#!/bin/bash

# ╔═════════════════════════════════════════════════════════════════════════════╗
# ║                        🚀 Universal Linux Installer 🚀                     ║
# ╠═════════════════════════════════════════════════════════════════════════════╣
# ║  📋 Author  : NotFond                                                       ║
# ║  📌 Version : 2.0                                                           ║
# ║  📅 Date    : September 2024                                                ║
# ║  🔒 LICENSE : MIT                                                           ║
# ║  🌟 Description: Auto-detects Linux distribution and runs appropriate      ║
# ║                  installation script                                       ║
# ║                                                                             ║
# ║      _   ______ ______   __________  __  ___   ______                       ║
# ║     / | / / __ /_  __/  / ____/ __ \/ / / / | / / __ \                      ║
# ║    /  |/ / / / // /    / /_  / / / / / / /  |/ / / / /                      ║
# ║   / /|  / /_/ // /    / __/ / /_/ / /_/ / /|  / /_/ /                       ║
# ║  /_/ |_/\____//_/    /_/    \____/\____/_/ |_/_____/                        ║
# ║                                                                             ║
# ╚═════════════════════════════════════════════════════════════════════════════╝

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/installation.log"

# Initialize logging
exec 1> >(tee -a "${LOG_FILE}")
exec 2> >(tee -a "${LOG_FILE}" >&2)

# Utility functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING] $*${NC}"
}

info() {
    echo -e "${CYAN}[INFO] $*${NC}"
}

# Check for root privileges
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should NOT be run as root!"
        error "Please run without sudo. The script will ask for sudo when needed."
        exit 1
    fi
}

# Print banner
print_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔═════════════════════════════════════════════════════════════════════════════╗"
    echo "║                        🚀 Universal Linux Installer 🚀                     ║"
    echo "╠═════════════════════════════════════════════════════════════════════════════╣"
    echo "║  📋 Author  : NotFond                                                       ║"
    echo "║  📌 Version : 2.0                                                           ║"
    echo "║  📅 Date    : September 2024                                                ║"
    echo "║  🔒 LICENSE : MIT                                                           ║"
    echo "║                                                                             ║"
    echo "║      _   ______ ______   __________  __  ___   ______                       ║"
    echo "║     / | / / __ /_  __/  / ____/ __ \/ / / / | / / __ \                      ║"
    echo "║    /  |/ / / / // /    / /_  / / / / / / /  |/ / / / /                      ║"
    echo "║   / /|  / /_/ // /    / __/ / /_/ / /_/ / /|  / /_/ /                       ║"
    echo "║  /_/ |_/\____//_/    /_/    \____/\____/_/ |_/_____/                        ║"
    echo "║                                                                             ║"
    echo "╚═════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Detect Linux distribution
detect_distro() {
    local distro=""
    
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        distro="$ID"
    elif [[ -f /etc/lsb-release ]]; then
        source /etc/lsb-release
        distro="$DISTRIB_ID"
    elif [[ -f /etc/debian_version ]]; then
        distro="debian"
    elif [[ -f /etc/redhat-release ]]; then
        distro="rhel"
    elif [[ -f /etc/arch-release ]]; then
        distro="arch"
    else
        error "Unable to detect Linux distribution!"
        exit 1
    fi
    
    echo "${distro,,}"  # Convert to lowercase
}

# Get distribution family
get_distro_family() {
    local distro="$1"
    
    case "$distro" in
        ubuntu|debian|mint|elementary|pop|kali|parrot)
            echo "debian"
            ;;
        fedora|centos|rhel|rocky|alma|opensuse*)
            echo "redhat"
            ;;
        arch|manjaro|endeavouros|artix|garuda)
            echo "arch"
            ;;
        gentoo)
            echo "gentoo"
            ;;
        alpine)
            echo "alpine"
            ;;
        void)
            echo "void"
            ;;
        nixos)
            echo "nixos"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Display system information
show_system_info() {
    local distro="$1"
    local family="$2"
    
    info "System Information:"
    echo "  📋 Distribution: $distro"
    echo "  👨‍💻 Family: $family"
    echo "  🖥️  Architecture: $(uname -m)"
    echo "  🐧 Kernel: $(uname -r)"
    echo "  💾 Available RAM: $(free -h | awk 'NR==2{printf "%.1f GB", $7/1024/1024/1024}')"
    echo
}

# Main installation function
main() {
    print_banner
    check_root
    
    log "Starting Universal Linux Installer..."
    
    local distro
    distro=$(detect_distro)
    local family
    family=$(get_distro_family "$distro")
    
    show_system_info "$distro" "$family"
    
    # Check if specific distribution script exists
    local distro_script="${SCRIPT_DIR}/distributions/${family}/install.sh"
    
    if [[ -f "$distro_script" ]]; then
        info "Found installation script for $family family"
        info "Executing: $distro_script"
        
        # Make script executable
        chmod +x "$distro_script"
        
        # Execute the distribution-specific script
        bash "$distro_script" "$distro"
        
        local exit_code=$?
        if [[ $exit_code -eq 0 ]]; then
            log "✅ Installation completed successfully!"
        else
            error "❌ Installation failed with exit code: $exit_code"
            exit $exit_code
        fi
    else
        error "No installation script found for distribution family: $family"
        error "Supported families: debian, redhat, arch, gentoo, alpine, void, nixos"
        error "Expected script location: $distro_script"
        exit 1
    fi
    
    info "Installation log saved to: $LOG_FILE"
}

# Trap for cleanup
trap 'error "Script interrupted!"; exit 1' INT TERM

# Run main function
main "$@"
