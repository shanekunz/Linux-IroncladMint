#!/bin/bash
# Install nitrogen wallpaper manager

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-nitrogen]${NC} Checking for nitrogen..."

if command -v nitrogen &> /dev/null; then
    echo -e "${GREEN}[install-nitrogen]${NC} nitrogen is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-nitrogen]${NC} Installing nitrogen..."
sudo apt update
sudo apt install -y nitrogen

echo -e "${GREEN}[install-nitrogen]${NC} nitrogen installed successfully!"
