{ pkgs, system, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.primaryUser = username;

  # Define user for Home Manager compatibility
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    description = username;
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Enable TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 6;
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

  system.stateVersion = 6;
}
