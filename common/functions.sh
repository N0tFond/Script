#!/bin/bash

# Common package definitions and configurations
# This file is sourced by distribution-specific scripts

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# Security and validation functions
validate_url() {
    local url="$1"
    # Basic URL validation
    if [[ "$url" =~ ^https?://[a-zA-Z0-9.-]+(/.*)?$ ]]; then
        return 0
    else
        return 1
    fi
}

# Secure download function with integrity checks
secure_download() {
    local url="$1"
    local output_file="$2"
    local max_size="${3:-10485760}"  # 10MB default
    local expected_hash="$4"  # Optional SHA256 hash
    
    # Validate URL
    if ! validate_url "$url"; then
        error "Invalid URL format: $url"
        return 1
    fi
    
    # Create temporary file
    local temp_file
    temp_file=$(mktemp)
    
    # Download with security constraints
    if curl -fsSL --max-time 60 --retry 3 --max-filesize "$max_size" "$url" -o "$temp_file"; then
        # Verify file size
        local file_size
        file_size=$(stat -f%z "$temp_file" 2>/dev/null || stat -c%s "$temp_file" 2>/dev/null)
        
        if [[ "$file_size" -gt "$max_size" ]]; then
            error "Downloaded file too large: $file_size bytes"
            rm -f "$temp_file"
            return 1
        fi
        
        # Verify hash if provided
        if [[ -n "$expected_hash" ]]; then
            local actual_hash
            actual_hash=$(sha256sum "$temp_file" | cut -d' ' -f1)
            if [[ "$actual_hash" != "$expected_hash" ]]; then
                error "Hash verification failed for $url"
                error "Expected: $expected_hash"
                error "Actual: $actual_hash"
                rm -f "$temp_file"
                return 1
            fi
        fi
        
        # Move to final location
        mv "$temp_file" "$output_file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Package categories
declare -A BASE_PACKAGES=(
    ["essential"]="git curl wget zsh neofetch htop tree unzip"
    ["development"]="build-essential nodejs npm python3 python3-pip"
    ["media"]="vlc firefox"
    ["productivity"]="libreoffice"
)

declare -A FLATPAK_PACKAGES=(
    ["vscode"]="com.visualstudio.code"
    ["discord"]="com.discordapp.Discord"
    ["spotify"]="com.spotify.Client"
    ["gimp"]="org.gimp.GIMP"
)

declare -A SNAP_PACKAGES=(
    ["vscode"]="code --classic"
    ["discord"]="discord"
    ["spotify"]="spotify"
    ["postman"]="postman"
)

# Node.js configuration
readonly NODE_VERSION="22"
readonly NVM_VERSION="v0.40.2"

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

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}"
}

# Progress bar function
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r${CYAN}Progress: ["
    printf "%*s" $filled | tr ' ' '█'
    printf "%*s" $((width - filled)) | tr ' ' '░'
    printf "] %d%% - %s${NC}" $percentage "$message"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# User confirmation function with timeout
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local timeout="${3:-30}"
    
    local response
    while true; do
        if [[ "$default" == "y" ]]; then
            if read -t "$timeout" -r -p "$prompt [Y/n]: " response; then
                response=${response,,}
                [[ -z "$response" || "$response" == "y" || "$response" == "yes" ]] && return 0
                [[ "$response" == "n" || "$response" == "no" ]] && return 1
            else
                warn "Timeout reached, using default: $default"
                [[ "$default" == "y" ]] && return 0 || return 1
            fi
        else
            if read -t "$timeout" -r -p "$prompt [y/N]: " response; then
                response=${response,,}
                [[ "$response" == "y" || "$response" == "yes" ]] && return 0
                [[ -z "$response" || "$response" == "n" || "$response" == "no" ]] && return 1
            else
                warn "Timeout reached, using default: $default"
                [[ "$default" == "y" ]] && return 0 || return 1
            fi
        fi
        warn "Please answer yes or no."
    done
}

# Package selection menu
select_packages() {
    local category="$1"
    local -n packages_ref=$2
    local selected_packages=()
    
    info "Select $category packages to install:"
    echo
    
    local i=1
    local package_list=()
    for pkg in ${packages_ref["$category"]}; do
        package_list+=("$pkg")
        echo "  $i) $pkg"
        ((i++))
    done
    
    echo "  a) All packages"
    echo "  s) Skip this category"
    echo
    
    read -r -p "Enter your choice (comma-separated numbers, 'a' for all, 's' to skip): " choice
    
    case "$choice" in
        s|S|skip|Skip)
            return 0
            ;;
        a|A|all|All)
            selected_packages=("${package_list[@]}")
            ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)  # trim whitespace
                if [[ "$c" =~ ^[0-9]+$ && "$c" -ge 1 && "$c" -le ${#package_list[@]} ]]; then
                    selected_packages+=("${package_list[$((c-1))]}")
                fi
            done
            ;;
    esac
    
    echo "${selected_packages[@]}"
}

# System stabilization wait
wait_for_system() {
    local seconds=${1:-10}
    local message="${2:-Waiting for system stabilization}"
    
    info "$message..."
    for ((i=seconds; i>=1; i--)); do
        printf "\r${YELLOW}⏳ $message: %d seconds remaining...${NC}" "$i"
        sleep 1
    done
    echo
    success "System ready!"
}

# Install Node.js via NVM
install_nodejs() {
    if confirm "Install Node.js $NODE_VERSION via NVM?" "y"; then
        info "Installing NVM..."
        
        # Validate NVM version format
        if [[ ! "$NVM_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            error "Invalid NVM version format: $NVM_VERSION"
            return 1
        fi
        
        # Download and install NVM with security checks
        local nvm_url="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"
        local temp_script
        temp_script=$(mktemp)
        
        # Download with security checks
        if ! curl -fsSL --max-time 30 --retry 3 "$nvm_url" -o "$temp_script"; then
            error "Failed to download NVM installer"
            rm -f "$temp_script"
            return 1
        fi
        
        # Basic validation of downloaded script
        if [[ ! -s "$temp_script" ]] || ! grep -q "nvm" "$temp_script"; then
            error "Downloaded NVM script appears invalid"
            rm -f "$temp_script"
            return 1
        fi
        
        # Execute the script
        bash "$temp_script"
        rm -f "$temp_script"
        
        # Load NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        
        if command -v nvm >/dev/null 2>&1; then
            info "Installing Node.js version $NODE_VERSION..."
            
            # Validate Node version format
            if [[ ! "$NODE_VERSION" =~ ^[0-9]+$ ]]; then
                error "Invalid Node.js version format: $NODE_VERSION"
                return 1
            fi
            
            nvm install "$NODE_VERSION"
            nvm use "$NODE_VERSION"
            nvm alias default "$NODE_VERSION"
            
            # Verify installation
            local node_version npm_version
            node_version=$(node -v 2>/dev/null || echo "not installed")
            npm_version=$(npm -v 2>/dev/null || echo "not installed")
            
            success "Node.js installed: $node_version"
            success "npm installed: $npm_version"
        else
            error "Failed to load NVM. Please restart your shell and try again."
            return 1
        fi
    fi
}

# Setup development environment
setup_dev_environment() {
    if confirm "Setup development environment (Git, SSH, etc.)?" "y"; then
        info "Configuring development environment..."
        
        # Git configuration with input validation
        if command -v git >/dev/null 2>&1; then
            local git_username git_email
            
            # Validate Git username
            while true; do
                read -r -p "Enter your Git username: " git_username
                if [[ -n "$git_username" && "$git_username" =~ ^[a-zA-Z0-9._-]+$ ]]; then
                    break
                else
                    warn "Invalid username. Use only alphanumeric characters, dots, underscores, and hyphens."
                fi
            done
            
            # Validate Git email
            while true; do
                read -r -p "Enter your Git email: " git_email
                if [[ "$git_email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    break
                else
                    warn "Invalid email format. Please enter a valid email address."
                fi
            done
            
            if [[ -n "$git_username" && -n "$git_email" ]]; then
                git config --global user.name "$git_username"
                git config --global user.email "$git_email"
                git config --global init.defaultBranch main
                git config --global pull.rebase false
                
                success "Git configured for $git_username <$git_email>"
            fi
        fi
        
        # Generate SSH key if requested
        if confirm "Generate SSH key for Git/GitHub?" "n"; then
            if [[ ! -f ~/.ssh/id_rsa ]]; then
                # Ensure SSH directory exists with proper permissions
                mkdir -p ~/.ssh
                chmod 700 ~/.ssh
                
                ssh-keygen -t rsa -b 4096 -C "$git_email" -f ~/.ssh/id_rsa -N ""
                
                # Set proper permissions for SSH key
                chmod 600 ~/.ssh/id_rsa
                chmod 644 ~/.ssh/id_rsa.pub
                
                success "SSH key generated at ~/.ssh/id_rsa.pub"
                info "Add this key to your GitHub account:"
                cat ~/.ssh/id_rsa.pub
            else
                warn "SSH key already exists at ~/.ssh/id_rsa"
            fi
        fi
        
        # Setup ZSH with Oh My Zsh (with security checks)
        if command -v zsh >/dev/null 2>&1 && confirm "Install Oh My Zsh?" "y"; then
            if [[ ! -d ~/.oh-my-zsh ]]; then
                local temp_script
                temp_script=$(mktemp)
                
                # Download Oh My Zsh installer with security checks
                if curl -fsSL --max-time 30 --retry 3 "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh" -o "$temp_script"; then
                    # Basic validation
                    if grep -q "oh-my-zsh" "$temp_script"; then
                        sh "$temp_script" --unattended
                        success "Oh My Zsh installed"
                    else
                        error "Downloaded Oh My Zsh script appears invalid"
                    fi
                else
                    error "Failed to download Oh My Zsh installer"
                fi
                
                rm -f "$temp_script"
            else
                warn "Oh My Zsh already installed"
            fi
        fi
    fi
}

# Check if Flatpak is available and install packages
install_flatpak_packages() {
    if ! command -v flatpak >/dev/null 2>&1; then
        warn "Flatpak not available on this system"
        return 1
    fi
    
    # Add Flathub repository if not already added
    if ! flatpak remotes | grep -q flathub; then
        info "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    info "Available Flatpak packages:"
    local i=1
    local package_list=()
    for name in "${!FLATPAK_PACKAGES[@]}"; do
        package_list+=("$name")
        echo "  $i) $name (${FLATPAK_PACKAGES[$name]})"
        ((i++))
    done
    
    echo "  a) All packages"
    echo "  s) Skip Flatpak packages"
    echo
    
    read -r -p "Enter your choice: " choice
    
    case "$choice" in
        s|S|skip|Skip)
            return 0
            ;;
        a|A|all|All)
            for pkg_id in "${FLATPAK_PACKAGES[@]}"; do
                info "Installing Flatpak package: $pkg_id"
                flatpak install -y flathub "$pkg_id"
            done
            ;;
        *)
            IFS=',' read -ra choices <<< "$choice"
            for c in "${choices[@]}"; do
                c=$(echo "$c" | xargs)
                if [[ "$c" =~ ^[0-9]+$ && "$c" -ge 1 && "$c" -le ${#package_list[@]} ]]; then
                    local pkg_name="${package_list[$((c-1))]}"
                    local pkg_id="${FLATPAK_PACKAGES[$pkg_name]}"
                    info "Installing Flatpak package: $pkg_name ($pkg_id)"
                    flatpak install -y flathub "$pkg_id"
                fi
            done
            ;;
    esac
}

# System cleanup function
cleanup_system() {
    if confirm "Perform system cleanup?" "y"; then
        info "Performing system cleanup..."
        
        # This will be implemented by each distribution script
        cleanup_distribution_specific
        
        success "System cleanup completed"
    fi
}

# Final system configuration
finalize_installation() {
    success "🎉 Installation completed successfully!"
    echo
    info "Summary of installed components:"
    
    # Check and display installed software
    command -v git >/dev/null && echo "  ✅ Git: $(git --version | cut -d' ' -f3)"
    command -v zsh >/dev/null && echo "  ✅ ZSH: $(zsh --version | cut -d' ' -f2)"
    command -v node >/dev/null && echo "  ✅ Node.js: $(node -v)"
    command -v npm >/dev/null && echo "  ✅ npm: $(npm -v)"
    command -v code >/dev/null && echo "  ✅ Visual Studio Code"
    command -v flatpak >/dev/null && echo "  ✅ Flatpak available"
    
    echo
    info "Post-installation notes:"
    echo "  📝 Installation log: $(dirname "$0")/installation.log"
    echo "  🔄 Restart your terminal or run 'source ~/.bashrc' to reload environment"
    echo "  🐚 Change shell to ZSH: chsh -s \$(which zsh)"
    echo
    
    if confirm "Reboot system to complete installation?" "n"; then
        warn "System will reboot in 5 seconds..."
        sleep 5
        sudo reboot
    fi
}
