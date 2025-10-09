#!/bin/bash

# Migration script to clean up old structure and show new structure
# This script helps transition from v1 to v2

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

echo -e "${CYAN}🔄 Migration from v1.0 to v2.0${NC}"
echo "================================"
echo

echo -e "${BLUE}Nouvelle structure créée:${NC}"
echo "📁 install.sh                    - Script principal avec détection auto"
echo "📁 common/functions.sh          - Fonctions communes partagées" 
echo "📁 distributions/"
echo "   ├── debian/install.sh         - Ubuntu, Debian, Mint, etc."
echo "   ├── arch/install.sh           - Arch, Manjaro, EndeavourOS, etc."
echo "   ├── redhat/install.sh         - Fedora, CentOS, RHEL, etc."
echo "   ├── gentoo/install.sh         - Gentoo Linux"
echo "   ├── alpine/install.sh         - Alpine Linux"
echo "   ├── void/install.sh           - Void Linux"
echo "   └── nixos/install.sh          - NixOS"
echo "📁 test-detection.sh            - Script de test de détection"
echo "📁 README_V2.md                 - Documentation mise à jour"
echo

echo -e "${YELLOW}Anciens fichiers détectés:${NC}"
if [[ -f "./Arch_install.sh" ]]; then
    echo "❗ Arch_install.sh (remplacé par distributions/arch/install.sh)"
fi
if [[ -f "./DEBIAN_Version/Deb_install.sh" ]]; then
    echo "❗ DEBIAN_Version/Deb_install.sh (remplacé par distributions/debian/install.sh)"
fi

echo
echo -e "${GREEN}✨ Améliorations de la v2.0:${NC}"
echo "• 🔍 Détection automatique de distribution"
echo "• 📦 Support de 7+ familles de distributions"
echo "• 🎯 Installation modulaire et interactive"  
echo "• 📊 Interface améliorée avec barres de progression"
echo "• 🔧 Configuration optimisée par distribution"
echo "• 📝 Logging avancé et gestion d'erreurs"
echo "• 🧹 Nettoyage automatique intelligent"
echo

echo -e "${BLUE}🚀 Pour utiliser la nouvelle version:${NC}"
echo "1. Testez la détection:  ./test-detection.sh"
echo "2. Lancez l'installation: ./install.sh"
echo "3. Ou directement:       ./distributions/FAMILLE/install.sh DISTRO"
echo

read -p "Voulez-vous supprimer les anciens fichiers? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Nettoyage des anciens fichiers...${NC}"
    
    # Create secure backup directory
    local backup_dir="./backups"
    mkdir -p "$backup_dir"
    chmod 700 "$backup_dir"
    
    # Backup first with timestamp
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [[ -f "./Arch_install.sh" ]]; then
        if cp "./Arch_install.sh" "$backup_dir/Arch_install.sh.backup.$timestamp" 2>/dev/null; then
            echo "✅ Backup créé: $backup_dir/Arch_install.sh.backup.$timestamp"
        else
            error "Failed to create backup for Arch_install.sh"
            exit 1
        fi
    fi
    
    if [[ -f "./DEBIAN_Version/Deb_install.sh" ]]; then
        if cp "./DEBIAN_Version/Deb_install.sh" "$backup_dir/Deb_install.sh.backup.$timestamp" 2>/dev/null; then
            echo "✅ Backup créé: $backup_dir/Deb_install.sh.backup.$timestamp"
        else
            error "Failed to create backup for DEBIAN_Version/Deb_install.sh"
            exit 1
        fi
    fi
    
    # Remove old files (keeping backups)
    if [[ -f "./Arch_install.sh" ]]; then
        rm -f "./Arch_install.sh" 2>/dev/null || true
        echo "🗑️  Supprimé: Arch_install.sh"
    fi
    
    # Keep DEBIAN_Version folder but could be removed later manually
    echo "ℹ️  DEBIAN_Version/ conservé (supprimez manuellement si désiré)"
    
    echo -e "${GREEN}✅ Nettoyage terminé!${NC}"
else
    echo "ℹ️  Anciens fichiers conservés"
fi

echo
echo -e "${GREEN}🎉 Migration terminée! Prêt à utiliser la v2.0${NC}"
