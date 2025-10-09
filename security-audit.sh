#!/bin/bash

# Security Audit Script for Universal Linux Installer
# This script performs security checks on the installation scripts

# Display header in terminal at script start
echo -e "${PURPLE:-\033[0;35m}"
echo "╔═════════════════════════════════════════════════════════════════════════════╗"
echo "║                        🚀 Universal Linux Installer 🚀                      ║"
echo "╠═════════════════════════════════════════════════════════════════════════════╣"
echo "║  📋 Author  : NotFond                                                       ║"
echo "║  📌 Version : 2.0                                                           ║"
echo "║  📅 Date    : September 2024                                                ║"
echo "║  🔒 LICENSE : MIT                                                           ║"
echo "║  🌟 Description: Auto-detects Linux distribution and runs appropriate       ║"
echo "║                  installation script                                        ║"
echo "║                                                                             ║"
echo "║              _   ______ ______   __________  __  ___   ______               ║"
echo "║             / | / / __ /_  __/  / ____/ __ \/ / / / | / / __ \              ║"
echo "║            /  |/ / / / // /    / /_  / / / / / / /  |/ / / / /              ║"
echo "║           / /|  / /_/ // /    / __/ / /_/ / /_/ / /|  / /_/ /               ║"
echo "║          /_/ |_/\____//_/    /_/    \____/\____/_/ |_/_____/                ║"
echo "║                                                                             ║"
echo "╚═════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC:-\033[0m}"
echo

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly AUDIT_LOG="${SCRIPT_DIR}/security-audit.log"

# Utility functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}" | tee -a "$AUDIT_LOG"
}

error() {
    echo -e "${RED}[ERROR] $*${NC}" | tee -a "$AUDIT_LOG" >&2
}

warn() {
    echo -e "${YELLOW}[WARNING] $*${NC}" | tee -a "$AUDIT_LOG"
}

info() {
    echo -e "${CYAN}[INFO] $*${NC}" | tee -a "$AUDIT_LOG"
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}" | tee -a "$AUDIT_LOG"
}

# Initialize audit log
echo "=== Security Audit Started: $(date) ===" > "$AUDIT_LOG"
echo "Audit Script: $0" >> "$AUDIT_LOG"
echo "Working Directory: $(pwd)" >> "$AUDIT_LOG"
echo "=======================================" >> "$AUDIT_LOG"

# Print banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔═════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🔒 Security Audit Tool 🔒                          ║"
    echo "╠═════════════════════════════════════════════════════════════════════════════╣"
    echo "║  Checking security vulnerabilities in Universal Linux Installer scripts     ║"
    echo "╚═════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check for insecure patterns
check_insecure_patterns() {
    info "Checking for insecure coding patterns..."
    local issues=0
    
    # Find all shell scripts
    local scripts
    mapfile -t scripts < <(find "$SCRIPT_DIR" -name "*.sh" -type f)
    
    for script in "${scripts[@]}"; do
        info "Auditing: $(basename "$script")"
        
        # Check for dangerous commands
        if grep -Hn "curl.*|.*bash\|wget.*|.*bash\|sh.*<(" "$script" 2>/dev/null; then
            warn "Found dangerous pipe-to-shell pattern in $script"
            ((issues++))
        fi
        
        # Check for unquoted variables
        if grep -Hn '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$script" 2>/dev/null | grep -v '# ' | head -5; then
            warn "Found potentially unquoted variables in $script"
            ((issues++))
        fi
        
        # Check for missing input validation
        if grep -Hn "read.*-p" "$script" | grep -v "validate\|check" 2>/dev/null; then
            warn "Found user input without apparent validation in $script"
            ((issues++))
        fi
        
        # Check for hardcoded credentials
        if grep -iHn "password\|secret\|key.*=" "$script" | grep -v "SSH" 2>/dev/null; then
            error "Potential hardcoded credentials found in $script"
            ((issues++))
        fi
        
        # Check for unsafe temp file usage
        if grep -Hn "mktemp.*\$\$\|/tmp/.*\$\$" "$script" 2>/dev/null; then
            warn "Potentially unsafe temporary file usage in $script"
            ((issues++))
        fi
        
        # Check for eval usage
        if grep -Hn "eval\|exec.*\$" "$script" 2>/dev/null; then
            error "Dangerous eval/exec usage found in $script"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        success "No obvious insecure patterns found"
    else
        error "Found $issues potential security issues"
    fi
    
    return $issues
}

# Check file permissions
check_file_permissions() {
    info "Checking file permissions..."
    local issues=0
    
    # Check for world-writable files
    local writable_files
    if writable_files=$(find "$SCRIPT_DIR" -type f -perm -o+w 2>/dev/null); then
        if [[ -n "$writable_files" ]]; then
            error "World-writable files found:"
            echo "$writable_files" | tee -a "$AUDIT_LOG"
            ((issues++))
        fi
    fi
    
    # Check for executable files without proper extension
    local executable_files
    if executable_files=$(find "$SCRIPT_DIR" -type f -executable ! -name "*.sh" 2>/dev/null); then
        if [[ -n "$executable_files" ]]; then
            warn "Executable files without .sh extension found:"
            echo "$executable_files" | tee -a "$AUDIT_LOG"
        fi
    fi
    
    if [[ $issues -eq 0 ]]; then
        success "File permissions are secure"
    else
        error "Found $issues permission issues"
    fi
    
    return $issues
}

# Check for outdated dependencies
check_dependencies() {
    info "Checking for potentially outdated dependencies..."
    local issues=0
    
    # Check NVM version
    local nvm_version
    nvm_version=$(grep -o 'NVM_VERSION="[^"]*"' "$SCRIPT_DIR/common/functions.sh" | cut -d'"' -f2)
    info "Current NVM version in script: $nvm_version"
    
    # Check Node.js version
    local node_version
    node_version=$(grep -o 'NODE_VERSION="[^"]*"' "$SCRIPT_DIR/common/functions.sh" | cut -d'"' -f2)
    info "Current Node.js version in script: $node_version"
    
    # These should be updated regularly
    info "Remember to check if these versions are current and secure"
    
    return $issues
}

# Check for proper error handling
check_error_handling() {
    info "Checking error handling..."
    local issues=0
    
    local scripts
    mapfile -t scripts < <(find "$SCRIPT_DIR" -name "*.sh" -type f)
    
    for script in "${scripts[@]}"; do
        # Check for set -e
        if ! grep -q "set.*-.*e" "$script"; then
            warn "Script $script missing 'set -e' for error handling"
            ((issues++))
        fi
        
        # Check for set -u
        if ! grep -q "set.*-.*u" "$script"; then
            warn "Script $script missing 'set -u' for undefined variable handling"
            ((issues++))
        fi
        
        # Check for set -o pipefail
        if ! grep -q "set.*-.*o pipefail\|set -euo pipefail" "$script"; then
            warn "Script $script missing 'set -o pipefail' for pipeline error handling"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        success "Error handling appears adequate"
    else
        warn "Found $issues error handling issues"
    fi
    
    return $issues
}

# Check for secure defaults
check_secure_defaults() {
    info "Checking for secure defaults..."
    local issues=0
    
    # Check if scripts require confirmation for destructive actions
    if ! grep -r "confirm.*[Dd]elete\|confirm.*[Rr]emove\|confirm.*[Cc]lean" "$SCRIPT_DIR" >/dev/null; then
        warn "Some destructive operations may not require user confirmation"
        ((issues++))
    fi
    
    # Check for automatic yes responses
    if grep -r "\-y\|--yes\|--assume-yes" "$SCRIPT_DIR/distributions" | grep -v "confirm" >/dev/null; then
        info "Found automatic yes responses (review if appropriate)"
    fi
    
    if [[ $issues -eq 0 ]]; then
        success "Secure defaults appear to be in place"
    else
        warn "Found $issues potential issues with defaults"
    fi
    
    return $issues
}

# Generate security report
generate_report() {
    local total_issues=$1
    
    echo "" | tee -a "$AUDIT_LOG"
    echo "=== SECURITY AUDIT SUMMARY ===" | tee -a "$AUDIT_LOG"
    echo "Audit completed: $(date)" | tee -a "$AUDIT_LOG"
    echo "Total potential issues found: $total_issues" | tee -a "$AUDIT_LOG"
    
    if [[ $total_issues -eq 0 ]]; then
        success "🎉 No major security issues found!"
        echo "The scripts appear to follow security best practices." | tee -a "$AUDIT_LOG"
    elif [[ $total_issues -lt 5 ]]; then
        warn "⚠️  Found $total_issues potential security issues (minor)"
        echo "Review the warnings above and consider implementing fixes." | tee -a "$AUDIT_LOG"
    else
        error "🚨 Found $total_issues potential security issues (major)"
        echo "Several security issues detected. Please review and fix before deployment." | tee -a "$AUDIT_LOG"
    fi
    
    echo "" | tee -a "$AUDIT_LOG"
    echo "Detailed audit log saved to: $AUDIT_LOG" | tee -a "$AUDIT_LOG"
    
    return $total_issues
}

# Main audit function
main() {
    print_banner
    
    log "Starting security audit of Universal Linux Installer..."
    
    local total_issues=0
    
    # Run all security checks
    check_insecure_patterns
    total_issues=$((total_issues + $?))
    
    check_file_permissions
    total_issues=$((total_issues + $?))
    
    check_dependencies
    total_issues=$((total_issues + $?))
    
    check_error_handling
    total_issues=$((total_issues + $?))
    
    check_secure_defaults
    total_issues=$((total_issues + $?))
    
    # Generate report
    generate_report $total_issues
    
    exit $total_issues
}

# Run main function
main "$@"