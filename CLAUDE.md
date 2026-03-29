# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Personal dotfiles. Manages Nix configuration for any Nix-capable machine (Mac via nix-darwin, Linux via NixOS) and minimal shell/SSH bootstrap for machines without Nix.

Claude Code and Copilot configs live in **separate repos**, cloned independently when needed.

## Repo Layout

```
nix/                  # All Nix configuration
  flake.nix           # Entry point — declares inputs, wires Darwin/NixOS configs
  home.nix            # Home Manager: packages, shells, editor, git, symlinks
  darwin-configuration.nix   # macOS system settings (Touch ID, Dock, Finder, etc.)
  nixos-configuration.nix    # NixOS system settings
nushell/              # Nushell shell config (config.nu, env.nu)
ssh/                  # SSH config
  config
.bashrc               # Minimal bash setup (aliases, .env.local sourcing)
install-minimal.sh    # Bootstrap for non-Nix machines
```

## Key Commands

| Task | Command |
|------|---------|
| Apply Nix config (Mac) | `sudo darwin-rebuild switch --flake ~/.dotfiles/nix` (`nix-rb` alias) |
| Apply Nix config (NixOS) | `sudo nixos-rebuild switch --flake ~/.dotfiles/nix` |
| Update flake inputs | `nix flake update --flake ~/.dotfiles/nix` (`nix-up` alias) |
| Sync dotfiles | `git -C ~/.dotfiles pull` (`dotfiles-sync` alias) |
| Bootstrap non-Nix machine | `./install-minimal.sh` |

## Architecture

### Nix path (`nix/`)

- **`flake.nix`** — Entry point. Declares `nixpkgs`, `nix-darwin`, `home-manager` inputs. Produces `darwinConfigurations` (Mac) and `nixosConfigurations` (Linux). All `import` paths are relative within `nix/`.
- **`darwin-configuration.nix`** — macOS system-level settings: Touch ID sudo, keyboard repeat, Dock, Finder defaults, enabled shells.
- **`nixos-configuration.nix`** — Linux system-level settings: user, enabled shells.
- **`home.nix`** — User config via Home Manager: packages (obsidian, gh, rustup, etc.), shell setup (fish, zsh), git, Alacritty, VS Code, and `mkOutOfStoreSymlink` entries for nushell and SSH config.

### Non-Nix path (`install-minimal.sh`)

Creates `.bashrc` and `~/.ssh/config` symlinks. That's it. Prints instructions for cloning claude/copilot repos separately.

### Claude and Copilot configs (separate repos)

These are NOT submodules. Clone them independently:

```sh
# Claude Code
git clone git@github.com:cdprice02/claude-config ~/.claude
cp ~/.claude/profiles/work/settings.local.json.example ~/.claude/settings.local.json
# (personal machines: profiles/personal/ once created)

# Copilot
git clone git@github.com:cdprice02/copilot-config ~/.copilot
```

Sync them with `git -C ~/.claude pull` / `git -C ~/.copilot pull`.

### Symlinks managed by Home Manager

| Symlink | Target |
|---------|--------|
| `~/.config/nushell` | `~/.dotfiles/nushell/` |
| `~/.ssh/config` | `~/.dotfiles/ssh/config` |

(On non-Nix machines `install-minimal.sh` creates these manually.)
