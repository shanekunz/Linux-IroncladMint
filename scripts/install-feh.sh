#!/bin/bash
# Install feh image viewer (used by nitrogen)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-feh]${NC} Checking for feh..."

if command -v feh &> /dev/null; then
    echo -e "${GREEN}[install-feh]${NC} feh is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-feh]${NC} Installing feh..."
sudo apt update
sudo apt install -y feh

echo -e "${GREEN}[install-feh]${NC} feh installed successfully!"
