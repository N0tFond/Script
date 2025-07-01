# Installation Script for Arch Linux / Debian

![Version](https://img.shields.io/badge/version-1.0-blue)
![Date](https://img.shields.io/badge/date-May%202025-green)

## 📝 Description

Automated script to set up a development environment on Arch Linux and Debian. This script installs and configures essential development tools.

## 🚀 Features

- Complete system update
- Development tools installation:
  - GitHub CLI
  - Visual Studio Code
  - Git
  - Node.js (via nvm)
- Application installation:
  - Discord
  - Spotify
  - Neofetch
- ZSH configuration as default shell
- Custom installation: ability to add additional packages during installation

## 📚 Detailed Documentation

### ZSH and Oh My ZSH

- [Official ZSH Documentation](https://www.zsh.org/)
- [Oh My ZSH](https://ohmyz.sh/)
- Recommended plugins:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - git
  - sudo

### Distribution Resources

#### Arch Linux

- [Arch Linux Wiki](https://wiki.archlinux.org/)
- [AUR (Arch User Repository)](https://aur.archlinux.org/)
- [Official Packages](https://archlinux.org/packages/)
- [Yay Installation Guide](https://github.com/Jguer/yay)

#### Debian

- [Debian Official Website](https://www.debian.org/)
- [Debian Packages](https://www.debian.org/distrib/packages)
- [Debian Backports](https://backports.debian.org/)
- [Debian Wiki](https://wiki.debian.org/)

### Development Tools

#### MariaDB

- [MariaDB Documentation](https://mariadb.org/documentation/)
- Installed version: 10.11.x
- Default port: 3306

#### GitHub CLI

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- Essential commands:
  - `gh auth login`: Login to GitHub
  - `gh repo create`: Create a new repository
  - `gh pr create`: Create a pull request

#### Node.js and NVM

- [Node.js Documentation](https://nodejs.org/docs)
- [NVM Guide](https://github.com/nvm-sh/nvm)
- Useful NVM commands:
  - `nvm install node`: Install latest version
  - `nvm use node`: Use latest version
  - `nvm alias default node`: Set default version

#### Visual Studio Code

- [VS Code Documentation](https://code.visualstudio.com/docs)
- Recommended extensions:
  - ESLint
  - **Prettier**
  - GitLens
  - Live Server
  - Material Icon Theme

## 📋 Prerequisites

- Arch Linux or Debian system
- Root access
- `yay` (AUR helper) installed (Arch Linux only)
- Stable Internet connection

## 💻 Installation

### For Arch Linux:

1. Clone the repository:

```bash
git clone https://github.com/N0tFond/Script.git
cd Script
```

2. Make the script executable:

```bash
chmod +x install.sh
```

3. Run the script:

```bash
sudo ./install.sh
```

### For Debian:

1. Clone the repository:

```bash
git clone https://github.com/N0tFond/Script.git
cd Script/DEBIAN_Version
```

2. Make the script executable:

```bash
chmod +x install.sh
```

3. Run the script:

```bash
sudo ./install.sh
```

## ⚙️ Package Versions

- Node.js: v22.14.0
- npm: 10.9.2
- nvm: 0.40.2

## ⚠️ Important Notes

- Script must be run with root privileges
- A 15-second delay is included after system updates
- Make sure to backup your important data before running

| Author |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:
| [<img src="https://avatars.githubusercontent.com/u/92156365?s=400&u=03e2069751224461782a03ba2dfa57a51c4e5438&v=4" width=115 style="border-radius: 15px;" ><br><sub>@notfound</sub>](https://github.com/N0tFond) <br><br> [![](https://img.shields.io/badge/Portfolio-255E63?style=for-the-badge&logo=About.me&logoColor=white)](https://notfound-dev.vercel.app)

## 📄 License

This project is licensed under MIT

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.
