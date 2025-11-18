#!/bin/bash
# Install blueman bluetooth manager

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-blueman]${NC} Checking for blueman..."

if command -v blueman-applet &> /dev/null; then
    echo -e "${GREEN}[install-blueman]${NC} blueman is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-blueman]${NC} Installing blueman..."
sudo apt update
sudo apt install -y blueman

echo -e "${GREEN}[install-blueman]${NC} blueman installed successfully!"
