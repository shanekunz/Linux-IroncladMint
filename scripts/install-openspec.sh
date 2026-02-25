#!/bin/bash
# Install OpenSpec - Spec-driven development for AI coding assistants
# https://github.com/Fission-AI/OpenSpec
# Requires: Node.js (install-mise.sh installs node@lts)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-openspec]${NC} Checking for openspec..."

# Ensure user-local bins and mise shims are available
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[install-openspec]${NC} npm not found. Please run install-mise.sh first to install Node.js"
    exit 1
fi

# Check if already installed and working
if command -v openspec &> /dev/null; then
    if OPENSPEC_VERSION=$(openspec --version 2>/dev/null); then
        echo -e "${GREEN}[install-openspec]${NC} openspec is already installed: $OPENSPEC_VERSION"
        exit 0
    fi

    echo -e "${YELLOW}[install-openspec]${NC} openspec is on PATH but not working. Reinstalling..."
fi

echo -e "${YELLOW}[install-openspec]${NC} Installing openspec via npm..."

npm install -g @fission-ai/openspec@latest

# Refresh shims for mise-managed Node installations
if command -v mise &> /dev/null; then
    mise reshim || true
fi

# Verify installation
if command -v openspec &> /dev/null && OPENSPEC_VERSION=$(openspec --version 2>/dev/null); then
    echo -e "${GREEN}[install-openspec]${NC} openspec installed successfully: $OPENSPEC_VERSION"
    echo -e "${YELLOW}[install-openspec]${NC} Run 'openspec init' in your project to get started"
else
    echo -e "${RED}[install-openspec]${NC} Installation failed"
    echo -e "${YELLOW}[install-openspec]${NC} npm prefix: $(npm config get prefix 2>/dev/null || echo unknown)"
    exit 1
fi
