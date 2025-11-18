#!/bin/bash
# Install network-manager-applet

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-nm-applet]${NC} Checking for nm-applet..."

if command -v nm-applet &> /dev/null; then
    echo -e "${GREEN}[install-nm-applet]${NC} nm-applet is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-nm-applet]${NC} Installing network-manager-applet..."
sudo apt update
sudo apt install -y network-manager-gnome

echo -e "${GREEN}[install-nm-applet]${NC} network-manager-applet installed successfully!"
