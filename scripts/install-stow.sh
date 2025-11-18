#!/bin/bash
# Install GNU Stow for dotfiles management

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[install-stow]${NC} Checking for GNU Stow..."

# Check if stow is already installed
if command -v stow &> /dev/null; then
    echo -e "${GREEN}[install-stow]${NC} GNU Stow is already installed ($(stow --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-stow]${NC} Installing GNU Stow..."
sudo apt update
sudo apt install -y stow

echo -e "${GREEN}[install-stow]${NC} GNU Stow installed successfully!"
