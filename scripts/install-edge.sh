#!/bin/bash
# Install Microsoft Edge from official repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-edge]${NC} Checking for Microsoft Edge..."

if command -v microsoft-edge &> /dev/null; then
    echo -e "${GREEN}[install-edge]${NC} Microsoft Edge is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-edge]${NC} Installing Microsoft Edge from official repository..."

# Import Microsoft GPG key
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
rm microsoft.gpg

# Install
sudo apt update
sudo apt install -y microsoft-edge-stable

echo -e "${GREEN}[install-edge]${NC} Microsoft Edge installed successfully!"
