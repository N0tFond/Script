#!/bin/bash

# Arch-based distributions installer (Arch, Manjaro, EndeavourOS, ArcoLinux, etc.)
# This script handles Pacman and AUR package management

set -euo pipefail

# Get script directory and source common functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/functions.sh"

# Distribution-specific configuration
readonly DISTRO="$1"

# Distribution-specific package mappings
declare -A DISTRO_PACKAGES=(
    ["base"]="git curl wget zsh neofetch htop tree unzip base-devel"
    ["development"]="nodejs npm python python-pip github-cli"
    ["media"]="vlc firefox"
    ["fonts"]="ttf-dejavu ttf-liberation noto-fonts"
    ["multimedia"]="gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly"
)

# AUR packages (require AUR helper)
declare -A AUR_PACKAGES=(
    ["vscode"]="visual-studio-code-bin"
    ["spotify"]="spotify"
    ["discord"]="discord"
    ["chrome"]="google-chrome"
    ["postman"]="postman-bin"
    ["steam"]="steam"
)

# Check if AUR helper is available
check_aur_helper() {
    local aur_helpers=("yay" "paru" "pikaur" "trizen")
    local available_helper=""
    
    for helper in "${aur_helpers[@]}"; do
        if command -v "$helper" >/dev/null 2>&1; then
            available_helper="$helper"
            break
        fi
    done
    
    if [[ -n "$available_helper" ]]; then
        echo "$available_helper"
        return 0
    else
        return 1
    fi
}

# Install AUR helper (yay)
install_aur_helper() {
    if ! check_aur_helper >/dev/null; then
        if confirm "Install yay AUR helper?" "y"; then
            info "Installing yay AUR helper..."
            
            # Install dependencies
            sudo pacman -S --noconfirm --needed git base-devel
            
            # Create temporary directory
            local temp_dir
            temp_dir=$(mktemp -d)
            cd "$temp_dir"
            
            # Clone and install yay
            git clone https://aur.archlinux.org/yay.git
            cd yay
            makepkg -si --noconfirm
            
            # Cleanup
            cd /
            rm -rf "$temp_dir"
            
            success "yay AUR helper installed successfully"
        else
            warn "No AUR helper available. Some packages may not be installable."
            return 1
        fi
    else
        success "AUR helper already available: $(check_aur_helper)"
    fi
}

# Update system
update_system() {
    info "Updating system packages..."
    
    # Update pacman keyring first
    sudo pacman -Sy --noconfirm archlinux-keyring
    show_progress 1 4 "Updating keyring"
    
    # Full system update
    sudo pacman -Syu --noconfirm
    show_progress 2 4 "Updating packages"
    
    # Update AUR packages if AUR helper is available
    local aur_helper
    if aur_helper=$(check_aur_helper); then
        "$aur_helper" -Syu --noconfirm
        show_progress 3 4 "Updating AUR packages"
    fi
    
    show_progress 4 4 "System update complete"
    
    wait_for_system 5 "Allowing system to stabilize after updates"
    success "System updated successfully"
}

# Install packages using Pacman
install_pacman_packages() {
    local category="$1"
    local packages="${DISTRO_PACKAGES[$category]}"
    
    if [[ -z "$packages" ]]; then
        warn "No packages defined for category: $category"
        return 0
    fi
    
    info "Installing $category packages: $packages"
    
    # Install packages with progress tracking
    IFS=' ' read -ra pkg_array <<< "$packages"
    local total=${#pkg_array[@]}
    local current=0
    local failed_packages=()
    
    for package in "${pkg_array[@]}"; do
        ((current++))
        show_progress $current $total "Installing $package"
        
        if sudo pacman -S --noconfirm --needed "$package"; then
            success "✅ $package installed"
        else
            error "❌ Failed to install $package"
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        warn "Failed to install: ${failed_packages[*]}"
    fi
}

# Install AUR packages
install_aur_packages() {
    local aur_helper
    if ! aur_helper=$(check_aur_helper); then
        warn "No AUR helper available. Skipping AUR packages."
        return 1
    fi
    
    info "Available AUR packages:"
    local i=1
    local package_list=()
    for name in "${!AUR_PACKAGES[@]}"; do
        package_list+=("$name")
        echo "  $i) $name (${AUR_PACKAGES[$name]})"
        ((i++))
    done
    
    echo "  a) All packages"
    echo "  s) Skip AUR packages"
    echo
    
    read -r -p "Enter your choice (comma-separated numbers): " choice
    
    case "$choice" in
        s|S) return 0 ;;
        a|A)
            for pkg in "${AUR_PACKAGES[@]}"; do
                info "Installing AUR package: $pkg"
                "$aur_helper" -S --noconfirm "$pkg"
            done
            ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)
                if [[ "$c" =~ ^[0-9]+$ && "$c" -ge 1 && "$c" -le ${#package_list[@]} ]]; then
                    local pkg_name="${package_list[$((c-1))]}"
                    local pkg_id="${AUR_PACKAGES[$pkg_name]}"
                    info "Installing AUR package: $pkg_name ($pkg_id)"
                    "$aur_helper" -S --noconfirm "$pkg_id"
                fi
            done
            ;;
    esac
}

# Enable essential services
enable_services() {
    info "Configuring system services..."
    
    local services=(
        "NetworkManager:Network management"
        "bluetooth:Bluetooth support"
        "cups:Printing support"
        "fstrim.timer:SSD optimization"
    )
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service description <<< "$service_info"
        
        if systemctl list-unit-files | grep -q "^$service"; then
            if confirm "Enable $description ($service)?" "y"; then
                sudo systemctl enable "$service"
                success "✅ $service enabled"
            fi
        fi
    done
}

# Install multimedia codecs
install_multimedia_codecs() {
    if confirm "Install multimedia codecs and plugins?" "y"; then
        info "Installing multimedia support..."
        
        local multimedia_packages=(
            "gstreamer"
            "gst-plugins-base"
            "gst-plugins-good" 
            "gst-plugins-bad"
            "gst-plugins-ugly"
            "gst-libav"
            "ffmpeg"
            "x264"
            "x265"
        )
        
        local total=${#multimedia_packages[@]}
        local current=0
        
        for package in "${multimedia_packages[@]}"; do
            ((current++))
            show_progress $current $total "Installing $package"
            sudo pacman -S --noconfirm --needed "$package"
        done
        
        success "Multimedia codecs installed"
    fi
}

# Setup fonts
setup_fonts() {
    if confirm "Install additional fonts?" "y"; then
        info "Installing font packages..."
        
        local font_packages=(
            "ttf-dejavu"
            "ttf-liberation"
            "noto-fonts"
            "noto-fonts-emoji"
            "ttf-roboto"
            "ttf-opensans"
        )
        
        for font in "${font_packages[@]}"; do
            sudo pacman -S --noconfirm --needed "$font"
        done
        
        # Refresh font cache
        fc-cache -fv
        success "Fonts installed and cache updated"
    fi
}

# Setup Flatpak (available in Arch repos)
setup_flatpak() {
    if confirm "Install Flatpak support?" "y"; then
        info "Installing Flatpak..."
        sudo pacman -S --noconfirm flatpak
        
        # Add Flathub repository
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        success "Flatpak installed and configured"
        
        # Install Flatpak packages
        install_flatpak_packages
    fi
}

# Configure pacman
configure_pacman() {
    if confirm "Optimize pacman configuration?" "y"; then
        info "Configuring pacman..."
        
        local pacman_conf="/etc/pacman.conf"
        
        # Enable parallel downloads
        if ! grep -q "^ParallelDownloads" "$pacman_conf"; then
            sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' "$pacman_conf"
            success "Enabled parallel downloads"
        fi
        
        # Enable color output
        if ! grep -q "^Color" "$pacman_conf"; then
            sudo sed -i 's/#Color/Color/' "$pacman_conf"
            success "Enabled colored output"
        fi
        
        # Enable multilib repository for 32-bit support
        if confirm "Enable multilib repository (32-bit support)?" "y"; then
            if ! grep -q "^\[multilib\]" "$pacman_conf"; then
                echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a "$pacman_conf" > /dev/null
                sudo pacman -Sy --noconfirm
                success "Multilib repository enabled"
            else
                info "Multilib repository already enabled"
            fi
        fi
    fi
}

# Optimize mirror list
optimize_mirrors() {
    if confirm "Optimize pacman mirrors?" "y"; then
        info "Installing and running reflector to optimize mirrors..."
        
        sudo pacman -S --noconfirm --needed reflector
        
        # Backup current mirrorlist
        sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
        
        # Update mirrorlist with reflector
        sudo reflector --country "United States,Canada,Germany,France" \
                      --age 12 \
                      --protocol https \
                      --sort rate \
                      --save /etc/pacman.d/mirrorlist
        
        success "Mirror list optimized"
    fi
}

# Distribution-specific cleanup
cleanup_distribution_specific() {
    info "Cleaning up package cache and orphans..."
    
    # Clean package cache (keep only latest versions)
    sudo pacman -Sc --noconfirm
    
    # Remove orphaned packages
    local orphans
    if orphans=$(pacman -Qtdq 2>/dev/null); then
        if [[ -n "$orphans" ]]; then
            info "Removing orphaned packages:"
            echo "$orphans"
            # Split into array safely to avoid injection
            local -a orphan_array
            IFS=$'\n' read -r -d '' -a orphan_array <<< "$orphans" || true
            if [[ ${#orphan_array[@]} -gt 0 ]]; then
                sudo pacman -Rns --noconfirm "${orphan_array[@]}"
                success "Orphaned packages removed"
            fi
        fi
    fi
    
    # Clean AUR helper cache
    local aur_helper
    if aur_helper=$(check_aur_helper); then
        "$aur_helper" -Sc --noconfirm
    fi
    
    # Clean systemd journal logs
    if confirm "Clean up system logs?" "y"; then
        sudo journalctl --vacuum-time=7d
        sudo journalctl --vacuum-size=100M
    fi
}

# Configure shell environment for Arch
configure_arch_shell() {
    if command -v zsh >/dev/null 2>&1; then
        info "Configuring ZSH environment for Arch..."
        
        # Change default shell
        if confirm "Set ZSH as default shell?" "y"; then
            sudo chsh -s /usr/bin/zsh "$USER"
            success "Default shell changed to ZSH"
        fi
        
        # Install Oh My Zsh
        if confirm "Install Oh My Zsh with Arch-specific configuration?" "y"; then
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
                
                # Arch-specific aliases and functions
                cat >> "$HOME/.zshrc" << 'EOF'

# Arch Linux aliases
alias pacu='sudo pacman -Syu'        # Update system
alias pacs='pacman -Ss'              # Search packages
alias paci='sudo pacman -S'          # Install packages
alias pacr='sudo pacman -R'          # Remove packages
alias pacrns='sudo pacman -Rns'      # Remove packages with deps
alias paclo='pacman -Qdt'            # List orphans
alias pacro='sudo pacman -Rns $(pacman -Qtdq)' # Remove orphans
alias pacc='sudo pacman -Scc'        # Clean cache

# AUR helper aliases (if available)
if command -v yay >/dev/null 2>&1; then
    alias yayu='yay -Syu'            # Update including AUR
    alias yays='yay -Ss'             # Search AUR
    alias yayi='yay -S'              # Install from AUR
fi

# System information
alias sysinfo='neofetch'
alias diskinfo='df -h'
alias meminfo='free -h'
EOF
                
                success "Oh My Zsh installed with Arch-specific configuration"
            fi
        fi
    fi
}

# Main installation workflow
main() {
    info "Starting Arch-based distribution installer for: $DISTRO"
    
    # Configure pacman first
    configure_pacman
    
    # Optimize mirrors
    optimize_mirrors
    
    # System update
    update_system
    
    # Install AUR helper
    install_aur_helper
    
    # Install base packages
    if confirm "Install base packages?" "y"; then
        install_pacman_packages "base"
    fi
    
    # Install development packages
    if confirm "Install development packages?" "y"; then
        install_pacman_packages "development"
    fi
    
    # Install fonts
    setup_fonts
    
    # Install multimedia codecs
    install_multimedia_codecs
    
    # Install AUR packages
    install_aur_packages
    
    # Setup Flatpak
    setup_flatpak
    
    # Enable services
    enable_services
    
    # Install Node.js
    install_nodejs
    
    # Setup development environment
    setup_dev_environment
    
    # Configure shell
    configure_arch_shell
    
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
