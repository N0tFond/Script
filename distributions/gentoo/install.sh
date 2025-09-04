#!/bin/bash

# Gentoo Linux installer
# This script handles Portage package management and Gentoo-specific configurations

set -euo pipefail

# Get script directory and source common functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/functions.sh"

# Distribution-specific configuration
readonly DISTRO="$1"

# Gentoo-specific package mappings
declare -A DISTRO_PACKAGES=(
    ["base"]="dev-vcs/git net-misc/curl net-misc/wget app-shells/zsh app-misc/neofetch sys-process/htop app-text/tree app-arch/unzip"
    ["development"]="net-libs/nodejs dev-lang/python dev-python/pip sys-devel/gcc"
    ["media"]="media-video/vlc www-client/firefox"
    ["build-essential"]="sys-devel/gcc sys-devel/make sys-devel/binutils"
)

# Update system (sync portage tree)
update_system() {
    info "Updating Portage tree and system..."
    
    # Sync Portage tree
    sudo emerge --sync
    show_progress 1 3 "Syncing Portage tree"
    
    # Update system packages
    sudo emerge --ask=n --update --deep --newuse @world
    show_progress 2 3 "Updating system packages"
    
    # Clean up
    sudo emerge --ask=n --depclean
    show_progress 3 3 "Cleaning up unused packages"
    
    wait_for_system 10 "Allowing system to stabilize after updates"
    success "System updated successfully"
}

# Configure Portage
configure_portage() {
    if confirm "Optimize Portage configuration?" "y"; then
        info "Configuring Portage..."
        
        # Get number of CPU cores for parallel compilation
        local cpu_cores
        cpu_cores=$(nproc)
        local make_opts="-j$((cpu_cores + 1))"
        
        # Configure make.conf
        local make_conf="/etc/portage/make.conf"
        
        if confirm "Set MAKEOPTS to $make_opts?" "y"; then
            if ! grep -q "MAKEOPTS" "$make_conf"; then
                echo "MAKEOPTS=\"$make_opts\"" | sudo tee -a "$make_conf" > /dev/null
                success "MAKEOPTS configured"
            fi
        fi
        
        # Enable parallel emerge
        if confirm "Enable parallel emerge?" "y"; then
            if ! grep -q "EMERGE_DEFAULT_OPTS" "$make_conf"; then
                echo "EMERGE_DEFAULT_OPTS=\"--jobs=4 --load-average=$cpu_cores\"" | sudo tee -a "$make_conf" > /dev/null
                success "Parallel emerge enabled"
            fi
        fi
        
        # Configure USE flags
        if confirm "Configure common USE flags?" "y"; then
            local common_use="X gtk gtk3 qt5 alsa pulseaudio networkmanager wifi bluetooth usb"
            if ! grep -q "USE=" "$make_conf"; then
                echo "USE=\"$common_use\"" | sudo tee -a "$make_conf" > /dev/null
                success "Common USE flags configured"
            fi
        fi
    fi
}

# Install packages using Portage
install_portage_packages() {
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
        
        if sudo emerge --ask=n "$package"; then
            success "✅ $package installed"
        else
            error "❌ Failed to install $package"
        fi
    done
}

# Setup layman for overlays
setup_layman() {
    if confirm "Install and configure Layman for overlays?" "y"; then
        info "Installing Layman..."
        sudo emerge --ask=n app-portage/layman
        
        # Initialize layman
        sudo layman -L
        
        # Add popular overlays
        local overlays=("guru:Community overlay" "gentoo-zh:Chinese overlay")
        for overlay_info in "${overlays[@]}"; do
            IFS=':' read -r overlay description <<< "$overlay_info"
            if confirm "Add $description ($overlay)?" "n"; then
                sudo layman -a "$overlay"
                success "✅ $overlay overlay added"
            fi
        done
        
        success "Layman configured"
    fi
}

# Configure services
configure_services() {
    info "Configuring system services..."
    
    # OpenRC services
    local services=(
        "NetworkManager:Network management"
        "bluetooth:Bluetooth support"
        "cupsd:Printing support"
        "chronyd:Time synchronization"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service description <<< "$service_info"
        
        if [[ -f "/etc/init.d/$service" ]]; then
            if confirm "Enable $description ($service)?" "y"; then
                sudo rc-update add "$service" default
                sudo rc-service "$service" start
                success "✅ $service enabled and started"
            fi
        fi
    done
}

# Install multimedia support
install_multimedia() {
    if confirm "Install multimedia support?" "y"; then
        info "Installing multimedia packages..."
        
        local multimedia_packages=(
            "media-libs/gstreamer"
            "media-libs/gst-plugins-base"
            "media-libs/gst-plugins-good"
            "media-libs/gst-plugins-bad"
            "media-libs/gst-plugins-ugly"
            "media-video/ffmpeg"
        )
        
        local total=${#multimedia_packages[@]}
        local current=0
        
        for package in "${multimedia_packages[@]}"; do
            ((current++))
            show_progress $current $total "Installing $package"
            sudo emerge --ask=n "$package" || warn "Failed to install $package"
        done
        
        success "Multimedia support installed"
    fi
}

# Distribution-specific cleanup
cleanup_distribution_specific() {
    info "Cleaning up Portage..."
    
    # Remove unused packages
    sudo emerge --ask=n --depclean
    
    # Clean distfiles
    if confirm "Clean distfiles directory?" "y"; then
        sudo eclean-dist --deep
    fi
    
    # Clean binary packages
    if confirm "Clean binary packages?" "y"; then
        sudo eclean-pkg --deep
    fi
    
    # Rebuild reverse dependencies if needed
    sudo revdep-rebuild
}

# Configure kernel (if needed)
configure_kernel() {
    if confirm "Configure and rebuild kernel?" "n"; then
        warn "Kernel configuration requires advanced knowledge!"
        if confirm "Are you sure you want to continue?" "n"; then
            info "Configuring kernel..."
            
            # This is a simplified kernel rebuild
            cd /usr/src/linux
            sudo make menuconfig
            sudo make -j"$(nproc)" && sudo make modules_install && sudo make install
            
            # Update bootloader
            if command -v grub-mkconfig >/dev/null 2>&1; then
                sudo grub-mkconfig -o /boot/grub/grub.cfg
            fi
            
            success "Kernel rebuilt. Reboot recommended."
        fi
    fi
}

# Main installation workflow
main() {
    info "Starting Gentoo Linux installer"
    warn "Note: Gentoo compilation can take significant time!"
    
    # Configure Portage first
    configure_portage
    
    # Update system
    update_system
    
    # Setup Layman
    setup_layman
    
    # Install base packages
    if confirm "Install base packages?" "y"; then
        install_portage_packages "base"
    fi
    
    # Install development packages
    if confirm "Install development packages?" "y"; then
        install_portage_packages "development"
    fi
    
    # Install multimedia support
    install_multimedia
    
    # Configure services
    configure_services
    
    # Install Node.js (this may take a while to compile)
    if confirm "Install Node.js? (Warning: This will compile from source and take time)" "y"; then
        sudo emerge --ask=n net-libs/nodejs
    fi
    
    # Setup development environment
    setup_dev_environment
    
    # Configure kernel
    configure_kernel
    
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
