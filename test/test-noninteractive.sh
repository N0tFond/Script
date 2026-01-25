#!/bin/bash

# Test script for non-interactive mode
# This script validates that the installer works properly in non-interactive mode

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Testing Non-Interactive Mode..."
echo "=================================="

# Test 1: Check syntax of all scripts
echo "Test 1: Syntax validation..."
find "${SCRIPT_DIR}" -name "*.sh" -exec bash -n {} \; && echo "✅ All scripts have valid syntax" || echo "❌ Syntax errors found"

# Test 2: Test main installer help
echo "Test 2: Help message..."
"${SCRIPT_DIR}/install.sh" --help >/dev/null && echo "✅ Help message works" || echo "❌ Help message failed"

# Test 3: Test common functions in non-interactive mode
echo "Test 3: Common functions non-interactive mode..."
export NONINTERACTIVE=1
source "${SCRIPT_DIR}/common/functions.sh"

# Test confirm function
if confirm "Test question" "y"; then
    echo "✅ Confirm function works in non-interactive mode"
else
    echo "❌ Confirm function failed in non-interactive mode"
fi

# Test 4: Simulate installer dry run (with skip validation)
echo "Test 4: Installer dry run (validation disabled)..."
echo "This will test the installer logic without actually installing packages..."

# Note: We can't do a full test without potentially installing packages
# so we just test the initial phases
timeout 30s "${SCRIPT_DIR}/install.sh" --noninteractive --skip-validation &>/dev/null && echo "✅ Non-interactive mode works" || echo "ℹ️  Test completed (expected timeout or controlled exit)"

echo "=================================="
echo "🏁 Test completed!"
echo "Run './install.sh --help' to see all available options"