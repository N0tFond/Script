# Script d'Installation Arch Linux / Debian

![Version](https://img.shields.io/badge/version-1.0-blue)
![Date](https://img.shields.io/badge/date-May%202025-green)

## 📝 Description

Script automatisé pour configurer un environnement de développement sur Arch Linux et Debian. Ce script installe et configure les outils essentiels pour le développement.

## 🚀 Fonctionnalités

- Mise à jour système complète
- Installation des outils de développement :
  - MariaDB
  - GitHub CLI
  - Visual Studio Code
  - Git
  - Node.js (via nvm)
- Installation des applications :
  - Discord
  - Spotify
  - Neofetch
- Configuration de ZSH comme shell par défaut

## 📋 Prérequis

- Système Arch Linux ou Debian
- Accès root
- `yay` (AUR helper) installé (uniquement pour Arch Linux)
- Connexion Internet stable

## 💻 Installation

### Pour Arch Linux :

1. Clonez le dépôt :

```bash
git clone https://github.com/N0tFond/Script.git
cd Script
```

2. Rendez le script exécutable :

```bash
chmod +x install.sh
```

3. Exécutez le script :

```bash
sudo ./install.sh
```

### Pour Debian :

1. Clonez le dépôt :

```bash
git clone https://github.com/N0tFond/Script.git
cd Script/DEBIAN_Version
```

2. Rendez le script exécutable :

```bash
chmod +x install.sh
```

3. Exécutez le script :

```bash
sudo ./install.sh
```

## ⚙️ Versions des Paquets

- Node.js : v22.14.0
- npm : 10.9.2
- nvm : 0.40.2

## ⚠️ Notes Importantes

- Le script doit être exécuté avec les privilèges root
- Un délai de 15 secondes est prévu après les mises à jour système
- Assurez-vous d'avoir une sauvegarde de vos données importantes avant l'exécution

## 👤 Auteur

- **NotFond**

## 📄 Licence

Ce projet est sous licence MIT

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou un pull request.
