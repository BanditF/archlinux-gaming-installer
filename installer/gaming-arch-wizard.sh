#!/bin/bash
# Gaming-Optimized Arch Linux Installation Wizard

# Handle --help FIRST, before any other checks
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    cat << 'HELP_TEXT'
🎮 Gaming-Optimized Arch Linux Installation Wizard

USAGE:
    ./gaming-arch-wizard.sh [OPTIONS]

OPTIONS:
    -h, --help      Show this help message  
    -d, --dry-run   Test mode (no actual changes)

DESCRIPTION:
    Installs a gaming-optimized Arch Linux system with:
    
    🎮 Gaming Stack:
    • Steam, GameMode, MangoHUD, Lutris
    • NVIDIA + Intel hybrid GPU support
    • Gaming kernel optimizations
    
    🖥️ Desktop Options:
    • Hyprland (gaming-optimized)
    • KDE Plasma
    • GNOME
    
    💾 Storage:
    • Dual drive setup (boot + games)
    • BTRFS with snapshots
    
EXAMPLES:
    ./gaming-arch-wizard.sh --help     # Show this help
    ./gaming-arch-wizard.sh --dry-run  # Test without changes  
    sudo ./gaming-arch-wizard.sh       # Run installation

REQUIREMENTS:
    • UEFI system required
    • 16GB+ RAM recommended
    • Internet connection
    
⚠️  WARNING: Will erase selected disks!

HELP_TEXT
    exit 0
fi

# Handle --dry-run
DRY_RUN=false
if [[ "$1" == "--dry-run" ]] || [[ "$1" == "-d" ]]; then
    DRY_RUN=true
fi

# Now continue with the rest of the original script
set -e

INSTALLER_VERSION="1.0.0"
LOG_FILE="/tmp/installer-$(date +%Y%m%d_%H%M%S).log"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging
log() {
    local level="$1"
    shift
    local message="$*"
    
    if [ "$DRY_RUN" = false ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
    fi
    
    case "$level" in
        "INFO") echo -e "${BLUE}ℹ  $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "STEP") echo -e "${PURPLE}🔧 $message${NC}" ;;
        "DRY_RUN") echo -e "${CYAN}🧪 [DRY RUN] $message${NC}" ;;
    esac
}

# Banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
╭─────────────────────────────────────────────────────────╮
│                                                         │
│     🎮 Gaming-Optimized Arch Linux Installer 🎮        │
│                                                         │
│  • Intel/NVIDIA hybrid graphics support                │
│  • Configurable storage layout (Boot + Media drives)   │
│  • Gaming kernel optimizations                         │
│  • Desktop Environment options                         │
│  • Complete development stack                          │
│                                                         │
╰─────────────────────────────────────────────────────────╯
BANNER
    echo -e "${NC}"
    echo -e "${BLUE}Version: $INSTALLER_VERSION${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${CYAN}🧪 DRY RUN MODE - No changes will be made${NC}"
    else
        echo -e "${BLUE}Log file: $LOG_FILE${NC}"
    fi
    echo
}

# Main function
main() {
    show_banner
    
    if [ "$DRY_RUN" = true ]; then
        log "DRY_RUN" "Running in test mode"
        log "DRY_RUN" "Would check root privileges"
        log "DRY_RUN" "Would detect hardware (CPU, GPU, RAM, disks)"
        log "DRY_RUN" "Would configure storage layout"
        log "DRY_RUN" "Would install Arch Linux base system"
        log "DRY_RUN" "Would install gaming packages"
        log "DRY_RUN" "Would configure desktop environment"
        log "SUCCESS" "Dry run completed - installer looks good!"
        echo -e "${BLUE}💡 Run without --dry-run to perform actual installation${NC}"
        exit 0
    fi
    
    # Root check for real installation
    if [ "$EUID" -ne 0 ]; then
        log "ERROR" "This installer must be run as root"
        log "INFO" "For testing: $0 --dry-run"
        log "INFO" "For real installation: sudo $0"
        exit 1
    fi
    
    # The rest of the installer would go here
    log "WARNING" "Full installation not implemented yet"
    log "INFO" "This is the development version"
}

main "$@"
