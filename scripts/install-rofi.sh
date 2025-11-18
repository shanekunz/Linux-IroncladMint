#!/bin/bash
# Install rofi application launcher

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-rofi]${NC} Checking for rofi..."

if command -v rofi &> /dev/null; then
    echo -e "${GREEN}[install-rofi]${NC} rofi is already installed ($(rofi -version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-rofi]${NC} Installing rofi..."
sudo apt update
sudo apt install -y rofi

echo -e "${GREEN}[install-rofi]${NC} rofi installed successfully!"
