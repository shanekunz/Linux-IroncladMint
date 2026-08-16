#!/bin/bash
# Install OpenCode - AI coding agent for the terminal
# https://opencode.ai

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-opencode]${NC} Checking for opencode..."

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$PATH"

if command -v opencode &> /dev/null; then
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "installed")
    echo -e "${YELLOW}[install-opencode]${NC} Updating opencode from: $OPENCODE_VERSION"
    opencode upgrade --method curl
    echo -e "${GREEN}[install-opencode]${NC} opencode is now: $(opencode --version 2>/dev/null || echo "installed")"
    exit 0
fi

echo -e "${YELLOW}[install-opencode]${NC} Installing opencode via official installer..."

# Install using official installer
curl -fsSL https://opencode.ai/install | bash

# Add to PATH if not already there (installer usually handles this)
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Verify installation
if command -v opencode &> /dev/null; then
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "installed")
    echo -e "${GREEN}[install-opencode]${NC} opencode installed successfully: $OPENCODE_VERSION"
    echo -e "${YELLOW}[install-opencode]${NC} Run 'opencode auth login' to configure your AI provider"
else
    echo -e "${RED}[install-opencode]${NC} Installation failed - opencode not found in PATH"
    echo -e "${YELLOW}[install-opencode]${NC} Try restarting your terminal or run: source ~/.bashrc"
    exit 1
fi
