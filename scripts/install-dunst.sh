#!/bin/bash
# Install dunst notification daemon

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-dunst]${NC} Checking for dunst..."

if command -v dunst &> /dev/null; then
    echo -e "${GREEN}[install-dunst]${NC} dunst is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-dunst]${NC} Installing dunst..."
sudo apt update
sudo apt install -y dunst

echo -e "${GREEN}[install-dunst]${NC} dunst installed successfully!"
