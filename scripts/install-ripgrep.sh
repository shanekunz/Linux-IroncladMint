#!/bin/bash
# Install ripgrep (rg) - fast search tool for LazyVim

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-ripgrep]${NC} Checking for ripgrep..."

if command -v rg &> /dev/null; then
    echo -e "${GREEN}[install-ripgrep]${NC} ripgrep is already installed ($(rg --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-ripgrep]${NC} Installing ripgrep..."
sudo apt update
sudo apt install -y ripgrep

echo -e "${GREEN}[install-ripgrep]${NC} ripgrep installed successfully!"
