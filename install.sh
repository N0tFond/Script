#!/bin/bash

# Display header in terminal at script start
echo -e "${PURPLE:-\033[0;35m}"
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                        🚀 Universal Linux Installer 🚀                      ║"
echo "╠═════════════════════════════════════════════════════════════════════════════╣"
echo "║  📋 Author  : NotFond                                                       ║"
echo "║  📌 Version : 2.0                                                           ║"
echo "║  📅 Date    : September 2024                                                ║"
echo "║  🔒 LICENSE : MIT                                                           ║"
echo "║  🌟 Description: Auto-detects Linux distribution and runs appropriate       ║"
echo "║                  installation script                                        ║"
echo "║                                                                             ║"
echo "║      _   ______ ______   __________  __  ___   ______                       ║"
echo "║     / | / / __ /_  __/  / ____/ __ \/ / / / | / / __ \                      ║"
echo "║    /  |/ / / / // /    / /_  / / / / / / /  |/ / / / /                      ║"
echo "║   / /|  / /_/ // /    / __/ / /_/ / /_/ / /|  / /_/ /                       ║"
echo "║  /_/ |_/\____//_/    /_/    \____/\____/_/ |_/_____/                        ║"
echo "║                                                                             ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC:-\033[0m}"
echo

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
readonly MAX_LOG_SIZE=10485760  # 10MB
readonly MAX_LOG_FILES=5

# Setup logging with rotation
setup_logging() {
    # Create logs directory if it doesn't exist
    local log_dir
    log_dir=$(dirname "$LOG_FILE")
    mkdir -p "$log_dir"
    
    # Rotate logs if current log is too large
    if [[ -f "$LOG_FILE" ]]; then
        local log_size
        log_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null)
        
        if [[ "$log_size" -gt "$MAX_LOG_SIZE" ]]; then
            # Rotate existing logs
            for ((i=MAX_LOG_FILES-1; i>=1; i--)); do
                if [[ -f "${LOG_FILE}.${i}" ]]; then
                    mv "${LOG_FILE}.${i}" "${LOG_FILE}.$((i+1))"
                fi
            done
            
            # Move current log to .1
            mv "$LOG_FILE" "${LOG_FILE}.1"
        fi
    fi
    
    # Initialize new log file
    {
        echo "=== Installation Log Started: $(date) ==="
        echo "Script: $0"
        echo "User: $(whoami)"
        echo "Working Directory: $(pwd)"
        echo "=========================================="
    } > "$LOG_FILE"
}

# Initialize logging
setup_logging
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

# Validate execution environment
validate_environment() {
    local errors=0
    
    # Check if running in a container (not recommended)
    if [[ -f /.dockerenv ]] || grep -q 'container=' /proc/1/environ 2>/dev/null; then
        warn "Running in a container environment. Some features may not work correctly."
    fi
    
    # Check available disk space (minimum 2GB)
    local available_space
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ "$available_space" -lt 2097152 ]]; then  # 2GB in KB
        error "Insufficient disk space. At least 2GB free space required."
        ((errors++))
    fi
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        error "No internet connectivity detected. Internet access is required."
        ((errors++))
    fi
    
    # Check required commands
    local required_commands=("curl" "wget" "sudo" "bash")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            error "Required command not found: $cmd"
            ((errors++))
        fi
    done
    
    # Check sudo access
    if ! sudo -n true 2>/dev/null; then
        warn "Script requires sudo access. You may be prompted for your password."
    fi
    
    if [[ $errors -gt 0 ]]; then
        error "Environment validation failed with $errors errors"
        exit 1
    fi
    
    success "Environment validation passed"
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
    
    # Validate and sanitize file contents before sourcing
    if [[ -f /etc/os-release ]]; then
        # Parse os-release safely without sourcing
        distro=$(grep -oP '^ID=\K.*' /etc/os-release | tr -d '"' | head -n1)
    elif [[ -f /etc/lsb-release ]]; then
        # Parse lsb-release safely without sourcing
        distro=$(grep -oP '^DISTRIB_ID=\K.*' /etc/lsb-release | tr -d '"' | head -n1)
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
    
    # Validate distro name contains only alphanumeric characters and hyphens
    if [[ ! "$distro" =~ ^[a-zA-Z0-9-]+$ ]]; then
        error "Invalid distribution name detected: $distro"
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
    validate_environment
    
    log "Starting Universal Linux Installer..."
    
    local distro
    distro=$(detect_distro)
    local family
    family=$(get_distro_family "$distro")
    
    show_system_info "$distro" "$family"
    
    # Validate family name before using in path
    if [[ ! "$family" =~ ^[a-zA-Z0-9-]+$ ]]; then
        error "Invalid distribution family: $family"
        exit 1
    fi
    
    # Check if specific distribution script exists
    local distro_script="${SCRIPT_DIR}/distributions/${family}/install.sh"
    
    # Validate script path is within expected directory
    local real_script_path
    real_script_path=$(realpath -e "$distro_script" 2>/dev/null)
    local real_script_dir
    real_script_dir=$(realpath -e "${SCRIPT_DIR}/distributions")
    
    if [[ -f "$distro_script" && "$real_script_path" == "$real_script_dir"/* ]]; then
        info "Found installation script for $family family"
        info "Executing: $distro_script"
        
        # Make script executable
        chmod +x "$distro_script"
        
        # Execute the distribution-specific script with validation
        if bash "$distro_script" "$distro"; then
            log "✅ Installation completed successfully!"
        else
            local exit_code=$?
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
