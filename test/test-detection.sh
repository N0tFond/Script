#!/bin/bash

# Test script for distribution detection
# This script tests the distribution detection logic without running the full installer

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

echo -e "${CYAN}🧪 Universal Linux Installer - Distribution Detection Test${NC}"
echo "=================================================================="

# Detect Linux distribution
detect_distro() {
    local distro=""
    
    # Validate and sanitize file contents before parsing
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
        distro="unknown"
    fi
    
    # Validate distro name contains only safe characters
    if [[ -n "$distro" && ! "$distro" =~ ^[a-zA-Z0-9-]+$ ]]; then
        distro="unknown"
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
        fedora|centos|rhel|rocky|alma|nobara|opensuse*)
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

# Main test
main() {
    local distro
    distro=$(detect_distro)
    local family
    family=$(get_distro_family "$distro")
    
    echo -e "${BLUE}System Information:${NC}"
    echo "  📋 Detected Distribution: $distro"
    echo "  👨‍💻 Distribution Family: $family"
    echo "  🖥️  Architecture: $(uname -m)"
    echo "  🐧 Kernel: $(uname -r)"
    echo "  💾 Available RAM: $(free -h | awk 'NR==2{printf "%.1f GB", $7/1024/1024/1024}')"
    echo
    
    # Check if script exists
    local script_path="./distributions/${family}/install.sh"
    
    if [[ -f "$script_path" ]]; then
        echo -e "${GREEN}✅ Installation script found: $script_path${NC}"
        echo -e "${GREEN}✅ Your distribution is supported!${NC}"
        
        echo
        echo -e "${YELLOW}🚀 To run the installer:${NC}"
        echo "   ./install.sh"
        echo
        echo -e "${YELLOW}🔧 To run distribution-specific installer directly:${NC}"
        echo "   $script_path $distro"
    else
        echo -e "${RED}❌ No installation script found for family: $family${NC}"
        echo -e "${RED}❌ Your distribution is not yet supported${NC}"
        echo
        echo -e "${YELLOW}Supported families:${NC}"
        echo "  • debian (Ubuntu, Debian, Mint, etc.)"
        echo "  • arch (Arch, Manjaro, EndeavourOS, etc.)"
        echo "  • redhat (Fedora, CentOS, RHEL, etc.)"
        echo "  • gentoo (Gentoo Linux)"
        echo "  • alpine (Alpine Linux)"
        echo "  • void (Void Linux)"
        echo "  • nixos (NixOS)"
    fi
    
    # Show additional system info if available
    echo
    echo -e "${BLUE}Additional Information:${NC}"
    
    # Package manager detection
    echo -n "  📦 Package Managers: "
    local pkg_managers=()
    command -v apt >/dev/null 2>&1 && pkg_managers+=("apt")
    command -v pacman >/dev/null 2>&1 && pkg_managers+=("pacman")
    command -v dnf >/dev/null 2>&1 && pkg_managers+=("dnf")
    command -v yum >/dev/null 2>&1 && pkg_managers+=("yum")
    command -v emerge >/dev/null 2>&1 && pkg_managers+=("emerge")
    command -v apk >/dev/null 2>&1 && pkg_managers+=("apk")
    command -v xbps-install >/dev/null 2>&1 && pkg_managers+=("xbps")
    command -v nix-env >/dev/null 2>&1 && pkg_managers+=("nix")
    
    if [[ ${#pkg_managers[@]} -gt 0 ]]; then
        echo "${pkg_managers[*]}"
    else
        echo "none detected"
    fi
    
    # Init system detection
    echo -n "  🔧 Init System: "
    if [[ -d /run/systemd/system ]]; then
        echo "systemd"
    elif [[ -f /sbin/openrc ]]; then
        echo "OpenRC"
    elif [[ -d /etc/runit ]]; then
        echo "runit"
    elif [[ -f /etc/inittab ]]; then
        echo "SysV"
    else
        echo "unknown"
    fi
    
    # Desktop environment detection
    echo -n "  🖥️  Desktop Environment: "
    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        echo "$XDG_CURRENT_DESKTOP"
    elif [[ -n "${DESKTOP_SESSION:-}" ]]; then
        echo "$DESKTOP_SESSION"
    else
        echo "unknown/headless"
    fi
}

main "$@"
