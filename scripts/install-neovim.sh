#!/bin/bash
# Install latest Neovim from official PPA

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-neovim]${NC} Checking for Neovim..."

if command -v nvim &> /dev/null; then
    echo -e "${GREEN}[install-neovim]${NC} Neovim is already installed ($(nvim --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-neovim]${NC} Installing Neovim from official PPA..."

# Add Neovim unstable PPA for latest version
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim

# Install Python support
sudo apt install -y python3-neovim

# Install xsel for clipboard support (required for clipboard = "unnamedplus")
sudo apt install -y xsel

echo -e "${GREEN}[install-neovim]${NC} Neovim installed successfully!"
