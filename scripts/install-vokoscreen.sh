#!/bin/bash
# Install vokoscreen-ng screen recorder

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-vokoscreen]${NC} Checking for vokoscreen-ng..."

if command -v vokoscreenNG &> /dev/null; then
    echo -e "${GREEN}[install-vokoscreen]${NC} vokoscreen-ng is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-vokoscreen]${NC} Installing vokoscreen-ng..."
sudo apt update
sudo apt install -y vokoscreen-ng

echo -e "${GREEN}[install-vokoscreen]${NC} vokoscreen-ng installed successfully!"
