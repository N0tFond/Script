#!/bin/bash

# Echo début de script

echo "╔═════════════════════════════════════════════════════════════╗"
echo "║                    🚀 Installation Setup 🚀                 ║"
echo "╠═════════════════════════════════════════════════════════════╣"
echo "║  📋 Author  : NotFond                                       ║"
echo "║  📌 Version : 1.0                                           ║"
echo "║  📅 Date    : May 2025                                      ║" 
echo "║  🔒 LICENCE : MIT                                           ║"
echo "║      _   ______ ______   __________  __  ___   ______       ║"
echo "║     / | / / __ /_  __/  / ____/ __ \/ / / / | / / __ \      ║"
echo "║    /  |/ / / / // /    / /_  / / / / / / /  |/ / / / /      ║"
echo "║   / /|  / /_/ // /    / __/ / /_/ / /_/ / /|  / /_/ /       ║"
echo "║  /_/ |_/\____//_/    /_/    \____/\____/_/ |_/_____/        ║"
echo "║                                                             ║"
echo "╚═════════════════════════════════════════════════════════════╝"

# Vérification des privilèges root
if [ "$EUID" -ne 0 ]; then
    echo "╔═════════════════════════════════════════════════════════════╗"
    echo "║                   ⚠️  ERREUR CRITIQUE ⚠️                    ║"
    echo "╠═════════════════════════════════════════════════════════════╣"
    echo "║                                                             ║"
    echo "║   🔐 Privilèges root requis pour l'installation             ║"
    echo "║   💡 Exécutez : sudo ./install.sh                           ║"
    echo "║                                                             ║"
    echo "╚═════════════════════════════════════════════════════════════╝"
    exit 1
fi

# Start installation message
echo "╔═════════════════════════════════════════════════════════════╗"
echo "║               🔄 Démarrage de l'installation                ║"
echo "╚═════════════════════════════════════════════════════════════╝"

# Mettre à jour les paquets et installer les dépendances nécessaires
echo "Mise à jour des paquets et installation des dépendances..."
sudo pacman -Syu --noconfirm
yay -Syu --noconfirm

# Délai d'attente avec compte à rebours
echo -e "\nDélai d'attente pour stabilisation du système après la mise à jour..."
total_seconds=15
for (( i=total_seconds; i>=0; i-- )); do
    echo -ne "\rAttente: $i secondes restantes... "
    sleep 1
done
echo -e "\nReprise de l'installation...\n"

# Installation des paquets de base
echo "Installation des paquets de base..."
sudo pacman -S --noconfirm mariadb github-cli discord zsh git neofetch

# Installer Visual Studio Code via yay
echo "Installation de Visual Studio Code..."
yay -S --noconfirm code

# Installation Spotify via yay
echo "Installation de Spotify..."
yay -S --noconfirm spotify

# Télécharger et installer nvm
echo "Téléchargement et installation de nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash

# Charger nvm dans le shell actuel sans redémarrer
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Installer Node.js via nvm
echo "Installation de Node.js version 22..."
nvm install 22

# Vérifier les versions installées
echo "Vérification des versions installées..."
node_version=$(node -v)
nvm_current=$(nvm current)
npm_version=$(npm -v)

echo "Version de Node.js : $node_version"
echo "Version courante de nvm : $nvm_current"
echo "Version de npm : $npm_version"

# Vérifier si les versions attendues sont installées
if [[ "$node_version" == "v22.14.0" && "$nvm_current" == "v22.14.0" && "$npm_version" == "10.9.2" ]]; then
    echo "Installation réussie !"
else
    echo "Erreur : Les versions installées ne correspondent pas aux versions attendues."
    echo "Version de Node.js attendue : v22.14.0, installée : $node_version"
    echo "Version courante de nvm attendue : v22.14.0, installée : $nvm_current"
    echo "Version de npm attendue : 10.9.2, installée : $npm_version"
fi