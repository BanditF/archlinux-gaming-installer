# Testing and Review Guide

This project relies on shell scripts to automate installation of Arch Linux and multiple desktop environments. Because the scripts modify the system extensively, run them only in a disposable virtual machine before trusting them on real hardware.

## Static Analysis

1. **ShellCheck** – Run `shellcheck` on all `*.sh` files to catch common issues:
   ```bash
   find . -name "*.sh" -print0 | xargs -0 shellcheck
   ```
   Install the `shellcheck` package from your distribution if it's not available.

## Virtual Machine Testing

1. **Create a VM** – Use QEMU, VirtualBox, or any hypervisor capable of booting an Arch ISO.
2. **Boot the Arch ISO** and clone this repository inside the live environment:
   ```bash
   git clone https://github.com/yourusername/archlinux-gaming-installer.git
   cd archlinux-gaming-installer
   ```
3. **Run the installer** with a small virtual disk. For example:
   ```bash
   sudo ./installer/full-install.sh --de hyprland
   ```
4. **Verify** that the installation completes and that the selected desktop environment loads after reboot.

## Reviewing External Dotfiles

All dotfiles under `configs/` originate from community repositories. Review each
file for unwanted settings or hard‑coded paths before adding them to the VM. A
helper script `scripts/analyze-dependencies.sh` scans dotfiles for referenced
commands so you can install any missing packages before testing:

```bash
./scripts/analyze-dependencies.sh configs/hyprland
```

Keep a changelog of any modifications.

## Troubleshooting

If the installation fails, collect the log stored in `/tmp` by the installer scripts and open an issue with the relevant excerpts.
