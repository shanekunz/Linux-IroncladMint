#!/bin/bash
# Install Sunshine game streaming server

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-sunshine]${NC} Checking for Sunshine..."

if command -v sunshine &> /dev/null; then
    echo -e "${GREEN}[install-sunshine]${NC} Sunshine is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-sunshine]${NC} Installing Sunshine..."

# Install from GitHub releases (latest .deb)
cd /tmp
SUNSHINE_VERSION=$(curl -s "https://api.github.com/repos/LizardByte/Sunshine/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
wget "https://github.com/LizardByte/Sunshine/releases/download/v${SUNSHINE_VERSION}/sunshine-ubuntu-22.04-amd64.deb"

sudo apt install -y "./sunshine-ubuntu-22.04-amd64.deb"
rm sunshine-ubuntu-22.04-amd64.deb

echo -e "${GREEN}[install-sunshine]${NC} Sunshine installed successfully!"
