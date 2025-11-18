#!/bin/bash
# Install NVM (Node Version Manager)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-nvm]${NC} Checking for NVM..."

# Check if NVM is already installed
if [ -d "$HOME/.nvm" ]; then
    echo -e "${GREEN}[install-nvm]${NC} NVM is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-nvm]${NC} Installing NVM from official install script..."

# Download and run NVM install script
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo -e "${GREEN}[install-nvm]${NC} NVM installed successfully!"
echo -e "${YELLOW}Note:${NC} Restart your shell or run: source ~/.bashrc"
