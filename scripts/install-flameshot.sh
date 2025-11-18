#!/bin/bash
# Install flameshot screenshot tool

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-flameshot]${NC} Checking for flameshot..."

if command -v flameshot &> /dev/null; then
    echo -e "${GREEN}[install-flameshot]${NC} flameshot is already installed ($(flameshot --version))"
    exit 0
fi

echo -e "${YELLOW}[install-flameshot]${NC} Installing flameshot..."
sudo apt update
sudo apt install -y flameshot

echo -e "${GREEN}[install-flameshot]${NC} flameshot installed successfully!"
