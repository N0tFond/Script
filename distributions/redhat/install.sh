#!/bin/bash

# Red Hat-based distributions installer (Fedora, CentOS, RHEL, Rocky, AlmaLinux, etc.)
# This script handles DNF/YUM package management and RPM repositories

set -euo pipefail

# Get script directory and source common functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/functions.sh"

# Distribution-specific configuration
readonly DISTRO="$1"

# Detect package manager
detect_package_manager() {
    if command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    else
        error "No supported package manager found (dnf/yum)"
        exit 1
    fi
}

readonly PKG_MANAGER=$(detect_package_manager)

# Distribution-specific package mappings
declare -A DISTRO_PACKAGES=(
    ["base"]="git curl wget zsh neofetch htop tree unzip"
    ["development"]="nodejs npm python3 python3-pip gcc gcc-c++ make"
    ["media"]="vlc firefox"
    ["build-essential"]="@development-tools"
    ["fonts"]="google-noto-fonts google-noto-emoji-fonts"
)

# RPM Fusion packages (multimedia codecs)
declare -A RPMFUSION_PACKAGES=(
    ["free"]="https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-\$(rpm -E %fedora).noarch.rpm"
    ["nonfree"]="https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-\$(rpm -E %fedora).noarch.rpm"
)

# Flatpak applications
declare -A FLATPAK_APPS=(
    ["vscode"]="com.visualstudio.code"
    ["discord"]="com.discordapp.Discord"
    ["spotify"]="com.spotify.Client"
    ["steam"]="com.valvesoftware.Steam"
    ["chrome"]="com.google.Chrome"
)

# Update system
update_system() {
    info "Updating system packages..."
    
    # Refresh repository metadata
    sudo "$PKG_MANAGER" clean all
    show_progress 1 3 "Cleaning package cache"
    
    # Update all packages
    sudo "$PKG_MANAGER" upgrade -y
    show_progress 2 3 "Upgrading packages"
    
    # Remove unnecessary packages
    sudo "$PKG_MANAGER" autoremove -y
    show_progress 3 3 "Removing unnecessary packages"
    
    wait_for_system 5 "Allowing system to stabilize after updates"
    success "System updated successfully"
}

# Setup additional repositories
setup_repositories() {
    info "Setting up additional repositories..."
    
    # Enable EPEL repository (for RHEL/CentOS)
    if [[ "$DISTRO" =~ ^(rhel|centos|rocky|alma) ]]; then
        if confirm "Enable EPEL repository?" "y"; then
            sudo "$PKG_MANAGER" install -y epel-release
            success "EPEL repository enabled"
        fi
    fi
    
    # Setup RPM Fusion (for Fedora)
    if [[ "$DISTRO" == "fedora" ]]; then
        if confirm "Enable RPM Fusion repositories?" "y"; then
            info "Installing RPM Fusion repositories..."
            
            # Install RPM Fusion free repository
            sudo "$PKG_MANAGER" install -y \
                "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
            
            # Install RPM Fusion non-free repository  
            sudo "$PKG_MANAGER" install -y \
                "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
            
            success "RPM Fusion repositories installed"
        fi
    fi
    
    # Flathub repository
    if confirm "Enable Flathub repository?" "y"; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        success "Flathub repository added"
    fi
    
    # Visual Studio Code repository
    if confirm "Add Visual Studio Code repository?" "y"; then
        info "Adding Visual Studio Code repository..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        success "Visual Studio Code repository added"
    fi
    
    # Google Chrome repository
    if confirm "Add Google Chrome repository?" "y"; then
        info "Adding Google Chrome repository..."
        sudo sh -c 'echo -e "[google-chrome]\nname=google-chrome\nbaseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64\nenabled=1\ngpgcheck=1\ngpgkey=https://dl.google.com/linux/linux_signing_key.pub" > /etc/yum.repos.d/google-chrome.repo'
        success "Google Chrome repository added"
    fi
}

# Install packages using DNF/YUM
install_packages() {
    local category="$1"
    local packages="${DISTRO_PACKAGES[$category]}"
    
    if [[ -z "$packages" ]]; then
        warn "No packages defined for category: $category"
        return 0
    fi
    
    info "Installing $category packages: $packages"
    
    # Handle group packages (starting with @)
    if [[ "$packages" =~ ^@ ]]; then
        sudo "$PKG_MANAGER" groupinstall -y "$packages"
    else
        # Split packages into array for individual handling
        IFS=' ' read -ra pkg_array <<< "$packages"
        local total=${#pkg_array[@]}
        local current=0
        
        for package in "${pkg_array[@]}"; do
            ((current++))
            show_progress $current $total "Installing $package"
            
            if sudo "$PKG_MANAGER" install -y "$package"; then
                success "✅ $package installed"
            else
                error "❌ Failed to install $package"
            fi
        done
    fi
}

# Install applications
install_applications() {
    info "Select applications to install:"
    echo "  1) Visual Studio Code"
    echo "  2) Google Chrome"
    echo "  3) Firefox"
    echo "  4) VLC Media Player"
    echo "  5) GIMP"
    echo "  6) LibreOffice"
    echo "  7) Thunderbird"
    echo "  8) Discord (Flatpak)"
    echo "  9) Spotify (Flatpak)"
    echo "  10) Steam (Flatpak)"
    echo "  a) All applications"
    echo "  s) Skip applications"
    echo
    
    read -r -p "Enter your choice (comma-separated numbers): " choice
    
    local apps=()
    local flatpak_apps=()
    
    case "$choice" in
        s|S) return 0 ;;
        a|A) 
            apps=("code" "google-chrome-stable" "firefox" "vlc" "gimp" "libreoffice" "thunderbird")
            flatpak_apps=("com.discordapp.Discord" "com.spotify.Client" "com.valvesoftware.Steam")
            ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)
                case "$c" in
                    1) apps+=("code") ;;
                    2) apps+=("google-chrome-stable") ;;
                    3) apps+=("firefox") ;;
                    4) apps+=("vlc") ;;
                    5) apps+=("gimp") ;;
                    6) apps+=("libreoffice") ;;
                    7) apps+=("thunderbird") ;;
                    8) flatpak_apps+=("com.discordapp.Discord") ;;
                    9) flatpak_apps+=("com.spotify.Client") ;;
                    10) flatpak_apps+=("com.valvesoftware.Steam") ;;
                esac
            done
            ;;
    esac
    
    # Install native packages
    for app in "${apps[@]}"; do
        info "Installing $app..."
        if sudo "$PKG_MANAGER" install -y "$app"; then
            success "✅ $app installed successfully"
        else
            error "❌ Failed to install $app"
        fi
    done
    
    # Install Flatpak applications
    if command -v flatpak >/dev/null 2>&1; then
        for app in "${flatpak_apps[@]}"; do
            info "Installing Flatpak app: $app"
            flatpak install -y flathub "$app"
        done
    elif [[ ${#flatpak_apps[@]} -gt 0 ]]; then
        warn "Flatpak not available, skipping Flatpak applications"
    fi
}

# Setup multimedia codecs
install_multimedia_codecs() {
    if [[ "$DISTRO" == "fedora" ]] && confirm "Install multimedia codecs from RPM Fusion?" "y"; then
        info "Installing multimedia codecs..."
        
        # Install multimedia packages
        local multimedia_packages=(
            "gstreamer1-plugins-base"
            "gstreamer1-plugins-good"
            "gstreamer1-plugins-bad-free"
            "gstreamer1-plugins-good-extras"
            "gstreamer1-plugins-bad-freeworld"
            "gstreamer1-plugins-ugly"
            "gstreamer1-plugin-openh264"
            "mozilla-openh264"
            "ffmpeg"
        )
        
        local total=${#multimedia_packages[@]}
        local current=0
        
        for package in "${multimedia_packages[@]}"; do
            ((current++))
            show_progress $current $total "Installing $package"
            sudo "$PKG_MANAGER" install -y "$package" || warn "Failed to install $package"
        done
        
        success "Multimedia codecs installed"
    fi
}

# Setup Flatpak
setup_flatpak() {
    if confirm "Install and configure Flatpak?" "y"; then
        info "Installing Flatpak..."
        sudo "$PKG_MANAGER" install -y flatpak
        
        # Add Flathub repository
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        success "Flatpak installed and configured"
        
        # Install Flatpak packages
        install_flatpak_packages
    fi
}

# Enable system services
enable_services() {
    info "Configuring system services..."
    
    local services=(
        "NetworkManager:Network management"
        "firewalld:Firewall"
        "bluetooth:Bluetooth support"
        "cups:Printing support"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service description <<< "$service_info"
        
        if systemctl list-unit-files | grep -q "^$service"; then
            if confirm "Enable $description ($service)?" "y"; then
                sudo systemctl enable --now "$service"
                success "✅ $service enabled and started"
            fi
        fi
    done
}

# Configure firewall
configure_firewall() {
    if systemctl is-active firewalld >/dev/null 2>&1; then
        if confirm "Configure firewall rules?" "y"; then
            info "Configuring firewall..."
            
            # Common services to potentially open
            local services=("ssh:SSH access" "http:Web server" "https:Secure web server")
            
            for service_info in "${services[@]}"; do
                IFS=':' read -r service description <<< "$service_info"
                if confirm "Allow $description?" "n"; then
                    sudo firewall-cmd --permanent --add-service="$service"
                    success "✅ $service allowed through firewall"
                fi
            done
            
            # Reload firewall
            sudo firewall-cmd --reload
            success "Firewall configuration reloaded"
        fi
    fi
}

# Distribution-specific cleanup
cleanup_distribution_specific() {
    info "Cleaning up package cache and unnecessary packages..."
    
    # Clean package cache
    sudo "$PKG_MANAGER" clean all
    
    # Remove unnecessary packages
    sudo "$PKG_MANAGER" autoremove -y
    
    # Clean up systemd journal logs
    if confirm "Clean up system logs?" "y"; then
        sudo journalctl --vacuum-time=7d
        sudo journalctl --vacuum-size=100M
    fi
    
    # Clean up old kernels (keep latest + 1 previous)
    if [[ "$DISTRO" == "fedora" ]] && confirm "Clean up old kernels?" "y"; then
        sudo dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q)
    fi
}

# Configure SELinux
configure_selinux() {
    if command -v getenforce >/dev/null 2>&1; then
        local selinux_status
        selinux_status=$(getenforce)
        
        info "Current SELinux status: $selinux_status"
        
        if [[ "$selinux_status" == "Enforcing" ]]; then
            if confirm "Keep SELinux in enforcing mode? (recommended for security)" "y"; then
                info "SELinux will remain in enforcing mode"
                # Install useful SELinux tools
                sudo "$PKG_MANAGER" install -y policycoreutils-python-utils setroubleshoot-server
                success "SELinux tools installed"
            else
                warn "Disabling SELinux is not recommended for security reasons"
                if confirm "Are you sure you want to disable SELinux?" "n"; then
                    sudo setenforce 0
                    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
                    warn "SELinux disabled. Reboot required to take full effect."
                fi
            fi
        fi
    fi
}

# Main installation workflow
main() {
    info "Starting Red Hat-based distribution installer for: $DISTRO"
    info "Package manager: $PKG_MANAGER"
    
    # System update
    update_system
    
    # Setup repositories
    setup_repositories
    
    # Install base packages
    if confirm "Install base packages?" "y"; then
        install_packages "base"
    fi
    
    # Install development tools
    if confirm "Install development tools?" "y"; then
        install_packages "build-essential"
        install_packages "development"
    fi
    
    # Install multimedia codecs
    install_multimedia_codecs
    
    # Install applications
    install_applications
    
    # Setup Flatpak
    setup_flatpak
    
    # Enable services
    enable_services
    
    # Configure firewall
    configure_firewall
    
    # Configure SELinux
    configure_selinux
    
    # Install Node.js
    install_nodejs
    
    # Setup development environment
    setup_dev_environment
    
    # Configure shell
    configure_shell
    
    # System cleanup
    cleanup_system
    
    # Final configuration
    finalize_installation
}

# Run main function with error handling
if ! main; then
    error "Installation failed!"
    exit 1
fi
