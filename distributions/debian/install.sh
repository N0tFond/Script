#!/bin/bash

# Debian-based distributions installer (Ubuntu, Debian, Mint, Elementary, Pop!_OS, etc.)
# This script handles APT package management and distribution-specific configurations

set -euo pipefail

# Get script directory and source common functions
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../common/functions.sh"

# Distribution-specific configuration
readonly DISTRO="$1"

# Distribution-specific package mappings
declare -A DISTRO_PACKAGES=(
    ["base"]="git curl wget zsh neofetch htop tree unzip build-essential"
    ["development"]="nodejs npm python3 python3-pip python3-venv gh"
    ["media"]="vlc firefox-esr"
    ["snap-support"]="snapd"
    ["flatpak-support"]="flatpak"
)

# Ubuntu-specific PPAs and repositories
declare -A UBUNTU_PPAS=(
    ["git"]="ppa:git-core/ppa"
    ["nodejs"]="https://deb.nodesource.com/node_18.x"
)

# Package manager functions
update_system() {
    info "Updating package lists and upgrading system..."
    sudo apt update
    show_progress 1 3 "Updating package lists"
    
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
    show_progress 2 3 "Upgrading packages"
    
    sudo DEBIAN_FRONTEND=noninteractive apt autoremove -y
    show_progress 3 3 "Removing unnecessary packages"
    
    wait_for_system 5 "Allowing system to stabilize after updates"
    success "System updated successfully"
}

# Install essential repositories and keys
setup_repositories() {
    info "Setting up additional repositories..."
    
    # Install software-properties-common for add-apt-repository
    sudo apt install -y software-properties-common apt-transport-https ca-certificates gnupg lsb-release
    
    # GitHub CLI repository
    if confirm "Add GitHub CLI repository?" "y"; then
        local keyring_file="/usr/share/keyrings/githubcli-archive-keyring.gpg"
        if curl -fsSL --max-time 30 --retry 3 "https://cli.github.com/packages/githubcli-archive-keyring.gpg" | sudo dd of="$keyring_file" status=none; then
            sudo chmod go+r "$keyring_file"
            echo "deb [arch=$(dpkg --print-architecture) signed-by=$keyring_file] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            success "GitHub CLI repository added"
        else
            error "Failed to add GitHub CLI repository"
        fi
    fi
    
    # Visual Studio Code repository
    if confirm "Add Visual Studio Code repository?" "y"; then
        local temp_key
        temp_key=$(mktemp)
        if wget -qO "$temp_key" "https://packages.microsoft.com/keys/microsoft.asc" && [[ -s "$temp_key" ]]; then
            gpg --dearmor < "$temp_key" | sudo dd of=/etc/apt/trusted.gpg.d/packages.microsoft.gpg status=none
            sudo chmod 644 /etc/apt/trusted.gpg.d/packages.microsoft.gpg
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
            success "Visual Studio Code repository added"
        else
            error "Failed to add Visual Studio Code repository"
        fi
        rm -f "$temp_key"
    fi
    
    # Spotify repository
    if confirm "Add Spotify repository?" "y"; then
        if curl -fsSL --max-time 30 --retry 3 "https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg" | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg; then
            sudo chmod 644 /etc/apt/trusted.gpg.d/spotify.gpg
            echo "deb https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null
            success "Spotify repository added"
        else
            error "Failed to add Spotify repository"
        fi
    fi
    
    # Google Chrome repository (Ubuntu/Debian)
    if confirm "Add Google Chrome repository?" "y"; then
        if curl -fsSL --max-time 30 --retry 3 "https://dl.google.com/linux/linux_signing_key.pub" | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/google-chrome.gpg; then
            sudo chmod 644 /etc/apt/trusted.gpg.d/google-chrome.gpg
            echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
            success "Google Chrome repository added"
        else
            error "Failed to add Google Chrome repository"
        fi
    fi
        rm -f "$temp_key"
    fi
    
    # Update package lists after adding repositories
    sudo apt update
    success "Repositories configured successfully"
}

# Install packages using APT
install_apt_packages() {
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
        
        if sudo DEBIAN_FRONTEND=noninteractive apt install -y "$package"; then
            success "✅ $package installed"
        else
            error "❌ Failed to install $package"
        fi
    done
}

# Install applications from repositories
install_applications() {
    local apps=()
    
    info "Select applications to install:"
    echo "  1) Visual Studio Code"
    echo "  2) Google Chrome"
    echo "  3) Spotify"
    echo "  4) Discord (via Flatpak)"
    echo "  5) Steam (via Flatpak)"
    echo "  6) GIMP"
    echo "  7) LibreOffice"
    echo "  8) VLC Media Player"
    echo "  9) Firefox"
    echo "  a) All applications"
    echo "  s) Skip applications"
    echo
    
    read -r -p "Enter your choice (comma-separated numbers): " choice
    
    case "$choice" in
        s|S) return 0 ;;
        a|A) apps=("code" "google-chrome-stable" "spotify-client" "gimp" "libreoffice" "vlc" "firefox-esr") ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)
                case "$c" in
                    1) apps+=("code") ;;
                    2) apps+=("google-chrome-stable") ;;
                    3) apps+=("spotify-client") ;;
                    4) install_flatpak_app "com.discordapp.Discord" ;;
                    5) install_flatpak_app "com.valvesoftware.Steam" ;;
                    6) apps+=("gimp") ;;
                    7) apps+=("libreoffice") ;;
                    8) apps+=("vlc") ;;
                    9) apps+=("firefox-esr") ;;
                esac
            done
            ;;
    esac
    
    # Install selected APT packages
    for app in "${apps[@]}"; do
        info "Installing $app..."
        if sudo DEBIAN_FRONTEND=noninteractive apt install -y "$app"; then
            success "✅ $app installed successfully"
        else
            error "❌ Failed to install $app"
        fi
    done
}

# Setup Flatpak if requested
setup_flatpak() {
    if confirm "Install Flatpak support?" "y"; then
        info "Installing Flatpak..."
        sudo apt install -y flatpak
        
        # Add Flathub repository
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        
        success "Flatpak installed and configured"
        
        # Install Flatpak packages
        install_flatpak_packages
    fi
}

# Setup Snap if requested (mainly for Ubuntu)
setup_snap() {
    if [[ "$DISTRO" == "ubuntu" ]] && confirm "Install Snap support?" "y"; then
        info "Installing Snap support..."
        sudo apt install -y snapd
        
        success "Snap installed and configured"
        
        # Install some popular Snap packages
        info "Available Snap packages:"
        echo "  1) Visual Studio Code"
        echo "  2) Discord"
        echo "  3) Postman"
        echo "  4) Slack"
        echo "  s) Skip"
        
        read -r -p "Select packages to install: " snap_choice
        
        case "$snap_choice" in
            *1*) sudo snap install code --classic ;;
            *2*) sudo snap install discord ;;
            *3*) sudo snap install postman ;;
            *4*) sudo snap install slack --classic ;;
        esac
    fi
}

# Install Flatpak application
install_flatpak_app() {
    local app_id="$1"
    if command -v flatpak >/dev/null 2>&1; then
        info "Installing Flatpak app: $app_id"
        flatpak install -y flathub "$app_id"
    else
        warn "Flatpak not available. Install Flatpak support first."
    fi
}

# Distribution-specific cleanup
cleanup_distribution_specific() {
    info "Cleaning up APT cache and unnecessary packages..."
    sudo apt autoremove -y
    sudo apt autoclean
    sudo apt clean
    
    # Clean up old kernels (keep current + 1 previous)
    if confirm "Remove old kernel versions?" "y"; then
        sudo apt autoremove --purge -y
    fi
    
    # Clean up systemd journal logs
    if confirm "Clean up system logs?" "y"; then
        sudo journalctl --vacuum-time=7d
        sudo journalctl --vacuum-size=100M
    fi
}

# Configure shell environment
configure_shell() {
    if command -v zsh >/dev/null 2>&1; then
        info "Configuring ZSH environment..."
        
        # Change default shell to ZSH if requested
        if confirm "Set ZSH as default shell?" "y"; then
            sudo chsh -s "$(which zsh)" "$USER"
            success "Default shell changed to ZSH (requires logout to take effect)"
        fi
        
        # Install Oh My Zsh if requested
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
                
                # Install popular plugins
                git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" 2>/dev/null || true
                git clone https://github.com/zsh-users/zsh-syntax-highlighting "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" 2>/dev/null || true
                
                # Configure .zshrc with plugins
                sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
                
                success "Oh My Zsh installed with useful plugins"
            else
                warn "Oh My Zsh already installed"
            fi
        fi
    fi
}

# Main installation workflow
main() {
    info "Starting Debian-based distribution installer for: $DISTRO"
    
    # System update
    update_system
    
    # Setup repositories
    setup_repositories
    
    # Install base packages
    if confirm "Install base packages (git, curl, zsh, etc.)?" "y"; then
        install_apt_packages "base"
    fi
    
    # Install development packages
    if confirm "Install development packages?" "y"; then
        install_apt_packages "development"
    fi
    
    # Install applications
    install_applications
    
    # Setup package managers
    setup_flatpak
    setup_snap
    
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
