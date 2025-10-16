#!/bin/bash

# Void Linux installer
# This script handles XBPS package management and Void-specific configurations

set -euo pipefail

# Get script directory and source common functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/functions.sh"

# Distribution-specific configuration
readonly DISTRO="$1"

# Void-specific package mappings
declare -A DISTRO_PACKAGES=(
    ["base"]="git curl wget zsh neofetch htop tree unzip"
    ["development"]="nodejs npm python3 python3-pip gcc"
    ["media"]="vlc firefox"
    ["build-essential"]="base-devel"
    ["fonts"]="noto-fonts-ttf dejavu-fonts-ttf liberation-fonts-ttf"
)

# Update system
update_system() {
    info "Updating Void Linux packages..."
    
    # Synchronize remote repository data
    sudo xbps-install -S
    show_progress 1 3 "Synchronizing repositories"
    
    # Update all packages
    sudo xbps-install -u
    show_progress 2 3 "Updating packages"
    
    # Remove orphaned packages
    sudo xbps-remove -o
    show_progress 3 3 "Removing orphaned packages"
    
    wait_for_system 5 "Allowing system to stabilize after updates"
    success "System updated successfully"
}

# Setup repositories
setup_repositories() {
    info "Configuring Void Linux repositories..."
    
    # Check current repositories
    local repo_config="/etc/xbps.d"
    
    # Enable multilib repository (for 32-bit support)
    if confirm "Enable multilib repository (32-bit support)?" "y"; then
        if [[ ! -f "$repo_config/10-multilib.conf" ]]; then
            echo "repository=https://alpha.de.repo.voidlinux.org/current/multilib" | sudo tee "$repo_config/10-multilib.conf" > /dev/null
            sudo xbps-install -S
            success "Multilib repository enabled"
        else
            info "Multilib repository already enabled"
        fi
    fi
    
    # Enable nonfree repository
    if confirm "Enable nonfree repository?" "y"; then
        if [[ ! -f "$repo_config/20-nonfree.conf" ]]; then
            echo "repository=https://alpha.de.repo.voidlinux.org/current/nonfree" | sudo tee "$repo_config/20-nonfree.conf" > /dev/null
            sudo xbps-install -S
            success "Nonfree repository enabled"
        else
            info "Nonfree repository already enabled"
        fi
    fi
}

# Install packages using XBPS
install_xbps_packages() {
    local category="$1"
    local packages="${DISTRO_PACKAGES[$category]}"
    
    if [[ -z "$packages" ]]; then
        warn "No packages defined for category: $category"
        return 0
    fi
    
    info "Installing $category packages: $packages"
    
    # Split packages into array for individual handling
    IFS=' ' read -ra pkg_array <<< "$packages"
    local total=${#pkg_array[@]}
    local current=0
    
    for package in "${pkg_array[@]}"; do
        ((current++))
        show_progress $current $total "Installing $package"
        
        if sudo xbps-install -y "$package"; then
            success "✅ $package installed"
        else
            error "❌ Failed to install $package"
        fi
    done
}

# Install applications
install_applications() {
    info "Select applications to install:"
    echo "  1) Visual Studio Code (from nonfree repo)"
    echo "  2) Firefox"
    echo "  3) Chromium"
    echo "  4) VLC Media Player"
    echo "  5) GIMP"
    echo "  6) LibreOffice"
    echo "  7) Thunderbird"
    echo "  8) Discord"
    echo "  9) Spotify (if available)"
    echo "  10) Steam (from multilib)"
    echo "  a) All available applications"
    echo "  s) Skip applications"
    echo
    
    read -r -p "Enter your choice (comma-separated numbers): " choice
    
    local apps=()
    
    case "$choice" in
        s|S) return 0 ;;
        a|A) apps=("firefox" "chromium" "vlc" "gimp" "libreoffice" "thunderbird" "discord" "steam") ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)
                case "$c" in
                    1) apps+=("vscode") ;;
                    2) apps+=("firefox") ;;
                    3) apps+=("chromium") ;;
                    4) apps+=("vlc") ;;
                    5) apps+=("gimp") ;;
                    6) apps+=("libreoffice") ;;
                    7) apps+=("thunderbird") ;;
                    8) apps+=("discord") ;;
                    9) apps+=("spotify") ;;
                    10) apps+=("steam") ;;
                esac
            done
            ;;
    esac
    
    # Install selected applications
    for app in "${apps[@]}"; do
        info "Installing $app..."
        if sudo xbps-install -y "$app"; then
            success "✅ $app installed successfully"
        else
            error "❌ Failed to install $app (may not be available in repos)"
        fi
    done
}

# Setup services (runit)
setup_services() {
    info "Configuring system services (runit)..."
    
    local services=(
        "NetworkManager:Network management"
        "bluetoothd:Bluetooth support"
        "cupsd:Printing support"
        "chronyd:Time synchronization"
        "dbus:D-Bus system"
        "sddm:Display manager (if using)"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service description <<< "$service_info"
        
        if [[ -d "/etc/sv/$service" ]]; then
            if confirm "Enable $description ($service)?" "y"; then
                sudo ln -sf "/etc/sv/$service" /var/service/
                success "✅ $service enabled"
            fi
        else
            # Try to install the service if it doesn't exist
            if confirm "Install and enable $description?" "y"; then
                # Try to find the package that provides this service
                local service_package=""
                case "$service" in
                    "NetworkManager") service_package="NetworkManager" ;;
                    "bluetoothd") service_package="bluez" ;;
                    "cupsd") service_package="cups" ;;
                    "chronyd") service_package="chrony" ;;
                    "dbus") service_package="dbus" ;;
                    "sddm") service_package="sddm" ;;
                esac
                
                if [[ -n "$service_package" ]]; then
                    if sudo xbps-install -y "$service_package"; then
                        sudo ln -sf "/etc/sv/$service" /var/service/
                        success "✅ $service installed and enabled"
                    else
                        warn "Failed to install $service_package"
                    fi
                fi
            fi
        fi
    done
}

# Install multimedia codecs
install_multimedia_codecs() {
    if confirm "Install multimedia codecs?" "y"; then
        info "Installing multimedia packages..."
        
        local multimedia_packages=(
            "gstreamer1-plugins-base"
            "gstreamer1-plugins-good"
            "gstreamer1-plugins-bad"
            "gstreamer1-plugins-ugly"
            "ffmpeg"
            "x264"
            "x265"
            "libdvdcss"
        )
        
        local total=${#multimedia_packages[@]}
        local current=0
        
        for package in "${multimedia_packages[@]}"; do
            ((current++))
            show_progress $current $total "Installing $package"
            sudo xbps-install -y "$package" || warn "Failed to install $package"
        done
        
        success "Multimedia codecs installed"
    fi
}

# Setup fonts
setup_fonts() {
    if confirm "Install additional fonts?" "y"; then
        info "Installing font packages..."
        
        local font_packages=(
            "noto-fonts-ttf"
            "noto-fonts-emoji"
            "dejavu-fonts-ttf"
            "liberation-fonts-ttf"
            "font-awesome"
        )
        
        for font in "${font_packages[@]}"; do
            sudo xbps-install -y "$font"
        done
        
        # Update font cache
        fc-cache -fv
        success "Fonts installed and cache updated"
    fi
}

# Configure shell for Void
configure_void_shell() {
    if command -v zsh >/dev/null 2>&1; then
        info "Configuring ZSH for Void Linux..."
        
        # Change default shell
        if confirm "Set ZSH as default shell?" "y"; then
            sudo chsh -s /bin/zsh "$USER"
            success "Default shell changed to ZSH"
        fi
        
        # Install Oh My Zsh with Void-specific configuration
        if confirm "Install Oh My Zsh?" "y"; then
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                # Secure download and install Oh My Zsh
                local temp_script
                temp_script=$(mktemp)
                local omz_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
                
                info "Downloading Oh My Zsh installer securely..."
                if curl -fsSL --max-time 30 --retry 3 "$omz_url" -o "$temp_script"; then
                    # Basic validation
                    if [[ -s "$temp_script" ]] && grep -q "oh-my-zsh" "$temp_script"; then
                        sh "$temp_script" --unattended
                        success "Oh My Zsh installed securely"
                    else
                        error "Downloaded Oh My Zsh script appears invalid"
                        rm -f "$temp_script"
                        return 1
                    fi
                else
                    error "Failed to download Oh My Zsh installer"
                    rm -f "$temp_script"
                    return 1
                fi
                rm -f "$temp_script"
                
                # Install useful plugins
                git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" 2>/dev/null || true
                git clone https://github.com/zsh-users/zsh-syntax-highlighting "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" 2>/dev/null || true
                
                # Void-specific aliases
                cat >> "$HOME/.zshrc" << 'EOF'

# Void Linux aliases
alias xi='sudo xbps-install'        # Install packages
alias xu='sudo xbps-install -u'     # Update system
alias xr='sudo xbps-remove'         # Remove packages
alias xq='xbps-query'               # Query packages
alias xs='xbps-query -Rs'           # Search packages
alias xo='sudo xbps-remove -o'      # Remove orphans
alias xc='sudo xbps-remove -O'      # Clean cache

# System information
alias sysinfo='neofetch'
alias diskinfo='df -h'
alias meminfo='free -h'

# Service management (runit)
alias svstat='sudo sv status /var/service/*'
alias svup='sudo sv up'
alias svdown='sudo sv down'
alias svrestart='sudo sv restart'
EOF
                
                success "Oh My Zsh installed with Void-specific configuration"
            fi
        fi
    fi
}

# Handle Node.js installation for Void
install_nodejs_void() {
    if confirm "Install Node.js?" "y"; then
        info "Installing Node.js on Void Linux..."
        
        # Install Node.js from Void repos
        sudo xbps-install -y nodejs npm
        
        # Verify installation
        if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
            local node_version npm_version
            node_version=$(node -v)
            npm_version=$(npm -v)
            
            success "Node.js installed: $node_version"
            success "npm installed: $npm_version"
        else
            error "Failed to install Node.js from repos"
            
            # Fallback to NVM
            if confirm "Try installing via NVM instead?" "y"; then
                install_nodejs  # Use the common function
            fi
        fi
    fi
}

# Distribution-specific cleanup
cleanup_distribution_specific() {
    info "Cleaning up Void packages..."
    
    # Remove orphaned packages
    sudo xbps-remove -o
    
    # Clean cache
    sudo xbps-remove -O
    
    # Clean up logs
    if confirm "Clean up system logs?" "y"; then
        sudo rm -rf /var/log/*.log.* 2>/dev/null || true
        
        # Void uses socklog, clean its logs
        if [[ -d /var/log/socklog ]]; then
            sudo find /var/log/socklog -name "*.s" -mtime +7 -delete
        fi
    fi
}

# Configure XBPS
configure_xbps() {
    if confirm "Optimize XBPS configuration?" "y"; then
        info "Configuring XBPS..."
        
        local xbps_conf="/etc/xbps.d/99-local.conf"
        
        # Set parallel download jobs
        if ! grep -q "maxparallel" "$xbps_conf" 2>/dev/null; then
            echo "maxparallel=4" | sudo tee "$xbps_conf" > /dev/null
            success "Parallel downloads enabled"
        fi
        
        # Set cache directory size limit
        if confirm "Set package cache size limit to 1GB?" "y"; then
            echo "cachedir=/var/cache/xbps" | sudo tee -a "$xbps_conf" > /dev/null
            echo "preserve=1073741824" | sudo tee -a "$xbps_conf" > /dev/null  # 1GB in bytes
            success "Cache size limit set"
        fi
    fi
}

# Main installation workflow
main() {
    info "Starting Void Linux installer"
    info "Note: Void uses runit as init system and XBPS as package manager"
    
    # Configure XBPS
    configure_xbps
    
    # Setup repositories
    setup_repositories
    
    # System update
    update_system
    
    # Install base packages
    if confirm "Install base packages?" "y"; then
        install_xbps_packages "base"
    fi
    
    # Install development packages
    if confirm "Install development packages?" "y"; then
        install_xbps_packages "build-essential"
        install_xbps_packages "development"
    fi
    
    # Setup fonts
    setup_fonts
    
    # Install multimedia codecs
    install_multimedia_codecs
    
    # Install applications
    install_applications
    
    # Setup services
    setup_services
    
    # Install Node.js (Void-specific)
    install_nodejs_void
    
    # Setup development environment
    setup_dev_environment
    
    # Configure shell
    configure_void_shell
    
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
