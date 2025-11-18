#!/bin/bash
# Install i3 window manager and related tools

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-i3]${NC} Checking for i3 window manager..."

if command -v i3 &> /dev/null; then
    echo -e "${GREEN}[install-i3]${NC} i3 is already installed ($(i3 --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-i3]${NC} Installing i3 window manager..."
sudo apt update
sudo apt install -y i3 i3blocks i3lock i3status

echo -e "${GREEN}[install-i3]${NC} i3 window manager installed successfully!"
