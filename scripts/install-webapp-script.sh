#!/bin/bash
# Install custom webapp script to ~/.local/bin

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-webapp-script]${NC} Checking for webapp script..."

# Check if webapp script is already in ~/.local/bin
if [ -f "$HOME/.local/bin/webapp" ]; then
    echo -e "${GREEN}[install-webapp-script]${NC} webapp script is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-webapp-script]${NC} Installing webapp script..."

# Create bin directory if it doesn't exist
mkdir -p ~/.local/bin

# The webapp script should be deployed via stow from dotfiles/bin/.local/bin/webapp
# This script just ensures it's executable
if [ -f "$HOME/.local/bin/webapp" ]; then
    chmod +x ~/.local/bin/webapp
    echo -e "${GREEN}[install-webapp-script]${NC} webapp script installed successfully!"
else
    echo -e "${YELLOW}[install-webapp-script]${NC} webapp script not found. It should be deployed via stow."
    echo -e "${YELLOW}Note:${NC} Run the stow-dotfiles.sh script to deploy it."
fi
