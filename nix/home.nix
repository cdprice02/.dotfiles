{ config, pkgs, lib, system, username, ... }:

let
  # Pinned QMK on x86_64 systems
  qmkPackage =
    if lib.strings.hasPrefix "x86_64" system then
      let
        pinnedPkgs = import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/0c408a087b4751c887e463e3848512c12017be25.tar.gz";
          sha256 = "049l2w7sngxb354kkrvaigzkkiz5073y7s176xdvqgm4gyzp05dw";
        }) { inherit system; };
      in pinnedPkgs.qmk
    else pkgs.qmk;

  rustTargets =
    if pkgs.stdenv.isDarwin then
      [ "x86_64-apple-darwin" "aarch64-apple-darwin" ]
    else
      [ "x86_64-unknown-linux-gnu" "aarch64-unknown-linux-gnu" ];
in
{
  home.username = username;
  home.homeDirectory = lib.mkForce (
    if pkgs.stdenv.isDarwin then
      "/Users/${username}"
    else
      "/home/${username}"
  );

  # Shell session variables to ensure proper PATH
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.packages =
    with pkgs; [
      # Fonts
      fira-code
      nerd-fonts.fira-code

      # Applications
      obsidian

      # Simple dev tools
      gh
      python3Minimal
      qmkPackage
      nodejs
      uv
      bun

      # Rust toolchain manager
      rustup

      # Additional Rust development tools (from Nix for reliability)
      cargo-edit
      cargo-watch
      cargo-expand
      cargo-audit
    ];

  # Symlinks to mutable, git-tracked config dirs outside the Nix store.
  # mkOutOfStoreSymlink keeps these writable for git operations.
  # Note: ~/.claude and ~/.copilot are NOT managed here — clone independently:
  #   git clone git@github.com:cdprice02/claude-config ~/.claude
  #   git clone git@github.com:cdprice02/copilot-config ~/.copilot
  home.file = {
    ".config/nushell" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/nushell";
    };
    ".ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.dotfiles/ssh/config";
    };
  };

  # Run rustup setup directly during Home Manager activation
  home.activation.rustup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup toolchain install stable > /dev/null 2>&1
    $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup toolchain install beta > /dev/null 2>&1
    $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup toolchain install nightly > /dev/null 2>&1

    $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup default stable > /dev/null 2>&1

    $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup component add rust-src rust-analyzer rustfmt clippy > /dev/null 2>&1
    $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup component add --toolchain nightly rust-src rust-analyzer rustfmt clippy > /dev/null 2>&1

    ${if pkgs.stdenv.isDarwin then ''
      $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup target add x86_64-apple-darwin > /dev/null 2>&1
      $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup target add aarch64-apple-darwin > /dev/null 2>&1
    '' else ''
      $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup target add x86_64-unknown-linux-gnu > /dev/null 2>&1
      $DRY_RUN_CMD ${pkgs.rustup}/bin/rustup target add aarch64-unknown-linux-gnu > /dev/null 2>&1
    ''}
  '';

  # Configure shells
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      dotfiles      = "git -C ~/.dotfiles";
      dotfiles-sync = "git -C ~/.dotfiles pull";
      nix-up        = "nix flake update --flake ~/.dotfiles/nix";
      nix-rb        = "sudo darwin-rebuild switch --flake ~/.dotfiles/nix";
    };

    initContent = ''
      # Source the nix-daemon profile
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # Source machine-local environment variables (not tracked)
      if [ -f "$HOME/.claude/.env.local" ]; then
        source "$HOME/.claude/.env.local"
      fi
    '';
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      dotfiles      = "git -C ~/.dotfiles";
      dotfiles-sync = "git -C ~/.dotfiles pull";
      nix-up        = "nix flake update --flake ~/.dotfiles/nix";
      nix-rb        = "sudo darwin-rebuild switch --flake ~/.dotfiles/nix";
    };

    interactiveShellInit = ''
      # Source the nix-daemon profile
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        bass source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      end

      # Source machine-local environment variables (not tracked)
      if test -f "$HOME/.claude/.env.local"
        source "$HOME/.claude/.env.local"
      end
    '';

    plugins = [
      # Enable bass plugin for sourcing bash scripts
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "2fd3d2157d5271ca3575b13daec975ca4c10577a";
          sha256 = "sha256-fl4/Pgtkojk5AE52wpGDnuLajQxHoVqyphE90IIPYFU=";
        };
      }
    ];
  };

  # Terminal configuration
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.9;
        decorations = "buttonless";
      };
      font = {
        size = 14;
        normal.family = "Fira Code";
      };
      colors = {
        primary = {
          background = "#1e1e1e";
          foreground = "#d4d4d4";
        };
      };
    };
  };

  # Editor configuration
  programs.vim = {
    enable = true;
    defaultEditor = true;
    settings = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
    };
    extraConfig = ''
      syntax on
      set clipboard=unnamed
      set ignorecase
      set smartcase
    '';
  };

  # VS Code configuration
  programs.vscode = {
    enable = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "cdprice02";
    userEmail = "cdprice02@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.default = "simple";
      push.autoSetupRemote = true;
      core.autocrlf = "input";
      credential.helper = "osxkeychain";

      # Better diff and merge tools
      diff.tool = "vscode";
      merge.tool = "vscode";
      difftool."vscode".cmd = "code --wait --diff $LOCAL $REMOTE";
      mergetool."vscode".cmd = "code --wait $MERGED";
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      ca = "commit -a";
      ps = "push";
      pl = "pull";
      lg = "log --oneline --graph --decorate --all";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };
  };

  home.stateVersion = "23.11";
}
