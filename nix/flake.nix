{
  description = "cdprice nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    }; 
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask }:
  let
    configuration = { pkgs, config, ... }: {
      # Allow non-opensource packages
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.alacritty
          pkgs.git
          pkgs.qmk
          pkgs.obsidian
          pkgs.vim
          pkgs.vscode
        ];

      fonts.packages = 
        [
          pkgs.fira-code
        ];

      homebrew = {
        enable = true;
 
        casks = [];

        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      security.pam.services.sudo_local.touchIdAuth = true;

      system.primaryUser = "cdprice";
      system.defaults = {
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleShowAllExtensions = true;
          ApplePressAndHoldEnabled = false;
          # 120, 90, 60, 30, 12, 6, 2
          KeyRepeat = 6;
          # 120, 94, 68, 35, 25, 15
          InitialKeyRepeat = 15;
          "com.apple.mouse.tapBehavior" = 1;
        };
        dock = {
          autohide = false;
          show-recents = false;
          launchanim = true;
          mru-spaces = false;
          orientation = "bottom";
          tilesize = 48;
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          CreateDesktop = false;
          FXPreferredViewStyle = "clmv";
          NewWindowTarget = "Home";
          ShowPathbar = true;
        };
        loginwindow.LoginwindowText = "May the odds be ever in your favor.";
        menuExtraClock.ShowSeconds = true;
        screensaver.askForPasswordDelay = 10;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#cdprice-lap
    # $ darwin-rebuild build --flake .
    darwinConfigurations."cdprice-lap" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;

            user = "cdprice";

            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            mutableTaps = false;

            autoMigrate = true;
          };
        }
      ];
    };
  };
}
