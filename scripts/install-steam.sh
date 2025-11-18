#!/bin/bash
# Install Steam gaming platform

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-steam]${NC} Checking for Steam..."

if command -v steam &> /dev/null; then
    echo -e "${GREEN}[install-steam]${NC} Steam is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-steam]${NC} Installing Steam..."

# Enable multiverse repository (for Steam)
sudo add-apt-repository -y multiverse
sudo apt update
sudo apt install -y steam-installer

echo -e "${GREEN}[install-steam]${NC} Steam installed successfully!"
