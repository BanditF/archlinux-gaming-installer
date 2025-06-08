#!/bin/bash
# Arch Linux and Desktop Environment installer
# Simplified script to automate installation with riced desktop environments

set -e

# Default settings
HOSTNAME="archlinux"
USERNAME="gamer"
DESKTOP="hyprland"

usage() {
    echo "Usage: $0 [--hostname name] [--user name] [--de hyprland|kde|gnome]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --hostname)
            HOSTNAME="$2"; shift 2;;
        --user)
            USERNAME="$2"; shift 2;;
        --de)
            DESKTOP="$2"; shift 2;;
        -h|--help)
            usage;;
        *)
            echo "Unknown option $1"; usage;;
    esac
done

BASE_PACKAGES=(
    base
    linux
    linux-firmware
    neovim
    zsh
    sudo
    networkmanager
    git
    stow
)

# Desktop-specific package groups
HYPR_PACKAGES=(hyprland waybar foot)
KDE_PACKAGES=(plasma-meta kde-applications sddm)
GNOME_PACKAGES=(gnome gdm)

install_base() {
    echo "==> Installing base system"
    pacstrap /mnt "${BASE_PACKAGES[@]}"
    genfstab -U /mnt >> /mnt/etc/fstab
}

configure_system() {
    arch-chroot /mnt /bin/bash -e <<EOF_CHROOT
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc
sed -i 's/#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "$HOSTNAME" > /etc/hostname
useradd -m -G wheel -s /bin/zsh $USERNAME
echo "$USERNAME ALL=(ALL) ALL" >> /etc/sudoers.d/99_$USERNAME
passwd -d root
passwd -d $USERNAME
chsh -s /bin/zsh $USERNAME
EOF_CHROOT
}

# Copy project configs into the new system for dotfile management
setup_configs() {
    echo "==> Preparing configuration files"
    mkdir -p /mnt/opt/de-explorer
    cp -r configs /mnt/opt/de-explorer/
}

install_desktop() {
    local packages=()
    case "$DESKTOP" in
        hyprland)
            packages=("${HYPR_PACKAGES[@]}")
            ;;
        kde)
            packages=("${KDE_PACKAGES[@]}")
            ;;
        gnome)
            packages=("${GNOME_PACKAGES[@]}")
            ;;
        *)
            echo "Unsupported desktop $DESKTOP"; exit 1;;
    esac

    arch-chroot /mnt pacman -S --noconfirm "${packages[@]}"

    if [[ "$DESKTOP" == "kde" ]]; then
        arch-chroot /mnt systemctl enable sddm
    elif [[ "$DESKTOP" == "gnome" ]]; then
        arch-chroot /mnt systemctl enable gdm
    fi
}

apply_ricing() {
    arch-chroot /mnt /bin/bash -e <<'EOF_CHROOT'
echo "Applying ricing for $DESKTOP"
# Placeholder for theme setup
echo "Install custom themes and dotfiles here"
EOF_CHROOT
}

# Use stow to link dotfiles for the chosen desktop environment
install_dotfiles() {
    arch-chroot /mnt /bin/bash -e <<EOF_CHROOT
if [ -d /opt/de-explorer/configs/$DESKTOP ]; then
    cd /opt/de-explorer/configs
    sudo -u $USERNAME stow -t /home/$USERNAME $DESKTOP
fi
EOF_CHROOT
}

main() {
    echo "### Arch Linux Installer ###"
    echo "Hostname: $HOSTNAME"
    echo "Username: $USERNAME"
    echo "Desktop: $DESKTOP"

    echo "==> Partition the disk manually and mount to /mnt before running this script."

    install_base
    configure_system
    setup_configs
    install_desktop
    apply_ricing
    install_dotfiles

    echo "Installation complete. You can reboot now."
}

main
