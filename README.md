# dotfiles

Personal dotfiles managed with [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager) via [nix-darwin](https://github.com/LnL7/nix-darwin). Supports macOS, NixOS, and any Linux/WSL2.

## Requirements

[Nix](https://nixos.org/download/) must be installed. No other prerequisites.

## Installation

### macOS

```sh
git clone git@github.com:cdprice02/.dotfiles.git ~/.dotfiles
sudo darwin-rebuild switch --flake ~/.dotfiles/nix
```

### NixOS

```sh
git clone git@github.com:cdprice02/.dotfiles.git ~/.dotfiles
sudo nixos-rebuild switch --flake ~/.dotfiles/nix
```

### Linux / WSL2 (any distro)

```sh
# 1. Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# 2. Clone and apply
git clone git@github.com:cdprice02/.dotfiles.git ~/.dotfiles
nix run home-manager -- switch --flake ~/.dotfiles/nix
```

### Windows (native shell)

Dev work runs in WSL2 + Nix (see above). To link the PowerShell profile for native Windows use:

```powershell
New-Item -ItemType SymbolicLink -Path $PROFILE `
  -Target "$HOME\.dotfiles\config\powershell\profile.ps1" -Force
```

## Daily commands

| Task | Command |
|------|---------|
| Apply config changes (Mac) | `nix-rb` |
| Apply config changes (Linux) | `home-manager switch --flake ~/.dotfiles/nix` |
| Update flake inputs | `nix-up` |
| Sync dotfiles | `dotfiles-sync` |
| Run git on dotfiles repo | `dotfiles <args>` |

## What's managed

**Packages**: starship, ripgrep, fd, bat, fzf, eza, delta, lazygit, fnm, jq, btop, git-lfs, direnv, atuin, zoxide, wget, obsidian, gh, python3, nodejs, uv, bun, rustup + cargo tools, Fira Code fonts, and more.

**Shells**: bash, zsh, fish — consistent aliases, completions, and tool integrations across all three.

**Programs**: git (with [GitAlias](https://github.com/GitAlias/gitalias)), vim, VS Code, alacritty, starship, direnv, zoxide, atuin, fzf.

**macOS system**: Homebrew casks, Touch ID sudo, Dock/Finder/keyboard defaults.

## Repo layout

```
nix/
  flake.nix                    # Entry point — inputs, Darwin/NixOS/home-manager outputs
  home.nix                     # Home Manager: packages, shells, programs
  darwin-configuration.nix     # macOS system settings + Homebrew
  nixos-configuration.nix      # NixOS system settings
config/
  nushell/                     # Nushell config + starship.toml (symlinked by Home Manager)
  ssh/                         # SSH config (symlinked by Home Manager)
  git/                         # Global gitignore, gitalias.txt
  powershell/                  # Windows PowerShell profile
```

## Separate repos

Claude Code and Copilot configs are not in this repo — clone independently when needed:

```sh
git clone git@github.com:cdprice02/claude-config ~/.claude
git clone git@github.com:cdprice02/copilot-config ~/.copilot
```
