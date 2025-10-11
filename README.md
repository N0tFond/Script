# 🚀 Universal Linux Installer

Un script d'installation universel et optimisé pour les distributions Linux, supportant une large gamme de familles de distributions avec détection automatique.

## ✨ Fonctionnalités

- 🔍 **Détection automatique** de la distribution Linux
- 📦 **Support multi-distribution** avec scripts spécialisés
- 🎯 **Installation modulaire** avec sélection interactive des paquets
- 🛠️ **Configuration optimisée** pour chaque gestionnaire de paquets
- 📊 **Barres de progression** et logging détaillé
- 🔧 **Environnement de développement** complet
- 🐚 **Configuration ZSH** avec Oh My Zsh
- 📝 **Logging complet** pour debugging
- 🧹 **Nettoyage automatique** du système

## 🏗️ Structure du Projet

```
├── install.sh                    # Script principal avec détection auto
├── common/
│   └── functions.sh              # Fonctions communes partagées
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

## 🐧 Distributions Supportées

### Famille Debian

- **Ubuntu** (toutes versions)
- **Debian** (stable, testing, unstable)
- **Linux Mint**
- **Elementary OS**
- **Pop!\_OS**
- **Kali Linux**
- **Parrot Security OS**

### Famille Arch

- **Arch Linux**
- **Manjaro**
- **EndeavourOS**
- **ArcoLinux**
- **Garuda Linux**
- **Artix Linux**

### Famille Red Hat

- **Fedora**
- **CentOS**
- **Red Hat Enterprise Linux (RHEL)**
- **Rocky Linux**
- **AlmaLinux**
- **OpenSUSE**

### Autres Distributions

- **Gentoo Linux** - Compilation depuis les sources
- **Alpine Linux** - Distribution légère basée sur musl
- **Void Linux** - Rolling release avec runit
- **NixOS** - Configuration déclarative

## 🚀 Installation Rapide

### Utilisation Simple

```bash
# Cloner le repository
git clone https://github.com/N0tFond/Script.git
cd Script

# Rendre le script exécutable
chmod +x install.sh

# Lancer l'installation (le script détecte automatiquement votre distribution)
./install.sh
```

### Installation Spécifique

Si vous voulez forcer une distribution spécifique :

```bash
# Pour Ubuntu/Debian
./distributions/debian/install.sh ubuntu

# Pour Arch Linux
./distributions/arch/install.sh arch

# Pour Fedora
./distributions/redhat/install.sh fedora
```

## ⚠️ Avertissements Critiques

> [!IMPORTANT] > **Distribution non détectée** : Si le script échoue à identifier votre distribution Linux, l'installation se terminera immédiatement avec un code d'erreur.

### 🔍 Résolution des Problèmes de Détection

> [!WARNING] > **Échec de détection automatique** peut survenir sur des distributions personnalisées ou très récentes.

**Solutions recommandées :**

1. **Vérification de compatibilité**

   ```bash
   # Vérifier votre distribution
   cat /etc/os-release
   ```

2. **Installation forcée** pour distributions compatibles

   ```bash
   # Distribution basée Debian (Ubuntu, Mint, Elementary, etc.)
   ./distributions/debian/install.sh ubuntu

   # Distribution basée Arch (Manjaro, EndeavourOS, etc.)
   ./distributions/arch/install.sh arch

   # Distribution basée Red Hat (Fedora, CentOS, etc.)
   ./distributions/redhat/install.sh fedora
   ```

3. **Support technique**

   > [!NOTE]
   > Créez une issue GitHub avec les informations suivantes :
   >
   > - Sortie de `cat /etc/os-release`
   > - Version du kernel (`uname -r`)
   > - Messages d'erreur complets

### 🛡️ Recommandations de Sécurité

> [!CAUTION] > **Tests obligatoires** : Toujours tester sur une machine virtuelle avant déploiement en production.

- **Sauvegarde complète** des données critiques
- **Point de restauration** système si disponible
- **Vérification des privilèges** sudo avant exécution
- **Connexion internet stable** requise pendant l'installation

> [!TIP] > **Mode debug** : Ajoutez `bash -x` pour un diagnostic détaillé
>
> ```bash
> bash -x ./install.sh
> ```
>
> ---

## 📦 Paquets Installés

### Paquets de Base

- **Outils système** : git, curl, wget, htop, tree, unzip
- **Shell** : zsh avec Oh My Zsh
- **Informations système** : neofetch

### Outils de Développement

- **Node.js** via NVM (version 22)
- **Python 3** avec pip
- **Compilateurs** : gcc, make, build-essential
- **Git** avec configuration interactive

### Applications

- **Éditeur** : Visual Studio Code
- **Navigateurs** : Firefox, Chrome
- **Média** : VLC, Spotify
- **Communication** : Discord
- **Productivité** : LibreOffice
- **Graphisme** : GIMP

### Gestionnaires de Paquets Alternatifs

- **Flatpak** avec Flathub
- **Snap** (Ubuntu)
- **AUR helpers** (Arch - yay)

## 🔧 Fonctionnalités par Distribution

### Debian/Ubuntu

- Configuration des dépôts officiels et tiers
- Support PPA et dépôts externes
- Installation via APT, Flatpak et Snap

### Arch Linux

- Configuration Pacman optimisée
- Installation AUR helper (yay)
- Gestion des services avec systemd
- Nettoyage automatique des paquets orphelins

### Fedora/RHEL

- Configuration RPM Fusion
- Gestion des référentiels EPEL
- Support SELinux
- Configuration firewalld

### Gentoo

- Optimisation Portage (MAKEOPTS, USE flags)
- Gestion des overlays avec Layman
- Services OpenRC
- Compilation parallèle optimisée

### Alpine

- Compatibilité glibc pour applications
- Gestion légère des paquets
- Services OpenRC
- Optimisations musl libc

### Void Linux

- Configuration XBPS optimisée
- Services runit
- Dépôts multilib et non-free
- Gestion cache intelligente

### NixOS

- Configuration déclarative
- Home-manager setup
- Flakes support
- Garbage collection automatique

## ⚙️ Options de Configuration

Le script propose plusieurs niveaux de personnalisation :

### Installation Interactive

- Sélection des catégories de paquets
- Choix des applications individuelles
- Configuration des services système
- Optimisations spécifiques à la distribution

### Configuration Automatisée

- Variables d'environnement pré-définies
- Scripts de configuration par défaut
- Nettoyage automatique post-installation

## 📝 Logging et Debugging

- **Fichier de log** : `installation.log` dans le répertoire du script
- **Codes de couleur** pour une meilleure lisibilité
- **Gestion d'erreurs** complète avec rollback
- **Progress bars** pour les opérations longues

## 🛡️ Sécurité

- **Vérification des privilèges** : Le script refuse de s'exécuter en root
- **Validation des entrées** utilisateur
- **Vérification des signatures** des dépôts
- **Backup automatique** des configurations système

## 🚨 Prérequis

- **Connexion internet** active
- **Privilèges sudo** pour l'utilisateur
- **Bash 4.0+** minimum
- **Distribution Linux supportée**

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment contribuer :

1. **Fork** le projet
2. **Créer** une branche feature (`git checkout -b feature/nouvelle-distribution`)
3. **Commit** vos changements (`git commit -m 'Ajout support pour XYZ'`)
4. **Push** vers la branche (`git push origin feature/nouvelle-distribution`)
5. **Créer** une Pull Request

### Ajouter une Nouvelle Distribution

1. Créer un dossier dans `distributions/nom-famille/`
2. Créer un script `install.sh` basé sur les templates existants
3. Ajouter la détection dans le script principal
4. Tester sur la distribution cible

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👤 Auteur

**NotFond**

- GitHub : [@N0tFond](https://github.com/N0tFond)
- Version : 2.0
- Date : Septembre 2024

## 🔄 Changelog

### Version 2.0 (Septembre 2024)

- ✨ Refactorisation complète avec architecture modulaire
- 🚀 Support de 7 familles de distributions Linux
- 📊 Interface utilisateur améliorée avec progress bars
- 🔧 Configuration optimisée par distribution
- 📝 Logging avancé et gestion d'erreurs
- 🧹 Nettoyage automatique intelligent
- 🎯 Installation modulaire et interactive

### Version 1.0 (Mai 2024)

- 🎉 Version initiale pour Arch et Debian
- 📦 Installation de base avec quelques applications
- 🐚 Configuration ZSH basique

## ⚠️ Avertissements

- **Testez toujours** sur une machine virtuelle avant utilisation en production
- **Sauvegardez** vos données importantes avant installation
- **Lisez** les logs en cas d'erreur pour diagnostiquer les problèmes
- **Vérifiez** la compatibilité avec votre version spécifique de distribution

## 🆘 Support

En cas de problème :

1. Consultez le fichier `installation.log`
2. Vérifiez les issues GitHub existantes
3. Créez une nouvelle issue avec le log d'erreur
4. Spécifiez votre distribution et version exacte

---

**⭐ N'hésitez pas à star le projet si il vous a été utile !**
