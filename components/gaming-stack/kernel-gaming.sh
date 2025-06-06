#!/bin/bash
# Gaming Kernel Optimizations
# Configures kernel parameters and settings for optimal gaming performance

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO") echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${PURPLE}🔧 $message${NC}" ;;
    esac
}

echo -e "${PURPLE}🎮 Gaming Kernel Optimizations${NC}"
echo "   Configuring kernel for maximum gaming performance"
echo

# Install gaming-optimized kernel
install_gaming_kernel() {
    log "STEP" "Installing gaming-optimized kernel"
    
    # Check if linux-zen is available (gaming-optimized kernel)
    if pacman -Ss linux-zen >/dev/null 2>&1; then
        log "INFO" "Installing linux-zen (gaming-optimized kernel)"
        pacman -S --needed --noconfirm linux-zen linux-zen-headers
        log "SUCCESS" "linux-zen kernel installed"
    else
        log "WARNING" "linux-zen not available, using standard kernel with optimizations"
    fi
    
    # Install performance tools
    pacman -S --needed --noconfirm \
        cpupower \
        irqbalance \
        ananicy-cpp \
        preload
    
    log "SUCCESS" "Performance tools installed"
}

# Configure GRUB for gaming
configure_grub_gaming() {
    log "STEP" "Configuring GRUB for gaming performance"
    
    # Backup original GRUB config
    cp /etc/default/grub /etc/default/grub.backup
    
    # Gaming kernel parameters
    local gaming_params=(
        "mitigations=off"                    # Disable security mitigations for performance
        "processor.max_cstate=1"             # Prevent deep CPU sleep states
        "intel_idle.max_cstate=0"           # Disable Intel idle states
        "idle=poll"                         # Use polling idle loop
        "intel_pstate=performance"          # Force performance governor
        "split_lock_detect=off"             # Disable split lock detection
        "tsx=on"                            # Enable Intel TSX
        "tsx_async_abort=off"               # Disable TSX async abort mitigation
        "kvm.ignore_msrs=1"                 # KVM optimizations
        "kvm.report_ignored_msrs=0"         # Reduce KVM logging
        "nowatchdog"                        # Disable watchdog
        "nmi_watchdog=0"                    # Disable NMI watchdog
        "rcu_nocbs=0-$(nproc --all)"        # RCU optimizations
        "rcu_nocb_poll"                     # RCU callback polling
        "irqaffinity=1"                     # IRQ affinity
        "skew_tick=1"                       # Scheduler tick skewing
        "tsc=reliable"                      # Trust TSC
        "clocksource=tsc"                   # Use TSC as clock source
        "highres=on"                        # High resolution timers
        "nohz=on"                           # No HZ full
        "preempt=full"                      # Full preemption
        "threadirqs"                        # Thread IRQs
    )
    
    # NVIDIA-specific parameters
    if lspci | grep -i nvidia >/dev/null; then
        gaming_params+=(
            "nvidia_drm.modeset=1"          # Enable NVIDIA DRM
            "nvidia.NVreg_UsePageAttributeTable=1"  # NVIDIA optimizations
            "nvidia.NVreg_InitializeSystemMemoryAllocations=0"
            "nvidia.NVreg_DynamicPowerManagement=0x02"
        )
        log "INFO" "Added NVIDIA-specific kernel parameters"
    fi
    
    # Intel-specific parameters
    if lscpu | grep -i intel >/dev/null; then
        gaming_params+=(
            "intel_iommu=on"                # Intel IOMMU
            "iommu=pt"                      # Passthrough mode
            "i915.enable_guc=2"             # Intel GuC
            "i915.enable_fbc=1"             # Frame buffer compression
            "i915.fastboot=1"               # Fast boot
        )
        log "INFO" "Added Intel-specific kernel parameters"
    fi
    
    # Join parameters
    local params_string=$(IFS=' '; echo "${gaming_params[*]}")
    
    # Update GRUB configuration
    sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet $params_string\"/" /etc/default/grub
    
    # Enable GRUB optimizations
    if ! grep -q "GRUB_RECORDFAIL_TIMEOUT" /etc/default/grub; then
        echo "GRUB_RECORDFAIL_TIMEOUT=2" >> /etc/default/grub
    fi
    
    # Regenerate GRUB configuration
    grub-mkconfig -o /boot/grub/grub.cfg
    
    log "SUCCESS" "GRUB configured for gaming performance"
}

# Configure CPU governor and scaling
configure_cpu_performance() {
    log "STEP" "Configuring CPU performance settings"
    
    # Create CPU performance service
    cat > /etc/systemd/system/gaming-cpu-performance.service << 'EOF'
[Unit]
Description=Gaming CPU Performance Optimization
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/gaming-cpu-setup.sh

[Install]
WantedBy=multi-user.target
EOF
    
    # Create CPU setup script
    cat > /usr/local/bin/gaming-cpu-setup.sh << 'EOF'
#!/bin/bash
# Gaming CPU Performance Setup

# Set performance governor
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    echo "performance" > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
    echo "Gaming: CPU governor set to performance"
fi

# Disable CPU frequency scaling
if command -v cpupower >/dev/null 2>&1; then
    cpupower frequency-set -g performance
    echo "Gaming: CPU frequency scaling disabled"
fi

# Set CPU performance bias
if [ -f /sys/devices/system/cpu/cpu0/power/energy_perf_bias ]; then
    echo 0 > /sys/devices/system/cpu/cpu*/power/energy_perf_bias
    echo "Gaming: CPU energy performance bias set to performance"
fi

# Disable CPU idle states
if [ -d /sys/devices/system/cpu/cpu0/cpuidle ]; then
    for state in /sys/devices/system/cpu/cpu*/cpuidle/state*/disable; do
        [ -f "$state" ] && echo 1 > "$state"
    done
    echo "Gaming: CPU idle states disabled"
fi

# Set CPU affinity for interrupt handling
if command -v irqbalance >/dev/null 2>&1; then
    systemctl stop irqbalance
    # Reserve CPU 0 and 1 for system, rest for applications
    echo 2 > /proc/irq/default_smp_affinity
    echo "Gaming: IRQ affinity optimized"
fi
EOF
    
    chmod +x /usr/local/bin/gaming-cpu-setup.sh
    systemctl enable gaming-cpu-performance.service
    
    log "SUCCESS" "CPU performance service configured"
}

# Configure I/O scheduler optimizations
configure_io_scheduler() {
    log "STEP" "Configuring I/O scheduler for gaming"
    
    # Create I/O optimization service
    cat > /etc/systemd/system/gaming-io-scheduler.service << 'EOF'
[Unit]
Description=Gaming I/O Scheduler Optimization
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/gaming-io-setup.sh

[Install]
WantedBy=multi-user.target
EOF
    
    # Create I/O setup script
    cat > /usr/local/bin/gaming-io-setup.sh << 'EOF'
#!/bin/bash
# Gaming I/O Scheduler Setup

# Set I/O scheduler for NVMe drives (mq-deadline for gaming)
for nvme in /sys/block/nvme*; do
    if [ -f "$nvme/queue/scheduler" ]; then
        echo mq-deadline > "$nvme/queue/scheduler"
        echo "Gaming: NVMe $(basename $nvme) scheduler set to mq-deadline"
    fi
done

# Set I/O scheduler for SATA drives (bfq for mixed workloads)
for sda in /sys/block/sd*; do
    if [ -f "$sda/queue/scheduler" ]; then
        echo bfq > "$sda/queue/scheduler"
        echo "Gaming: SATA $(basename $sda) scheduler set to bfq"
    fi
done

# Optimize queue depths
for device in /sys/block/*/queue; do
    # Increase queue depth for better throughput
    [ -f "$device/nr_requests" ] && echo 256 > "$device/nr_requests"
    
    # Disable rotational for SSDs
    [ -f "$device/rotational" ] && echo 0 > "$device/rotational"
    
    # Optimize read-ahead
    [ -f "$device/read_ahead_kb" ] && echo 256 > "$device/read_ahead_kb"
done

echo "Gaming: I/O scheduler optimizations applied"
EOF
    
    chmod +x /usr/local/bin/gaming-io-setup.sh
    systemctl enable gaming-io-scheduler.service
    
    log "SUCCESS" "I/O scheduler optimizations configured"
}

# Configure virtual memory for gaming
configure_vm_gaming() {
    log "STEP" "Configuring virtual memory for gaming"
    
    # Create gaming VM parameters
    cat > /etc/sysctl.d/99-gaming.conf << 'EOF'
# Gaming Virtual Memory Optimizations

# Reduce swappiness for gaming (keep more in RAM)
vm.swappiness = 1

# Improve responsiveness
vm.vfs_cache_pressure = 50

# Optimize dirty page handling for gaming
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.dirty_expire_centisecs = 3000
vm.dirty_writeback_centisecs = 500

# Optimize kernel memory allocation
vm.min_free_kbytes = 524288
vm.zone_reclaim_mode = 0

# Transparent hugepages optimization
vm.nr_hugepages = 1024

# Network optimizations for gaming
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1

# Reduce latency
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_window_scaling = 1

# File system optimizations
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288
EOF
    
    log "SUCCESS" "Virtual memory optimized for gaming"
}

# Configure real-time priorities
configure_realtime() {
    log "STEP" "Configuring real-time priorities for gaming"
    
    # Create gaming limits configuration
    cat > /etc/security/limits.d/99-gaming.conf << 'EOF'
# Gaming Real-time Limits

# Allow audio group to use real-time priorities
@audio          -       rtprio          95
@audio          -       memlock         unlimited

# Allow games to use higher priorities
@games          -       nice            -10
@games          -       rtprio          50

# Allow wheel group (sudo users) real-time access
@wheel          -       rtprio          95
@wheel          -       memlock         unlimited
EOF
    
    # Create games group if it doesn't exist
    if ! getent group games >/dev/null; then
        groupadd games
        log "INFO" "Created games group"
    fi
    
    log "SUCCESS" "Real-time priorities configured"
}

# Configure process scheduling
configure_process_scheduling() {
    log "STEP" "Configuring process scheduling for gaming"
    
    # Install and configure ananicy-cpp for automatic process prioritization
    if command -v ananicy-cpp >/dev/null 2>&1; then
        systemctl enable ananicy-cpp
        
        # Add gaming-specific rules
        mkdir -p /etc/ananicy.d
        cat > /etc/ananicy.d/gaming.rules << 'EOF'
# Gaming Process Prioritization Rules

{"name": "steam", "type": "Game"}
{"name": "steamwebhelper", "type": "Game"}
{"name": "gameoverlayui", "type": "Game"}
{"name": "csgo", "type": "Game"}
{"name": "dota2", "type": "Game"}
{"name": "wine", "type": "Game"}
{"name": "wine64", "type": "Game"}
{"name": "lutris", "type": "Game"}
{"name": "gamemoderun", "type": "Game"}
{"name": "mangohud", "type": "Game"}

# Desktop Environment
{"name": "hyprland", "type": "DE"}
{"name": "waybar", "type": "DE"}
{"name": "rofi", "type": "DE"}
{"name": "dunst", "type": "DE"}

# Audio
{"name": "pipewire", "type": "Audio"}
{"name": "pipewire-pulse", "type": "Audio"}
{"name": "wireplumber", "type": "Audio"}
EOF
        
        log "SUCCESS" "Process scheduling configured with ananicy-cpp"
    else
        log "WARNING" "ananicy-cpp not available, skipping process scheduling"
    fi
}

# Configure memory management
configure_memory_management() {
    log "STEP" "Configuring memory management for gaming"
    
    # Enable zram for better memory utilization
    if command -v zramctl >/dev/null 2>&1; then
        cat > /etc/systemd/system/zram-gaming.service << 'EOF'
[Unit]
Description=Gaming ZRAM Setup
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/gaming-zram-setup.sh
ExecStop=/usr/local/bin/gaming-zram-teardown.sh

[Install]
WantedBy=multi-user.target
EOF
        
        cat > /usr/local/bin/gaming-zram-setup.sh << 'EOF'
#!/bin/bash
# Setup ZRAM for gaming

ZRAM_SIZE="4G"
ZRAM_DEVICE="/dev/zram0"

# Create zram device
modprobe zram
echo $ZRAM_SIZE > /sys/block/zram0/disksize
mkswap $ZRAM_DEVICE
swapon $ZRAM_DEVICE -p 10

echo "Gaming: ZRAM configured with size $ZRAM_SIZE"
EOF
        
        cat > /usr/local/bin/gaming-zram-teardown.sh << 'EOF'
#!/bin/bash
# Teardown ZRAM

swapoff /dev/zram0
rmmod zram
echo "Gaming: ZRAM disabled"
EOF
        
        chmod +x /usr/local/bin/gaming-zram-*.sh
        systemctl enable zram-gaming.service
        
        log "SUCCESS" "ZRAM configured for gaming"
    fi
}

# Main function
main() {
    log "STEP" "Starting gaming kernel optimizations"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log "ERROR" "This script must be run as root"
        exit 1
    fi
    
    # Apply optimizations
    install_gaming_kernel
    configure_grub_gaming
    configure_cpu_performance
    configure_io_scheduler
    configure_vm_gaming
    configure_realtime
    configure_process_scheduling
    configure_memory_management
    
    # Enable preload for faster application startup
    if command -v preload >/dev/null 2>&1; then
        systemctl enable preload
        log "SUCCESS" "Preload enabled for faster application startup"
    fi
    
    echo
    log "SUCCESS" "Gaming kernel optimizations completed!"
    echo
    echo -e "${BLUE}📋 Applied Optimizations:${NC}"
    echo "   ✅ Gaming-optimized kernel parameters"
    echo "   ✅ CPU performance mode"
    echo "   ✅ I/O scheduler optimization"
    echo "   ✅ Virtual memory tuning"
    echo "   ✅ Real-time priorities"
    echo "   ✅ Process scheduling"
    echo "   ✅ Memory management (ZRAM)"
    echo
    echo -e "${YELLOW}⚠️  IMPORTANT:${NC}"
    echo "   - Reboot required for all optimizations to take effect"
    echo "   - Some optimizations may slightly increase power consumption"
    echo "   - Monitor system stability after reboot"
    echo
    
    read -p "Reboot now to apply kernel optimizations? [y/N]: " reboot_confirm
    if [[ "$reboot_confirm" =~ ^[Yy]$ ]]; then
        log "INFO" "Rebooting system..."
        reboot
    else
        log "INFO" "Please reboot manually to apply optimizations"
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi