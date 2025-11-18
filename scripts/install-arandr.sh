#!/bin/bash
# Install arandr monitor management GUI

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-arandr]${NC} Checking for arandr..."

if command -v arandr &> /dev/null; then
    echo -e "${GREEN}[install-arandr]${NC} arandr is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-arandr]${NC} Installing arandr..."
sudo apt update
sudo apt install -y arandr

echo -e "${GREEN}[install-arandr]${NC} arandr installed successfully!"
