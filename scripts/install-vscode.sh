#!/bin/bash
# Install Visual Studio Code from official Microsoft repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-vscode]${NC} Checking for VS Code..."

if command -v code &> /dev/null; then
    echo -e "${GREEN}[install-vscode]${NC} VS Code is already installed ($(code --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-vscode]${NC} Installing VS Code from Microsoft repository..."

# Import Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Install
sudo apt update
sudo apt install -y code

echo -e "${GREEN}[install-vscode]${NC} VS Code installed successfully!"
