# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles. Nix is the only path — no fallback scripts. Supports macOS (nix-darwin), NixOS, and any Linux/WSL2 via standalone Home Manager.

Claude Code and Copilot configs live in **separate repos**, cloned independently when needed.

## Repo Layout

```
nix/
  flake.nix                    # Entry point — inputs, Darwin/NixOS/homeConfigurations outputs
  home.nix                     # Home Manager: packages, shells (bash/zsh/fish), programs, git
  darwin-configuration.nix     # macOS system settings + Homebrew module
  nixos-configuration.nix      # NixOS system settings
config/
  nushell/                     # Nushell config (config.nu, env.nu) + starship.toml
  ssh/                         # SSH config
  git/                         # Global gitignore, gitalias.txt (GitAlias project)
  powershell/                  # Windows PowerShell profile
```

## Key Commands

| Task | Command |
|------|---------|
| Apply config (Mac) | `sudo darwin-rebuild switch --flake ~/.dotfiles/nix` (`nix-rb`) |
| Apply config (NixOS) | `sudo nixos-rebuild switch --flake ~/.dotfiles/nix` |
| Apply config (Linux/WSL) | `home-manager switch --flake ~/.dotfiles/nix` |
| Update flake inputs | `nix flake update --flake ~/.dotfiles/nix` (`nix-up`) |
| Sync dotfiles | `git -C ~/.dotfiles pull` (`dotfiles-sync`) |

## Architecture

### `nix/flake.nix`

Declares `nixpkgs`, `nix-darwin`, `home-manager` inputs. Produces three output types:
- `darwinConfigurations` — macOS machines (nix-darwin + home-manager)
- `nixosConfigurations` — NixOS machines
- `homeConfigurations` — standalone home-manager for any Linux/WSL2

### `nix/home.nix`

User config shared across all platforms. Includes:
- **Packages**: ripgrep, fd, bat, fzf, eza, delta, lazygit, fnm, jq, btop, git-lfs, direnv, atuin, zoxide, wget, obsidian, gh, python3, nodejs, uv, bun, rustup + cargo tools, fonts
- **Shells**: bash, zsh, fish — consistent `commonAliases` let binding, same tool integrations
- **Programs**: starship, direnv (with nix-direnv), zoxide, atuin, fzf, alacritty, vim, vscode, git
- **Git**: GitAlias via `programs.git.includes`, global gitignore via `core.excludesFile`
- **Symlinks**: `mkOutOfStoreSymlink` for nushell, ssh/config, starship.toml

### `nix/darwin-configuration.nix`

macOS system settings + Homebrew module (`cleanup = "zap"` — only declared packages kept):
- **brews**: screenresolution
- **casks**: logitech-options, copilot-cli

### VS Code

Binary managed by Nix. Extensions and settings managed entirely via GitHub Settings Sync — no `userSettings` or `extensions` declared in Nix.

### Symlinks managed by Home Manager

| Symlink | Target |
|---------|--------|
| `~/.config/nushell` | `~/.dotfiles/config/nushell/` |
| `~/.ssh/config` | `~/.dotfiles/config/ssh/config` |
| `~/.config/starship.toml` | `~/.dotfiles/config/nushell/starship.toml` |

### Claude and Copilot configs (separate repos)

These are NOT in this repo. Clone independently:

```sh
git clone git@github.com:cdprice02/claude-config ~/.claude
git clone git@github.com:cdprice02/copilot-config ~/.copilot
```
