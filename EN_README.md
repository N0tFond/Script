# 🚀 Universal Linux Installer

A universal and optimized installation script for Linux distributions, supporting a wide range of distribution families with automatic detection.

## ✨ Features

- 🔍 **Automatic detection** of Linux distribution
- 📦 **Multi-distribution support** with specialized scripts
- 🎯 **Modular installation** with interactive package selection
- 🛠️ **Optimized configuration** for each package manager
- 📊 **Progress bars** and detailed logging
- 🔧 **Complete development environment**
- 🐚 **ZSH configuration** with Oh My Zsh
- 📝 **Complete logging** for debugging
- 🧹 **Automatic system cleanup**

## 🏗️ Project Structure

```
├── install.sh                    # Main script with auto detection
├── common/
│   └── functions.sh              # Shared common functions
└── distributions/
    ├── debian/
    │   └── install.sh           # Ubuntu, Debian, Mint, Elementary, Pop!_OS, Kali
    ├── arch/
    │   └── install.sh           # Arch, Manjaro, EndeavourOS, ArcoLinux, Garuda
    ├── redhat/
    │   └── install.sh           # Fedora, CentOS, RHEL, Rocky, AlmaLinux, OpenSUSE
    ├── gentoo/
    │   └── install.sh           # Gentoo Linux
    ├── alpine/
    │   └── install.sh           # Alpine Linux
    ├── void/
    │   └── install.sh           # Void Linux
    └── nixos/
        └── install.sh           # NixOS
```

## 🐧 Supported Distributions

### Debian Family

- **Ubuntu** (all versions)
- **Debian** (stable, testing, unstable)
- **Linux Mint**
- **Elementary OS**
- **Pop!\_OS**
- **Kali Linux**
- **Parrot Security OS**

### Arch Family

- **Arch Linux**
- **Manjaro**
- **EndeavourOS**
- **ArcoLinux**
- **Garuda Linux**
- **Artix Linux**

### Red Hat Family

- **Fedora**
- **CentOS**
- **Red Hat Enterprise Linux (RHEL)**
- **Rocky Linux**
- **AlmaLinux**
- **OpenSUSE**

### Other Distributions

- **Gentoo Linux** - Source-based compilation
- **Alpine Linux** - Lightweight musl-based distribution
- **Void Linux** - Rolling release with runit
- **NixOS** - Declarative configuration

## 🚀 Quick Installation

### Simple Usage

```bash
# Clone the repository
git clone https://github.com/N0tFond/Script.git
cd Script

# Make the script executable
chmod +x install.sh

# Run the installation (script automatically detects your distribution)
./install.sh
```

### Specific Installation

If you want to force a specific distribution:

```bash
# For Ubuntu/Debian
./distributions/debian/install.sh ubuntu

# For Arch Linux
./distributions/arch/install.sh arch

# For Fedora
./distributions/redhat/install.sh fedora
```

## ⚠️ Critical Warnings

> [!IMPORTANT]
> **Distribution not detected**: If the script fails to identify your Linux distribution, the installation will terminate immediately with an error code.

### � Detection Problem Resolution

> [!WARNING]
> **Automatic detection failure** can occur on custom or very recent distributions.

**Recommended solutions:**

1. **Compatibility verification**

   ```bash
   # Check your distribution
   cat /etc/os-release
   ```

2. **Forced installation** for compatible distributions

   ```bash
   # Debian-based distribution (Ubuntu, Mint, Elementary, etc.)
   ./distributions/debian/install.sh ubuntu

   # Arch-based distribution (Manjaro, EndeavourOS, etc.)
   ./distributions/arch/install.sh arch

   # Red Hat-based distribution (Fedora, CentOS, etc.)
   ./distributions/redhat/install.sh fedora
   ```

3. **Technical support**

> [!NOTE]
> Create a GitHub issue with the following information:
>
> - Output of `cat /etc/os-release`
> - Kernel version (`uname -r`)
> - Complete error messages

### 🛡️ Security Recommendations

> [!CAUTION]
> **Mandatory testing**: Always test on a virtual machine before production deployment.
>
> - **Complete backup** of critical data
> - **System restore point** if available
> - **Sudo privileges verification** before execution
> - **Stable internet connection** required during installation

> [!TIP]
> **Debug mode**: Add `bash -x` for detailed diagnostics
>
> ```bash
> bash -x ./install.sh
> ```

## 📦 Installed Packages

### Base Packages

- **System tools**: git, curl, wget, htop, tree, unzip
- **Shell**: zsh with Oh My Zsh
- **System information**: neofetch

### Development Tools

- **Node.js** via NVM (version 22)
- **Python 3** with pip
- **Compilers**: gcc, make, build-essential
- **Git** with interactive configuration

### Applications

- **Editor**: Visual Studio Code
- **Browsers**: Firefox, Chrome
- **Media**: VLC, Spotify
- **Communication**: Discord
- **Productivity**: LibreOffice
- **Graphics**: GIMP

### Alternative Package Managers

- **Flatpak** with Flathub
- **Snap** (Ubuntu)
- **AUR helpers** (Arch - yay)

## 🔧 Features by Distribution

### Debian/Ubuntu

- Official and third-party repository configuration
- PPA and external repository support
- Installation via APT, Flatpak and Snap

### Arch Linux

- Optimized Pacman configuration
- AUR helper installation (yay)
- Service management with systemd
- Automatic cleanup of orphaned packages

### Fedora/RHEL

- RPM Fusion configuration
- EPEL repository management
- SELinux support
- Firewalld configuration

### Gentoo

- Portage optimization (MAKEOPTS, USE flags)
- Overlay management with Layman
- OpenRC services
- Optimized parallel compilation

### Alpine

- Glibc compatibility for applications
- Lightweight package management
- OpenRC services
- Musl libc optimizations

### Void Linux

- Optimized XBPS configuration
- Runit services
- Multilib and non-free repositories
- Intelligent cache management

### NixOS

- Declarative configuration
- Home-manager setup
- Flakes support
- Automatic garbage collection

## ⚙️ Configuration Options

The script offers several levels of customization:

### Interactive Installation

- Package category selection
- Individual application choices
- System service configuration
- Distribution-specific optimizations

### Automated Configuration

- Pre-defined environment variables
- Default configuration scripts
- Automatic post-installation cleanup

## 📝 Logging and Debugging

- **Log file**: `installation.log` in the script directory
- **Color codes** for better readability
- **Complete error handling** with rollback
- **Progress bars** for long operations

## 🛡️ Security

- **Privilege verification**: The script refuses to run as root
- **User input validation**
- **Repository signature verification**
- **Automatic backup** of system configurations

## 🚨 Prerequisites

- **Active internet connection**
- **Sudo privileges** for the user
- **Bash 4.0+** minimum
- **Supported Linux distribution**

## 🤝 Contributing

Contributions are welcome! Here's how to contribute:

1. **Fork** the project
2. **Create** a feature branch (`git checkout -b feature/new-distribution`)
3. **Commit** your changes (`git commit -m 'Add support for XYZ'`)
4. **Push** to the branch (`git push origin feature/new-distribution`)
5. **Create** a Pull Request

### Adding a New Distribution

1. Create a folder in `distributions/family-name/`
2. Create an `install.sh` script based on existing templates
3. Add detection in the main script
4. Test on the target distribution

## 📄 License

This project is licensed under MIT. See the [LICENSE](LICENSE) file for more details.

| Author |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:
| [<img src="https://avatars.githubusercontent.com/u/92156365?s=400&u=03e2069751224461782a03ba2dfa57a51c4e5438&v=4" width=115 style="border-radius: 15px;" ><br><sub>@notfound</sub>](https://github.com/N0tFond) <br><br> [![](https://img.shields.io/badge/Portfolio-255E63?style=for-the-badge&logo=About.me&logoColor=white)](https://notfound-dev.vercel.app)

## 🔄 Changelog

### Version 3.0 (October 2025)

- 🔒 **Complete security audit** with detailed report and enhanced configuration
- 🛡️ **Security scripts**: `security-audit.sh` for automated system checks
- 📋 **Improved detection tests** with `test-detection.sh` for multi-distribution validation
- 🔄 **Migration script** `migrate.sh` for smooth version updates
- 📚 **Multilingual documentation** with English README (`EN_README.md`)
- 🔧 **Centralized security configuration** via `security.conf`
- 🧪 **Automated testing** to ensure cross-distribution compatibility
- 🔍 **Vulnerability detection** and security recommendations
- 📊 **Performance metrics** and installation monitoring
- 🛠️ **Optimized common functions** in `common/functions.sh`

### Version 2.0 (September 2024)

- ✨ Complete refactoring with modular architecture
- 🚀 Support for 7 Linux distribution families
- 📊 Improved user interface with progress bars
- 🔧 Optimized configuration per distribution
- 📝 Advanced logging and error handling
- 🧹 Intelligent automatic cleanup
- 🎯 Modular and interactive installation

### Version 1.0 (May 2024)

- 🎉 Initial version for Arch and Debian
- 📦 Basic installation with some applications
- 🐚 Basic ZSH configuration

## ⚠️ Warnings

- **Always test** on a virtual machine before production use
- **Backup** your important data before installation
- **Read** logs in case of errors to diagnose problems
- **Verify** compatibility with your specific distribution version

## 🆘 Support

In case of problems:

1. Check the `installation.log` file
2. Review existing GitHub issues
3. Create a new issue with the error log
4. Specify your exact distribution and version

---

**⭐ Don't hesitate to star the project if it was useful to you!**
