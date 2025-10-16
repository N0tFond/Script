#!/bin/bash

# Alpine Linux installer
# This script handles APK package management and Alpine-specific configurations

set -euo pipefail

# Get script directory and source common functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/functions.sh"

# Distribution-specific configuration
readonly DISTRO="$1"

# Alpine-specific package mappings
declare -A DISTRO_PACKAGES=(
    ["base"]="git curl wget zsh neofetch htop tree unzip build-base"
    ["development"]="nodejs npm python3 py3-pip gcc musl-dev"
    ["media"]="vlc firefox"
    ["glibc"]="gcompat"  # For glibc compatibility
)

# Update system
update_system() {
    info "Updating Alpine Linux packages..."
    
    # Update package index
    sudo apk update
    show_progress 1 3 "Updating package index"
    
    # Upgrade all packages
    sudo apk upgrade
    show_progress 2 3 "Upgrading packages"
    
    # Clean cache
    sudo apk cache clean
    show_progress 3 3 "Cleaning package cache"
    
    wait_for_system 5 "Allowing system to stabilize after updates"
    success "System updated successfully"
}

# Setup repositories
setup_repositories() {
    info "Configuring Alpine repositories..."
    
    local repos_file="/etc/apk/repositories"
    
    # Enable community repository
    if ! grep -q "community" "$repos_file"; then
        if confirm "Enable community repository?" "y"; then
            local alpine_version
            alpine_version=$(cat /etc/alpine-release | cut -d'.' -f1,2)
            echo "https://dl-cdn.alpinelinux.org/alpine/v${alpine_version}/community" | sudo tee -a "$repos_file" > /dev/null
            sudo apk update
            success "Community repository enabled"
        fi
    fi
    
    # Enable edge repositories for latest packages
    if confirm "Enable edge repositories? (Warning: May be unstable)" "n"; then
        echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" | sudo tee -a "$repos_file" > /dev/null
        echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" | sudo tee -a "$repos_file" > /dev/null
        echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing" | sudo tee -a "$repos_file" > /dev/null
        sudo apk update
        success "Edge repositories enabled"
    fi
}

# Install packages using APK
install_apk_packages() {
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
        
        if sudo apk add "$package"; then
            success "✅ $package installed"
        else
            error "❌ Failed to install $package"
        fi
    done
}

# Setup glibc compatibility (for non-musl applications)
setup_glibc_compatibility() {
    if confirm "Install glibc compatibility layer?" "y"; then
        info "Installing glibc compatibility..."
        
        # Install gcompat for glibc compatibility
        sudo apk add gcompat
        
        # Some applications might need these
        sudo apk add libc6-compat
        
        success "glibc compatibility layer installed"
        warn "Some applications may still not work due to musl vs glibc differences"
    fi
}

# Install development tools
install_dev_tools() {
    if confirm "Install development tools?" "y"; then
        info "Installing development packages..."
        
        # Essential development packages for Alpine
        local dev_packages=(
            "build-base"     # Essential build tools
            "cmake"          # CMake build system
            "pkgconfig"      # Package config
            "linux-headers"  # Linux kernel headers
        )
        
        for package in "${dev_packages[@]}"; do
            sudo apk add "$package"
        done
        
        success "Development tools installed"
    fi
}

# Install applications
install_applications() {
    info "Select applications to install:"
    echo "  1) Firefox"
    echo "  2) VLC Media Player"
    echo "  3) GIMP"
    echo "  4) LibreOffice (may not be available)"
    echo "  5) Chromium"
    echo "  6) Transmission (BitTorrent)"
    echo "  7) Thunderbird"
    echo "  a) All available applications"
    echo "  s) Skip applications"
    echo
    
    read -r -p "Enter your choice (comma-separated numbers): " choice
    
    local apps=()
    
    case "$choice" in
        s|S) return 0 ;;
        a|A) apps=("firefox" "vlc" "gimp" "chromium" "transmission" "thunderbird") ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)
                case "$c" in
                    1) apps+=("firefox") ;;
                    2) apps+=("vlc") ;;
                    3) apps+=("gimp") ;;
                    4) apps+=("libreoffice") ;;
                    5) apps+=("chromium") ;;
                    6) apps+=("transmission") ;;
                    7) apps+=("thunderbird") ;;
                esac
            done
            ;;
    esac
    
    # Install selected applications
    for app in "${apps[@]}"; do
        info "Installing $app..."
        if sudo apk add "$app"; then
            success "✅ $app installed successfully"
        else
            error "❌ Failed to install $app (may not be available in Alpine repos)"
        fi
    done
}

# Setup services (OpenRC)
setup_services() {
    info "Configuring system services..."
    
    local services=(
        "networkmanager:Network management"
        "bluetooth:Bluetooth support"
        "cups:Printing support"
        "chronyd:Time synchronization"
        "dbus:D-Bus system"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service description <<< "$service_info"
        
        if [[ -f "/etc/init.d/$service" ]]; then
            if confirm "Enable $description ($service)?" "y"; then
                sudo rc-update add "$service"
                sudo service "$service" start
                success "✅ $service enabled and started"
            fi
        else
            # Try to install the service if it doesn't exist
            if confirm "Install and enable $description?" "y"; then
                if sudo apk add "$service"; then
                    sudo rc-update add "$service"
                    sudo service "$service" start
                    success "✅ $service installed, enabled and started"
                else
                    warn "Failed to install $service"
                fi
            fi
        fi
    done
}

# Configure shell for Alpine
configure_alpine_shell() {
    if command -v zsh >/dev/null 2>&1; then
        info "Configuring ZSH for Alpine..."
        
        # Change default shell
        if confirm "Set ZSH as default shell?" "y"; then
            sudo chsh -s /bin/zsh "$USER"
            success "Default shell changed to ZSH"
        fi
        
        # Install Oh My Zsh with Alpine-specific configuration
        if confirm "Install Oh My Zsh?" "y"; then
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                # Install curl if not present
                command -v curl >/dev/null 2>&1 || sudo apk add curl
                
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
                
                # Alpine-specific aliases
                cat >> "$HOME/.zshrc" << 'EOF'

# Alpine Linux aliases
alias apkupdate='sudo apk update'
alias apkupgrade='sudo apk upgrade'
alias apksearch='apk search'
alias apkinstall='sudo apk add'
alias apkremove='sudo apk del'
alias apkinfo='apk info'

# System information
alias sysinfo='neofetch'
alias diskinfo='df -h'
alias meminfo='free -h'
EOF
                
                success "Oh My Zsh installed with Alpine-specific configuration"
            fi
        fi
    fi
}

# Setup lightweight alternatives
setup_lightweight_alternatives() {
    info "Alpine Linux is designed to be lightweight. Consider these alternatives:"
    
    local alternatives=(
        "busybox:Use BusyBox utilities (already default in Alpine)"
        "musl:Use musl libc (already default in Alpine)"
        "openrc:Use OpenRC init system (already default in Alpine)"
    )
    
    if confirm "Install additional lightweight tools?" "y"; then
        local tools=("htop" "ncdu" "ranger" "tmux" "vim")
        
        for tool in "${tools[@]}"; do
            if confirm "Install $tool?" "y"; then
                sudo apk add "$tool"
            fi
        done
    fi
}

# Distribution-specific cleanup
cleanup_distribution_specific() {
    info "Cleaning up Alpine packages..."
    
    # Clean package cache
    sudo apk cache clean
    
    # Remove orphaned packages (Alpine doesn't have autoremove like other distros)
    info "Note: Alpine doesn't have automatic orphan removal like other distributions"
    
    # Clean up logs
    if confirm "Clean up system logs?" "y"; then
        sudo rm -rf /var/log/*.log.* 2>/dev/null || true
        sudo truncate -s 0 /var/log/*.log 2>/dev/null || true
    fi
}

# Handle Node.js installation for Alpine
install_nodejs_alpine() {
    if confirm "Install Node.js?" "y"; then
        info "Installing Node.js on Alpine..."
        
        # Install Node.js from Alpine repos (usually more stable than NVM on Alpine)
        sudo apk add nodejs npm
        
        # Verify installation
        if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
            local node_version npm_version
            node_version=$(node -v)
            npm_version=$(npm -v)
            
            success "Node.js installed: $node_version"
            success "npm installed: $npm_version"
        else
            error "Failed to install Node.js"
            
            # Fallback to NVM if Alpine packages failed
            if confirm "Try installing via NVM instead?" "y"; then
                install_nodejs  # Use the common function
            fi
        fi
    fi
}

# Main installation workflow
main() {
    info "Starting Alpine Linux installer"
    info "Note: Alpine uses musl libc instead of glibc"
    
    # Setup repositories
    setup_repositories
    
    # System update
    update_system
    
    # Install base packages
    if confirm "Install base packages?" "y"; then
        install_apk_packages "base"
    fi
    
    # Setup glibc compatibility
    setup_glibc_compatibility
    
    # Install development tools
    install_dev_tools
    
    # Install applications
    install_applications
    
    # Setup services
    setup_services
    
    # Install Node.js (Alpine-specific)
    install_nodejs_alpine
    
    # Setup development environment
    setup_dev_environment
    
    # Configure shell
    configure_alpine_shell
    
    # Setup lightweight alternatives
    setup_lightweight_alternatives
    
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
