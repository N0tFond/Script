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
    echo "║   💡 Execute: sudo ./install.sh                            ║"
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
sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

# Waiting delay with countdown
echo -e "\nWaiting for system stabilization after update..."
total_seconds=15
for (( i=total_seconds; i>=0; i-- )); do
    echo -ne "\rWaiting: $i seconds remaining... "
    sleep 1
done
echo -e "\nResuming installation...\n"

# Installing base packages
echo "Installing base packages..."
sudo pacman -S --noconfirm mariadb github-cli discord zsh git neofetch

# Install Visual Studio Code via yay
echo "Installing Visual Studio Code..."
yay -S --noconfirm code

# Install Spotify via yay
echo "Installing Spotify..."
yay -S --noconfirm spotify

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