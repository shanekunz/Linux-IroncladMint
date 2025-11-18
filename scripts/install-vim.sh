#!/bin/bash
# Install Vim editor (backup editor)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-vim]${NC} Checking for Vim..."

if command -v vim &> /dev/null; then
    echo -e "${GREEN}[install-vim]${NC} Vim is already installed ($(vim --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-vim]${NC} Installing Vim..."
sudo apt update
sudo apt install -y vim

echo -e "${GREEN}[install-vim]${NC} Vim installed successfully!"
