#!/bin/bash
# Gaming-Optimized Arch Linux Installation Wizard
# Production-ready installer with configurable storage and gaming optimizations

set -e

INSTALLER_VERSION="1.0.0"
CONFIG_FILE="/tmp/installer-config.json"
LOG_FILE="/tmp/installer-$(date +%Y%m%d_%H%M%S).log"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
    
    case "$level" in
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${PURPLE}🔧 $message${NC}" ;;
    esac
}

# Error handler
error_handler() {
    local line_no=$1
    log "ERROR" "Installation failed at line $line_no"
    log "ERROR" "Check log file: $LOG_FILE"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Show welcome banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
╭─────────────────────────────────────────────────────────╮
│                                                         │
│     🎮 Gaming-Optimized Arch Linux Installer 🎮        │
│                                                         │
│  • Intel/NVIDIA hybrid graphics support                │
│  • Configurable storage layout (Boot + Media drives)   │
│  • Gaming kernel optimizations                         │
│  • Desktop Environment Explorer integration            │
│  • Complete development stack                          │
│                                                         │
╰─────────────────────────────────────────────────────────╯
EOF
    echo -e "${NC}"
    echo -e "${BLUE}Version: $INSTALLER_VERSION${NC}"
    echo -e "${BLUE}Log file: $LOG_FILE${NC}"
    echo
}

# Hardware detection
detect_hardware() {
    log "STEP" "Detecting hardware configuration"
    
    # CPU Detection
    local cpu_vendor=$(lscpu | grep "Vendor ID" | awk '{print $3}')
    local cpu_model=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
    local cpu_cores=$(nproc)
    
    log "INFO" "CPU: $cpu_model ($cpu_cores cores)"
    
    # Memory Detection
    local total_ram_gb=$(free -g | grep Mem | awk '{print $2}')
    log "INFO" "RAM: ${total_ram_gb}GB"
    
    # GPU Detection
    local nvidia_gpu=""
    local intel_gpu=""
    local gpu_config="unknown"
    
    if lspci | grep -i nvidia >/dev/null; then
        nvidia_gpu=$(lspci | grep -i nvidia | grep VGA | head -1 | cut -d: -f3 | xargs)
        log "INFO" "NVIDIA GPU: $nvidia_gpu"
    fi
    
    if lspci | grep -i intel | grep -i vga >/dev/null; then
        intel_gpu=$(lspci | grep -i intel | grep VGA | head -1 | cut -d: -f3 | xargs)
        log "INFO" "Intel GPU: $intel_gpu"
    fi
    
    # Determine GPU configuration
    if [ -n "$nvidia_gpu" ] && [ -n "$intel_gpu" ]; then
        HARDWARE_GPU_CONFIG="hybrid_nvidia_intel"
        log "SUCCESS" "Hybrid NVIDIA + Intel configuration detected (optimal for gaming)"
    elif [ -n "$nvidia_gpu" ]; then
        HARDWARE_GPU_CONFIG="nvidia_only"
        log "SUCCESS" "NVIDIA-only configuration detected"
    elif [ -n "$intel_gpu" ]; then
        HARDWARE_GPU_CONFIG="intel_only"
        log "WARNING" "Intel-only configuration (limited gaming performance)"
    fi
    
    # Storage Detection
    log "INFO" "Available storage devices:"
    lsblk -d -o NAME,SIZE,TYPE | grep disk | while read -r line; do
        log "INFO" "  $line"
    done
    
    log "SUCCESS" "Hardware detection completed"
}

# Storage configuration wizard
configure_storage() {
    log "STEP" "Storage configuration wizard"
    
    echo -e "${BLUE}📦 Storage Configuration${NC}"
    echo "This installer supports flexible storage layouts:"
    echo "1. Single drive (all-in-one)"
    echo "2. Dual drive (recommended: Boot + Media)"
    echo "3. Custom layout"
    echo
    
    local available_disks=($(lsblk -d -o NAME -n | grep -E '^[sv]d[a-z]|^nvme[0-9]'))
    
    echo "Available disks:"
    for i in "${!available_disks[@]}"; do
        local disk="${available_disks[$i]}"
        local size=$(lsblk -d -o SIZE -n "/dev/$disk")
        echo "  $((i+1)). /dev/$disk ($size)"
    done
    echo
    
    # Boot drive selection
    while true; do
        read -p "Select boot drive (1-${#available_disks[@]}): " boot_choice
        if [[ "$boot_choice" =~ ^[0-9]+$ ]] && [ "$boot_choice" -ge 1 ] && [ "$boot_choice" -le "${#available_disks[@]}" ]; then
            local boot_disk="/dev/${available_disks[$((boot_choice-1))]}"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    
    log "INFO" "Boot drive selected: $boot_disk"
    
    # Media drive selection (optional)
    echo
    echo "Do you want a separate media/games drive? (recommended for gaming)"
    read -p "Use separate media drive? [Y/n]: " use_media_drive
    
    local media_disk=""
    if [[ "$use_media_drive" =~ ^[Nn]$ ]]; then
        log "INFO" "Using single drive layout"
    else
        echo "Available drives for media:"
        for i in "${!available_disks[@]}"; do
            local disk="${available_disks[$i]}"
            if [ "/dev/$disk" != "$boot_disk" ]; then
                local size=$(lsblk -d -o SIZE -n "/dev/$disk")
                echo "  $((i+1)). /dev/$disk ($size)"
            fi
        done
        
        while true; do
            read -p "Select media drive (or 0 for none): " media_choice
            if [ "$media_choice" = "0" ]; then
                break
            elif [[ "$media_choice" =~ ^[0-9]+$ ]] && [ "$media_choice" -ge 1 ] && [ "$media_choice" -le "${#available_disks[@]}" ]; then
                local selected_disk="/dev/${available_disks[$((media_choice-1))]}"
                if [ "$selected_disk" != "$boot_disk" ]; then
                    media_disk="$selected_disk"
                    break
                else
                    echo "Cannot use the same disk for boot and media. Please select a different disk."
                fi
            else
                echo "Invalid selection. Please try again."
            fi
        done
        
        if [ -n "$media_disk" ]; then
            log "INFO" "Media drive selected: $media_disk"
        fi
    fi
    
    # Store storage layout in variables
    STORAGE_BOOT_DISK="$boot_disk"
    STORAGE_MEDIA_DISK="$media_disk"
    if [ -z "$media_disk" ]; then
        STORAGE_LAYOUT="single"
    else
        STORAGE_LAYOUT="dual"
    fi
}

# Partition and format disks
setup_storage() {
    log "STEP" "Setting up storage layout"
    
    local boot_disk="$STORAGE_BOOT_DISK"
    local media_disk="$STORAGE_MEDIA_DISK"
    local layout="$STORAGE_LAYOUT"
    
    log "INFO" "Boot disk: $boot_disk"
    if [ "$layout" = "dual" ]; then
        log "INFO" "Media disk: $media_disk"
    fi
    
    # Partition boot disk
    log "INFO" "Partitioning boot disk: $boot_disk"
    
    # Clear existing partitions
    wipefs -a "$boot_disk"
    
    # Create GPT partition table
    parted "$boot_disk" mklabel gpt
    
    # EFI System Partition (512MB)
    parted "$boot_disk" mkpart ESP fat32 1MiB 513MiB
    parted "$boot_disk" set 1 esp on
    
    # Root partition (remaining space)
    parted "$boot_disk" mkpart primary btrfs 513MiB 100%
    
    # Format boot disk partitions
    local efi_part="${boot_disk}1"
    local root_part="${boot_disk}2"
    
    # Handle NVMe partition naming
    if [[ "$boot_disk" == *"nvme"* ]]; then
        efi_part="${boot_disk}p1"
        root_part="${boot_disk}p2"
    fi
    
    log "INFO" "Formatting EFI partition: $efi_part"
    mkfs.fat -F32 "$efi_part"
    
    log "INFO" "Formatting root partition with btrfs: $root_part"
    mkfs.btrfs -f "$root_part"
    
    # Create btrfs subvolumes
    mount "$root_part" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    umount /mnt
    
    # Mount root with optimizations
    mount -o compress=zstd:3,noatime,subvol=@ "$root_part" /mnt
    mkdir -p /mnt/{boot,home,snapshots}
    mount -o compress=zstd:3,noatime,subvol=@home "$root_part" /mnt/home
    mount -o compress=zstd:3,noatime,subvol=@snapshots "$root_part" /mnt/snapshots
    mount "$efi_part" /mnt/boot
    
    # Setup media disk if dual drive layout
    if [ "$layout" = "dual" ] && [ -n "$media_disk" ]; then
        log "INFO" "Setting up media disk: $media_disk"
        
        # Partition media disk
        wipefs -a "$media_disk"
        parted "$media_disk" mklabel gpt
        parted "$media_disk" mkpart primary ext4 1MiB 100%
        
        # Format media partition
        local media_part="${media_disk}1"
        if [[ "$media_disk" == *"nvme"* ]]; then
            media_part="${media_disk}p1"
        fi
        
        log "INFO" "Formatting media partition with ext4: $media_part"
        mkfs.ext4 -F "$media_part"
        
        # Mount media partition
        mkdir -p /mnt/data
        mount "$media_part" /mnt/data
        
        log "SUCCESS" "Media drive mounted at /data"
    fi
    
    log "SUCCESS" "Storage layout configured successfully"
}

# Install base system with gaming optimizations
install_base_system() {
    log "STEP" "Installing base system with gaming optimizations"
    
    # Update package database
    pacman -Sy
    
    # Base packages
    local base_packages=(
        "base"
        "linux"
        "linux-firmware"
        "linux-headers"  # For DKMS modules
        "btrfs-progs"
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "vim"
        "nano"
    )
    
    # Gaming kernel (if available)
    if pacman -Ss linux-zen >/dev/null 2>&1; then
        base_packages+=("linux-zen" "linux-zen-headers")
        log "INFO" "Adding gaming-optimized kernel (linux-zen)"
    fi
    
    log "INFO" "Installing base packages..."
    pacstrap /mnt "${base_packages[@]}"
    
    # Generate fstab with optimizations
    log "INFO" "Generating fstab with optimizations..."
    genfstab -U /mnt >> /mnt/etc/fstab
    
    # Add gaming-specific fstab optimizations
    cat >> /mnt/etc/fstab << 'EOF'

# Gaming optimizations
tmpfs /tmp tmpfs defaults,noatime,mode=1777 0 0
EOF
    
    log "SUCCESS" "Base system installed"
}

# Configure system
configure_system() {
    log "STEP" "Configuring system"
    
    # Get user preferences
    read -p "Enter hostname [gaming-rig]: " hostname
    hostname=${hostname:-gaming-rig}
    
    read -p "Enter username [gamer]: " username
    username=${username:-gamer}
    
    read -s -p "Enter password for $username: " password
    echo
    
    # Configure system in chroot
    arch-chroot /mnt /bin/bash << EOF
set -e

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Configure locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
echo "$hostname" > /etc/hostname

# Configure hosts
cat >> /etc/hosts << HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
HOSTS_EOF

# Set root password
echo "root:$password" | chpasswd

# Create user
useradd -m -G wheel,storage,power,audio,video -s /bin/bash $username
echo "$username:$password" | chpasswd

# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Install and configure bootloader
pacman -S --noconfirm grub efibootmgr os-prober

# Gaming kernel parameters
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& mitigations=off processor.max_cstate=1 intel_idle.max_cstate=0/' /etc/default/grub

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Install essential packages
pacman -S --noconfirm \\
    networkmanager \\
    openssh \\
    firewalld \\
    reflector \\
    pacman-contrib \\
    man-db \\
    man-pages

# Enable services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable firewalld
systemctl enable reflector.timer
systemctl enable fstrim.timer

EOF
    
    log "SUCCESS" "System configured"
}

# Install gaming stack
install_gaming_stack() {
    log "STEP" "Installing gaming stack"
    
    local gpu_config="$HARDWARE_GPU_CONFIG"
    
    arch-chroot /mnt /bin/bash << EOF
set -e

# Install AUR helper (yay)
cd /tmp
sudo -u $username git clone https://aur.archlinux.org/yay.git
cd yay
sudo -u $username makepkg -si --noconfirm
cd /
rm -rf /tmp/yay

# Gaming packages
pacman -S --noconfirm \\
    steam \\
    gamemode \\
    lib32-gamemode \\
    mangohud \\
    lib32-mangohud \\
    wine \\
    winetricks \\
    lutris

# Enable GameMode
systemctl --user enable gamemoded

EOF
    
    # GPU-specific installations
    if [ "$gpu_config" = "hybrid_nvidia_intel" ] || [ "$gpu_config" = "nvidia_only" ]; then
        log "INFO" "Installing NVIDIA drivers for gaming"
        
        arch-chroot /mnt /bin/bash << EOF
# NVIDIA drivers
pacman -S --noconfirm \\
    nvidia-dkms \\
    nvidia-utils \\
    lib32-nvidia-utils \\
    nvidia-settings \\
    libva-nvidia-driver

# Enable NVIDIA services
systemctl enable nvidia-suspend
systemctl enable nvidia-hibernate
systemctl enable nvidia-resume

EOF
    fi
    
    log "SUCCESS" "Gaming stack installed"
}

# Install desktop environment
install_desktop_environment() {
    log "STEP" "Installing desktop environment"
    
    echo -e "${BLUE}🖥️  Desktop Environment Selection${NC}"
    echo "Available options:"
    echo "1. Hyprland (Wayland, gaming-optimized)"
    echo "2. KDE Plasma (Traditional desktop)"
    echo "3. GNOME (Modern desktop)"
    echo "4. Minimal (no DE, manual setup later)"
    echo
    
    read -p "Select desktop environment [1]: " de_choice
    de_choice=${de_choice:-1}
    
    case $de_choice in
        1)
            log "INFO" "Installing Hyprland gaming setup"
            install_hyprland
            ;;
        2)
            log "INFO" "Installing KDE Plasma"
            install_kde
            ;;
        3)
            log "INFO" "Installing GNOME"
            install_gnome
            ;;
        4)
            log "INFO" "Minimal installation selected"
            ;;
        *)
            log "WARNING" "Invalid selection, defaulting to Hyprland"
            install_hyprland
            ;;
    esac
}

# Install Hyprland with gaming optimizations
install_hyprland() {
    arch-chroot /mnt /bin/bash << EOF
set -e

# Hyprland and essential packages
pacman -S --noconfirm \\
    hyprland \\
    waybar \\
    rofi-wayland \\
    dunst \\
    alacritty \\
    thunar \\
    grim \\
    slurp \\
    wl-clipboard \\
    xdg-desktop-portal-hyprland \\
    pipewire \\
    pipewire-pulse \\
    wireplumber

# Fonts
pacman -S --noconfirm \\
    ttf-jetbrains-mono \\
    noto-fonts \\
    noto-fonts-emoji

# Enable services
systemctl --user enable pipewire
systemctl --user enable wireplumber

EOF
    
    log "SUCCESS" "Hyprland installed"
}

# Install KDE Plasma
install_kde() {
    arch-chroot /mnt /bin/bash << EOF
set -e

pacman -S --noconfirm \\
    plasma-desktop \\
    sddm \\
    konsole \\
    dolphin \\
    kate \\
    firefox

systemctl enable sddm

EOF
    
    log "SUCCESS" "KDE Plasma installed"
}

# Install GNOME
install_gnome() {
    arch-chroot /mnt /bin/bash << EOF
set -e

pacman -S --noconfirm \\
    gnome \\
    gdm \\
    firefox

systemctl enable gdm

EOF
    
    log "SUCCESS" "GNOME installed"
}

# Install development stack
install_development_stack() {
    log "STEP" "Installing development stack"
    
    read -p "Install development tools? [Y/n]: " install_dev
    if [[ "$install_dev" =~ ^[Nn]$ ]]; then
        log "INFO" "Skipping development stack"
        return
    fi
    
    arch-chroot /mnt /bin/bash << EOF
set -e

# Development packages
pacman -S --noconfirm \\
    code \\
    neovim \\
    tmux \\
    nodejs \\
    npm \\
    python \\
    python-pip \\
    docker \\
    docker-compose \\
    git

# Enable Docker
systemctl enable docker
usermod -aG docker $username

EOF
    
    log "SUCCESS" "Development stack installed"
}

# Finalize installation
finalize_installation() {
    log "STEP" "Finalizing installation"
    
    # Update initramfs for gaming optimizations
    arch-chroot /mnt mkinitcpio -P
    
    # Create post-install script
    cat > /mnt/home/$username/post-install.sh << EOF
#!/bin/bash
# Post-installation setup script

echo "🎉 Gaming Arch Linux installation completed!"
echo
echo "Next steps:"
echo "1. Reboot the system"
echo "2. Log in as $username"
echo "3. Run DE Explorer: git clone <repo> && make install"
echo "4. Configure gaming optimizations"
echo
echo "Gaming features installed:"
echo "✅ Steam + GameMode + MangoHUD"
echo "✅ NVIDIA drivers (if applicable)"
echo "✅ Gaming kernel optimizations"
echo "✅ Performance-tuned storage"
echo
echo "Enjoy your gaming setup! 🎮"
EOF
    
    chmod +x /mnt/home/$username/post-install.sh
    chown $username:$username /mnt/home/$username/post-install.sh
    
    log "SUCCESS" "Installation finalized"
}

# Main installation flow
main() {
    show_banner
    
    # Pre-installation checks
    if [ "$EUID" -ne 0 ]; then
        log "ERROR" "This installer must be run as root"
        exit 1
    fi
    
    if [ ! -d "/sys/firmware/efi" ]; then
        log "ERROR" "UEFI system required"
        exit 1
    fi
    
    
    # Confirmation
    echo -e "${YELLOW}⚠️  This will erase selected disks and install Arch Linux${NC}"
    read -p "Continue? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log "INFO" "Installation cancelled"
        exit 0
    fi
    
    # Installation steps
    detect_hardware
    configure_storage
    setup_storage
    install_base_system
    configure_system
    install_gaming_stack
    install_desktop_environment
    install_development_stack
    finalize_installation
    
    echo
    log "SUCCESS" "Gaming Arch Linux installation completed successfully!"
    echo -e "${GREEN}🎮 Your gaming rig is ready!${NC}"
    echo -e "${BLUE}📋 Installation log: $LOG_FILE${NC}"
    echo
    read -p "Reboot now? [Y/n]: " reboot_now
    if [[ ! "$reboot_now" =~ ^[Nn]$ ]]; then
        reboot
    fi
}

# Run installer
main "$@"