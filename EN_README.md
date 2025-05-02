# Arch Linux Installation Script

![Version](https://img.shields.io/badge/version-1.0-blue)
![Date](https://img.shields.io/badge/date-May%202025-green)

## 📝 Description

Automated script to set up a development environment on Arch Linux. This script installs and configures essential development tools.

## 🚀 Features

- Complete system update
- Development tools installation:
  - MariaDB
  - GitHub CLI
  - Visual Studio Code
  - Git
  - Node.js (via nvm)
- Application installation:
  - Discord
  - Spotify
  - Neofetch
- ZSH configuration as default shell

## 📋 Prerequisites

- Arch Linux system
- Root access
- `yay` (AUR helper) installed
- Stable Internet connection

## 💻 Installation

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

## ⚙️ Package Versions

- Node.js: v22.14.0
- npm: 10.9.2
- nvm: 0.40.2

## ⚠️ Important Notes

- Script must be run with root privileges
- A 15-second delay is included after system updates
- Make sure to backup your important data before running

## 👤 Author

- **NotFond**

## 📄 License

This project is licensed under MIT

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.
