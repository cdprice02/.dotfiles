# dotfiles

Personal dotfiles managed with [Dotbot](https://github.com/anishathalye/dotbot) for cross-platform configuration management.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/cdprice02/.dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

The script will:
- Detect your operating system (Linux, macOS, or Windows)
- Initialize the Dotbot submodule
- Use the appropriate configuration file for your platform
- Create symlinks for all dotfiles and configurations

For manual installation:
```bash
git submodule update --init --recursive
# For Linux/macOS
./dotbot/bin/dotbot -d . -c install.conf.linux.yaml
# For Windows
./dotbot/bin/dotbot -d . -c install.conf.windows.yaml
```

## Configuration Files

### Linux/macOS (`install.conf.linux.yaml`)
Links these configs:
- Shell: `~/.bashrc`, `~/.zshrc`
- Nix: `~/.config/nix/`
- Nushell: `~/.config/nushell/`
- Starship: `~/.config/starship.toml`

### Windows (`install.conf.windows.yaml`)
Links these configs
- Shell: `~/.bashrc`
- Nushell: `~/AppData/Roaming/nushell/`
- Starship: `~/.config/starship.toml`

## Included Tools

- [Dotbot](https://github.com/anishathalye/dotbot)
- [Bash](https://www.gnu.org/software/bash)
- [Zsh](https://www.zsh.org/)
- [Nix](https://github.com/NixOS/nix)
- [Nushell](https://github.com/nushell/nushell)
- [Starship](https://github.com/starship/starship)

## Customization

To add new dotfiles:
1. Add the file to the repo.
2. Update the appropriate Dotbot YAML config (`install.conf.linux.yaml` or `install.conf.windows.yaml`).
3. Re-run `./install.sh`.

Platform-specific configs: Add files to the relevant config file and they will only be linked for the target platform.
