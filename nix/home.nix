{ config, pkgs, lib, system, username, ... }:

let
  home = config.home.homeDirectory;

  mkOutOfStoreSymlink = config.lib.file.mkOutOfStoreSymlink;

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

  # Shared shell aliases across bash, zsh, fish
  commonAliases = {
    dotfiles      = "git -C ~/.dotfiles";
    dotfiles-sync = "git -C ~/.dotfiles pull";
    nix-up        = "nix flake update --flake ~/.dotfiles/nix";
    nix-rb        = "sudo darwin-rebuild switch --flake ~/.dotfiles/nix";
  };

  # POSIX-compatible init snippets shared by bash and zsh
  nixDaemonInit = ''
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
  '';

  envLocalInit = ''
    if [ -f "$HOME/.claude/.env.local" ]; then
      source "$HOME/.claude/.env.local"
    fi
  '';

  gitaliasFile = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt";
    sha256 = "00hy0vhgvzqxh81szcwwkh2vapkimp7hp6cfccsymhd404kkgh0h";
  };
in
{
  home.username = username;
  home.homeDirectory = lib.mkForce (
    if pkgs.stdenv.isDarwin then
      "/Users/${username}"
    else
      "/home/${username}"
  );

  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.packages = with pkgs; [
    # Fonts
    fira-code
    nerd-fonts.fira-code

    # Applications
    obsidian

    # Dev tools
    gh
    python3
    nodejs
    uv
    bun
    qmkPackage

    # Rust toolchain manager + cargo tools
    rustup
    cargo-edit
    cargo-watch
    cargo-expand
    cargo-audit

    # Node version management
    fnm

    # CLI essentials
    jq
    neofetch
    ripgrep
    fd
    bat
    eza
    delta
    lazygit
    git-lfs
    wget
    btop
  ];

  # Symlinks to mutable, git-tracked config dirs outside the Nix store.
  # Note: ~/.claude and ~/.copilot are NOT managed here — clone independently:
  #   git clone git@github.com:cdprice02/claude-config ~/.claude
  #   git clone git@github.com:cdprice02/copilot-config ~/.copilot
  home.file = {
    ".config/nushell".source = mkOutOfStoreSymlink "${home}/.dotfiles/config/nushell";
    ".ssh/config".source     = mkOutOfStoreSymlink "${home}/.dotfiles/config/ssh/config";
    ".config/starship.toml".source = mkOutOfStoreSymlink "${home}/.dotfiles/config/nushell/starship.toml";
  };

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

  # Shells — all three configured consistently with shared aliases and tool integrations.
  # programs.direnv, zoxide, atuin, fzf, starship inject their init automatically.

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = commonAliases;
    initExtra = nixDaemonInit + envLocalInit;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = commonAliases;
    initContent = nixDaemonInit + envLocalInit + ''
      eval "$(fnm env --use-on-cd)"
    '';
  };

  programs.fish = {
    enable = true;
    shellAliases = commonAliases;

    interactiveShellInit = ''
      if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        bass source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      end

      if test -f "$HOME/.claude/.env.local"
        source "$HOME/.claude/.env.local"
      end

      fnm env --use-on-cd | source
    '';

    plugins = [
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

  # Prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Per-directory environment variables with nix flake shell support
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Smart cd
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Shell history with sync
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Fuzzy finder with shell integrations
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Terminal
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

  # Editor
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

  # VS Code — binary managed by Nix; extensions and settings via GitHub Settings Sync.
  # No userSettings declared here: Settings Sync owns settings.json.
  programs.vscode = {
    enable = true;
  };

  # Git
  programs.git = {
    enable = true;
    userName = "cdprice02";
    userEmail = "cdprice02@gmail.com";

    includes = [
      { path = "${gitaliasFile}"; }
    ];

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.default = "simple";
      push.autoSetupRemote = true;
      core.autocrlf = "input";
      core.excludesFile = "${home}/.dotfiles/config/git/ignore";
      credential.helper = "osxkeychain";

      diff.tool = "vscode";
      merge.tool = "vscode";
      difftool."vscode".cmd = "code --wait --diff $LOCAL $REMOTE";
      mergetool."vscode".cmd = "code --wait $MERGED";
    };

  };

  home.stateVersion = "23.11";
}
