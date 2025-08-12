# dotfiles

Personal dotfiles managed with [Dotbot](https://github.com/anishathalye/dotbot) for cross-platform configuration management.

## Features

- **Cross-platform support**: Separate configurations for Linux/macOS and Windows
- **Automatic OS detection**: Installation script detects your OS and uses the appropriate config
- **Shell configurations**: Includes `.bashrc` and `.zshrc` with dotfiles aliases and Nix commands
- **Nix integration**: Full Nix Darwin configuration for macOS (Linux config also includes Nix support)
- **Modern shell tools**: Configurations for Nushell and Starship prompt
- **Git submodule management**: Dotbot included as submodule with automatic initialization

## Installation

### Quick Start

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

### Manual Installation

If you prefer to run the installation manually:

1. Initialize submodules:
   ```bash
   git submodule update --init --recursive
   ```

2. Run Dotbot with specific configuration:
   ```bash
   # For Linux/macOS
   ./dotbot/bin/dotbot -d . -c install.conf.linux.yaml
   
   # For Windows
   ./dotbot/bin/dotbot -d . -c install.conf.windows.yaml
   ```

## Configuration Files

### Linux/macOS (`install.conf.linux.yaml`)

Links the following configurations:
- Shell configurations: `~/.bashrc`, `~/.zshrc`
- Nix configuration: `~/.config/nix/` (includes Darwin flake)
- Nushell: `~/.config/nushell/`
- Starship: `~/.config/starship.toml`

### Windows (`install.conf.windows.yaml`)

Links the following configurations (excludes Nix):
- Shell configurations: `~/.bashrc`, `~/.zshrc`
- Nushell: `~/AppData/Roaming/nushell/`
- Starship: `~/.config/starship.toml`

## Included Tools and Configurations

### Shell Configurations
- **Bash**: `.bashrc` with dotfiles alias and Nix shortcuts
- **Zsh**: `.zshrc` with dotfiles alias and Nix shortcuts  
- **Nushell**: Modern shell with structured data (placeholder config included)

### Prompt
- **Starship**: Cross-shell prompt with Git integration (basic config included)

### Package Management
- **Nix**: Functional package manager with Darwin configuration for macOS
  - Includes system packages, fonts, and Homebrew integration
  - Darwin-specific system defaults and preferences

## Usage

### Dotfiles Management
Use the included alias for managing dotfiles:
```bash
# Show status of dotfiles repository
dotfiles status

# Add new dotfiles
dotfiles add ~/.new-config-file
dotfiles commit -m "Add new config file"
dotfiles push
```

### Nix Commands (macOS/Linux)
```bash
# Update Nix flake
nix-up

# Rebuild Darwin system (macOS)
nix-rb
```

### Updating
To update your dotfiles:
```bash
cd ~/.dotfiles
git pull
./install.sh
```

## Customization

### Adding New Dotfiles
1. Add your dotfile to the repository
2. Update the appropriate YAML configuration file:
   - `install.conf.linux.yaml` for Linux/macOS
   - `install.conf.windows.yaml` for Windows
3. Run `./install.sh` to apply changes

### Platform-Specific Configurations
The installation system supports platform-specific configurations. Add files to the appropriate configuration and they will only be linked on the target platform.

## Directory Structure
```
.dotfiles/
├── install.sh                    # Installation script with OS detection
├── install.conf.linux.yaml      # Linux/macOS configuration
├── install.conf.windows.yaml    # Windows configuration  
├── .bashrc                       # Bash configuration
├── .zshrc                        # Zsh configuration
├── config/
│   ├── nushell/                  # Nushell configurations
│   └── starship.toml            # Starship prompt configuration
├── nix/
│   └── darwin/                   # Nix Darwin configuration
└── dotbot/                       # Dotbot submodule
```

## License

This is a personal dotfiles repository. Feel free to use any configurations that are helpful!