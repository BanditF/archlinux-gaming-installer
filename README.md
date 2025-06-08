# 🎮 Gaming-Optimized Arch Linux Installer

Production-ready Arch Linux installer with gaming optimizations, hybrid GPU support, and configurable storage layout.

## ✨ Features

- **Gaming-Optimized Kernel** (linux-zen with custom parameters)
- **Hybrid GPU Support** (Intel/NVIDIA with Optimus)
- **Configurable Storage** (500GB boot + 3TB+ media drives)
- **Gaming Stack** (Steam, GameMode, MangoHud, Lutris)
- **Performance Tuning** (CPU governors, I/O optimizations)
- **Component-Based Architecture** for easy customization

## 🚀 Quick Start

```bash
# Download the installer
git clone https://github.com/yourusername/archlinux-gaming-installer.git
cd archlinux-gaming-installer

# Run the gaming wizard
chmod +x installer/gaming-arch-wizard.sh
sudo ./installer/gaming-arch-wizard.sh

# Or use the full installer with desktop selection
chmod +x installer/full-install.sh
sudo ./installer/full-install.sh --de hyprland
```

## 📦 Dependencies

The installer uses `pacstrap` from the Arch ISO and expects an active
internet connection. The base system installs `git` and `stow` so that
dotfiles can be managed automatically. Each desktop environment pulls in
its own packages such as `hyprland`, `plasma-meta`, or `gnome`.

## 🎯 Target Hardware

### Optimal Configuration
- **CPU**: Intel (i5/i7/i9 8th gen+) or AMD (Ryzen 3000+)
- **GPU**: NVIDIA RTX series + Intel iGPU (hybrid)
- **RAM**: 16GB+ DDR4/DDR5
- **Storage**: NVMe SSD (boot) + Large HDD/SSD (games)

### Supported Systems
- Desktop gaming rigs
- Gaming laptops (hybrid GPU)
- Intel/NVIDIA combinations
- AMD systems (experimental)

## 🛠️ Installation Components

### Core Gaming Stack
- **Kernel**: linux-zen with gaming optimizations
- **GPU**: NVIDIA drivers + Optimus management
- **Audio**: PipeWire with low latency
- **Gaming**: Steam, Lutris, Wine, GameMode
- **Monitoring**: MangoHud, nvtop, btop

### Desktop Environment Options
- **Hyprland** (default) - Gaming-optimized Wayland
- **KDE Plasma** - Feature-rich with gaming widgets
- **GNOME** - Clean and modern
- **i3/Sway** - Minimal and fast

## 💾 Storage Configuration

### Recommended Layout
```
┌─ Drive 1 (500GB SSD) ─┐    ┌─ Drive 2 (3TB+) ─┐
│  /boot    (1GB)       │    │  /data           │
│  /        (50GB)      │    │    ├── Steam     │
│  /home    (449GB)     │    │    ├── Media     │
│  swap     (8GB)       │    │    └── Downloads │
└───────────────────────┘    └──────────────────┘
```

### Filesystem Options
- **Boot Drive**: BTRFS (snapshots) or EXT4 (performance)
- **Media Drive**: EXT4 (optimal for large files)
- **Gaming Storage**: Dedicated partition for Steam

## ⚙️ Gaming Optimizations

### Kernel Tuning
- CPU governor: `performance` during gaming
- I/O scheduler: `mq-deadline` for gaming drives
- Memory management: Gaming-friendly swappiness
- Preemption: Low-latency desktop preemption

### GPU Configuration
- NVIDIA Performance Mode
- Optimus hybrid switching
- VRAM optimization
- Frame rate limiting options

### Audio Optimization
- PipeWire low-latency configuration
- Real-time audio scheduling
- Gaming audio profiles

## 🔧 Component Architecture

### Modular Installation
```
components/
├── base-system/      # Core Arch installation
├── gaming-stack/     # Gaming-specific packages
├── gpu-drivers/      # Graphics driver setup
├── audio-system/     # Audio configuration
├── desktop-env/      # DE installation
└── optimizations/    # Performance tuning
```

### Customization Options
- Skip components not needed
- Choose alternative packages
- Custom optimization profiles
- Post-install script hooks

## 🎮 Gaming Features

### Steam Integration
- Automatic Steam installation
- Proton compatibility layer setup
- Steam library on media drive
- Gaming library organization

### Performance Tools
- **GameMode**: Automatic game optimizations
- **MangoHud**: In-game performance overlay
- **CoreCtrl**: GPU/CPU control interface
- **Lutris**: Game launcher and library

### Compatibility
- Windows game compatibility (Proton/Wine)
- Emulation support (RetroArch, Dolphin)
- VR gaming setup (SteamVR)
- Streaming capabilities (Sunshine/Moonlight)

## 📋 Installation Process

1. **Hardware Detection**: Scan system capabilities
2. **Storage Planning**: Configure disk layout
3. **Base Installation**: Minimal Arch setup
4. **Gaming Stack**: Install gaming components
5. **GPU Setup**: Configure graphics drivers
6. **Optimizations**: Apply performance tuning
7. **Desktop Environment**: Install chosen DE
8. **Post-Install**: Final configuration and testing

## 🚀 Post-Installation

### First Boot
- Automatic driver loading
- Gaming optimizations active
- Steam ready for login
- Performance monitoring available

### Verification Commands
```bash
# Check gaming kernel
uname -r  # Should show linux-zen

# Verify GPU setup
nvidia-smi  # NVIDIA status
optimus-manager --print-mode  # Hybrid mode

# Test gaming stack
steam --version
gamemode --status
mangohud --version
```

## 🗂 Dotfile Management

Configuration files for each desktop environment live under the
`configs/` directory. During installation the scripts copy these folders
to `/opt/de-explorer` on the new system and use `stow` to link the
selected set into the user's home directory. Shared resources such as
the Steam library remain in `/data` so every environment can access the
same games.

## 📚 Documentation

- [Installation Guide](docs/installation.md)
- [Hardware Compatibility](docs/hardware.md)
- [Gaming Configuration](docs/gaming.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Desktop Environment Explorer](docs/de-explorer.md)

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

**⚠️ Warning**: This installer modifies system configurations extensively. Backup important data before use.
