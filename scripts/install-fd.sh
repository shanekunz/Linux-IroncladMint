#!/bin/bash
# Install fd - fast file finder for LazyVim

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-fd]${NC} Checking for fd..."

if command -v fd &> /dev/null; then
    echo -e "${GREEN}[install-fd]${NC} fd is already installed ($(fd --version))"
    exit 0
fi

echo -e "${YELLOW}[install-fd]${NC} Installing fd-find..."
sudo apt update
sudo apt install -y fd-find

# Create symlink from fdfind to fd (Ubuntu/Debian ships it as fdfind)
if [ ! -e ~/.local/bin/fd ]; then
    echo -e "${YELLOW}[install-fd]${NC} Creating symlink fd -> fdfind..."
    mkdir -p ~/.local/bin
    ln -s $(which fdfind) ~/.local/bin/fd
fi

echo -e "${GREEN}[install-fd]${NC} fd installed successfully!"
