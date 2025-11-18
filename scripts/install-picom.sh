#!/bin/bash
# Install picom compositor

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-picom]${NC} Checking for picom..."

if command -v picom &> /dev/null; then
    echo -e "${GREEN}[install-picom]${NC} picom is already installed ($(picom --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-picom]${NC} Installing picom..."
sudo apt update
sudo apt install -y picom

echo -e "${GREEN}[install-picom]${NC} picom installed successfully!"
