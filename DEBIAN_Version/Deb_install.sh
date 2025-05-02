#!/bin/bash

# Script start echo

echo "╔═════════════════════════════════════════════════════════════╗"
echo "║                    🚀 Installation Setup 🚀                 ║"
echo "╠═════════════════════════════════════════════════════════════╣"
echo "║  📋 Author  : NotFond                                       ║"
echo "║  📌 Version : 1.0                                           ║"
echo "║  📅 Date    : May 2025                                      ║" 
echo "║  🔒 LICENSE : MIT                                           ║"
echo "║      _   ______ ______   __________  __  ___   ______       ║"
echo "║     / | / / __ /_  __/  / ____/ __ \/ / / / | / / __ \      ║"
echo "║    /  |/ / / / // /    / /_  / / / / / / /  |/ / / / /      ║"
echo "║   / /|  / /_/ // /    / __/ / /_/ / /_/ / /|  / /_/ /       ║"
echo "║  /_/ |_/\____//_/    /_/    \____/\____/_/ |_/_____/        ║"
echo "║                                                             ║"
echo "╚═════════════════════════════════════════════════════════════╝"

# Root privileges check
if [ "$EUID" -ne 0 ]; then
    echo "╔═════════════════════════════════════════════════════════════╗"
    echo "║                   ⚠️  CRITICAL ERROR ⚠️                     ║"
    echo "╠═════════════════════════════════════════════════════════════╣"
    echo "║                                                             ║"
    echo "║   🔐 Root privileges required for installation              ║"
    echo "║   💡 Execute: sudo ./install.sh                             ║"
    echo "║                                                             ║"
    echo "╚═════════════════════════════════════════════════════════════╝"
    exit 1
fi

# Start installation message
echo "╔═════════════════════════════════════════════════════════════╗"
echo "║               🔄 Starting Installation                      ║"
echo "╚═════════════════════════════════════════════════════════════╝"

# Update packages and install required dependencies
echo "Updating packages and installing dependencies..."
sudo apt update
sudo apt upgrade -y

# Waiting delay with countdown
echo -e "\nWaiting for system stabilization after update..."
total_seconds=15
for (( i=total_seconds; i>=0; i-- )); do
    echo -ne "\rWaiting: $i seconds remaining... "
    sleep 1
done
echo -e "\nResuming installation...\n"

# Function to prompt user for package installation
prompt_package_installation() {
    local package=$1
    local description=$2
    echo -n "Voulez-vous installer $package? ($description) [O/n]: "
    read -r response
    if [[ "${response,,}" != "n" ]]; then
        echo "Installation de $package..."
        return 0
    else
        echo "Installation de $package ignorée."
        return 1
    fi
}

# Package selection
echo "╔═════════════════════════════════════════════════════════════╗"
echo "║               📦 Sélection des Packages 📦                  ║"
echo "╚═════════════════════════════════════════════════════════════╝"

# Base packages selection
if prompt_package_installation "Packages de base" "mariadb-server, gh, zsh, git, neofetch, curl, wget"; then
    sudo apt install -y mariadb-server gh zsh git neofetch curl wget software-properties-common apt-transport-https
fi

# VSCode selection
if prompt_package_installation "Visual Studio Code" "Éditeur de code"; then
    echo "Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
    rm -f packages.microsoft.gpg
fi

# Spotify selection
if prompt_package_installation "Spotify" "Application de streaming musical"; then
    echo "Installing Spotify..."
    curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y spotify-client
fi

# Node.js selection
if prompt_package_installation "Node.js" "Environment d'exécution JavaScript"; then
    # Start installation message for Node.js
    echo "╔═════════════════════════════════════════════════════════════╗"
    echo "║               ℹ️  Important Information  ℹ️                 ║"
    echo "╠═════════════════════════════════════════════════════════════╣"
    echo "║  If you're having trouble with nvm and npm installation,    ║"
    echo "║  you can either install them manually or continue using     ║"
    echo "║  this automated installation script.                        ║"
    echo "╚═════════════════════════════════════════════════════════════╝"

    # Download and install nvm
    echo "Downloading and installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

    # Load nvm in current shell without restart
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Install Node.js via nvm
    echo "Installing Node.js version 22..."
    nvm install 22

    # Check installed versions
    echo "Checking installed versions..."
    node_version=$(node -v)
    nvm_current=$(nvm current)
    npm_version=$(npm -v)

    echo "Node.js version: $node_version"
    echo "Current nvm version: $nvm_current"
    echo "npm version: $npm_version"

    # Verify if expected versions are installed
    if [[ "$node_version" == "v22.14.0" && "$nvm_current" == "v22.14.0" && "$npm_version" == "10.9.2" ]]; then
        echo "Installation successful!"
    else
        echo "Error: Installed versions do not match expected versions."
        echo "Expected Node.js version: v22.14.0, installed: $node_version"
        echo "Expected nvm version: v22.14.0, installed: $nvm_current"
        echo "Expected npm version: 10.9.2, installed: $npm_version"
    fi
fi