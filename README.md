# Script d'Installation Arch Linux / Debian

![Version](https://img.shields.io/badge/version-1.0-blue)
![Date](https://img.shields.io/badge/date-May%202025-green)

## 📝 Description

Script automatisé pour configurer un environnement de développement sur Arch Linux et Debian. Ce script installe et configure les outils essentiels pour le développement.

## 🚀 Fonctionnalités

- Mise à jour système complète
- Installation des outils de développement :
  - GitHub CLI
  - Visual Studio Code
  - Git
  - Node.js (via nvm)
- Installation des applications :
  - Discord
  - Spotify
  - Neofetch
- Configuration de ZSH comme shell par défaut
- Installation personnalisée : possibilité d'ajouter des paquets supplémentaires pendant l'installation

## 📚 Documentation Détaillée

### ZSH et Oh My ZSH

- [Documentation officielle ZSH](https://www.zsh.org/)
- [Oh My ZSH](https://ohmyz.sh/)
- Plugins recommandés :
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - git
  - sudo

### Ressources des Distributions

#### Arch Linux

- [Wiki Arch Linux](https://wiki.archlinux.org/)
- [AUR (Arch User Repository)](https://aur.archlinux.org/)
- [Packages officiels](https://archlinux.org/packages/)
- [Guide d'installation yay](https://github.com/Jguer/yay)

#### Debian

- [Site officiel Debian](https://www.debian.org/)
- [Debian Packages](https://www.debian.org/distrib/packages)
- [Backports Debian](https://backports.debian.org/)
- [Wiki Debian](https://wiki.debian.org/)

### Outils de Développement

#### MariaDB

- [Documentation MariaDB](https://mariadb.org/documentation/)
- Version installée : 10.11.x
- Port par défaut : 3306

#### GitHub CLI

- [Documentation GitHub CLI](https://cli.github.com/manual/)
- Commandes essentielles :
  - `gh auth login` : Connexion à GitHub
  - `gh repo create` : Créer un nouveau dépôt
  - `gh pr create` : Créer une pull request

#### Node.js et NVM

- [Documentation Node.js](https://nodejs.org/docs)
- [Guide NVM](https://github.com/nvm-sh/nvm)
- Commandes NVM utiles :
  - `nvm install node` : Installer la dernière version
  - `nvm use node` : Utiliser la dernière version
  - `nvm alias default node` : Définir la version par défaut

#### Visual Studio Code

- [Documentation VS Code](https://code.visualstudio.com/docs)
- Extensions recommandées :
  - ESLint
  - Prettier
  - GitLens
  - Live Server
  - Material Icon Theme

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

## Author ✍️

| Author |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:
| [<img src="https://avatars.githubusercontent.com/u/92156365?s=400&u=03e2069751224461782a03ba2dfa57a51c4e5438&v=4" width=115 style="border-radius: 15px;" ><br><sub>@notfound</sub>](https://github.com/N0tFond) <br><br> [![](https://img.shields.io/badge/Portfolio-255E63?style=for-the-badge&logo=About.me&logoColor=white)](https://notfound-dev.vercel.app)

## 📄 Licence

Ce projet est sous licence MIT

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou un pull request.
