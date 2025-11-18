#!/bin/bash
# Install RetroArch emulator

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-retroarch]${NC} Checking for RetroArch..."

if command -v retroarch &> /dev/null; then
    echo -e "${GREEN}[install-retroarch]${NC} RetroArch is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-retroarch]${NC} Installing RetroArch..."

sudo apt update
sudo apt install -y retroarch

echo -e "${GREEN}[install-retroarch]${NC} RetroArch installed successfully!"
