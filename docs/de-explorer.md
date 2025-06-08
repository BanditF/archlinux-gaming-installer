# 🖥️ Desktop Environment Explorer

Safe exploration of community desktop configurations with complete isolation and gaming optimizations.

## ✨ Features

- **14 Curated Desktop Environments** from community showcases
- **Complete Configuration Isolation** - No ~/.config contamination
- **Gaming-Optimized** Hyprland configurations
- **SDDM Integration** with safe session switching
- **Backup & Restore** capabilities
- **Hardware Detection** for optimal compatibility

## 🎮 Included Configurations

### Hyprland Configurations
- **end-4/dots-hyprland** - AI integration with Material Design 3
- **JaKooLit/HyprPanel** - Multi-distro setup with AGS interface
- **Aylur/dotfiles** - Original AGS framework (joey_Mckur)
- **zDyanTB/hyprnova** - Clean config with advanced Hyprlock
- **Evren-os/hyprblaze** - NVIDIA gaming optimized
- **AymanLyesri/archeclipse** - Gaming setup with theming
- **ahmedSaadi0/my-hyprland-config** - Material Design 3
- **sansroot** - Multiple rice variations

### Other Desktop Environments
- **gh0stzk/BSPWM** - 18 different themes
- **WillPower3309/i3-gaps** - Optimized i3 configuration
- **KDE Plasma** - Sweet and Nordic themes
- **Sway** - Minimal configuration
- **AwesomeWM** - Lua-based configuration

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/de-explorer.git
cd de-explorer

# Make scripts executable
find . -name "*.sh" -exec chmod +x {} \;

# Run system check
./de-explorer.sh check

# List available desktop environments
./de-explorer.sh list

# Install a desktop environment (example)
./de-explorer.sh install hyprland-end4
```

## Project Structure

```
de-explorer/
├── configs/          # Configuration files for each DE
│   ├── kde/          # KDE Plasma configurations
│   ├── gnome/        # GNOME configurations  
│   ├── xfce/         # XFCE configurations
│   ├── i3/           # i3/i3-gaps configurations
│   ├── sway/         # Sway configurations
│   ├── awesome/      # AwesomeWM configurations
│   ├── bspwm/        # bspwm configurations
│   ├── dwm/          # dwm configurations
│   ├── qtile/        # Qtile configurations
│   ├── mate/         # MATE configurations
│   └── cinnamon/     # Cinnamon configurations
├── scripts/          # Installation and management scripts
│   ├── install/      # Installation scripts per DE
│   ├── uninstall/    # Clean removal scripts
│   ├── backup/       # Configuration backup tools
│   └── restore/      # Configuration restore tools
├── docs/             # Documentation and guides
├── backups/          # Automatic backups before changes
└── assets/           # Themes, wallpapers, fonts
```

## Installation Philosophy

### Safe and Reversible
- All changes are backed up before modification
- Each DE can be cleanly installed/removed
- Original configurations preserved
- SDDM integration for easy switching

### Modular Design
- Each DE has its own installation script
- Shared utilities for common tasks
- Dependency management per DE
- Conflict resolution between DEs

### Source Attribution
- All configurations credit original r/unixporn creators
- Links to original posts and repositories
- Adaptation notes for Arch Linux + current system

### Dependencies
- `git` and `stow` for syncing and linking dotfiles
- Desktop environment meta packages (Hyprland, KDE, GNOME)
- Arch install tools (`pacstrap`, `arch-chroot`)

### Dotfile Management
- Dotfiles for each environment live in `configs/<de>`
- `stow` links the selected set into the user's home directory
- Shared applications like Steam remain installed system-wide

## Usage

### Install a Desktop Environment
```bash
./scripts/install/install-kde.sh [theme-name]
./scripts/install/install-gnome.sh [theme-name]
```

### Switch Between DEs
- Use SDDM session selector at login
- Each DE appears as separate session option

### Backup/Restore
```bash
./scripts/backup/backup-current.sh
./scripts/restore/restore-config.sh [backup-name]
```

### Remove a DE
```bash
./scripts/uninstall/remove-kde.sh
```

## Status

- **Planning**: ✅ Project structure created
- **Research**: 🔄 Collecting r/unixporn configurations  
- **Framework**: ⏳ Base installation system
- **DEs**: ⏳ Individual environment setups

## Notes

This project maintains separation from the current .gilded Hyprland setup, allowing exploration without disrupting the working gaming environment.
