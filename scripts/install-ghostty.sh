#!/bin/bash
# Install Ghostty terminal emulator

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-ghostty]${NC} Checking for Ghostty..."

if command -v ghostty &> /dev/null; then
    echo -e "${GREEN}[install-ghostty]${NC} Ghostty is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-ghostty]${NC} Installing Ghostty..."

# Ghostty installation - check for PPA or use official method
# Add PPA if available, otherwise build from source
if ! apt-cache policy | grep -q ghostty; then
    echo -e "${YELLOW}[install-ghostty]${NC} Adding Ghostty PPA (if available)..."
    # This may need to be updated based on official installation method
    sudo apt update
    sudo apt install -y ghostty || {
        echo -e "${YELLOW}[install-ghostty]${NC} PPA not found, you may need to install manually"
        echo -e "${YELLOW}See:${NC} https://ghostty.org for installation instructions"
        exit 1
    }
else
    sudo apt update
    sudo apt install -y ghostty
fi

echo -e "${GREEN}[install-ghostty]${NC} Ghostty installed successfully!"
