#!/bin/bash
# Install Discord from official .deb package

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-discord]${NC} Checking for Discord..."

if command -v discord &> /dev/null; then
    echo -e "${GREEN}[install-discord]${NC} Discord is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-discord]${NC} Installing Discord from official .deb package..."

# Download latest Discord .deb
cd /tmp
wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"

# Install
sudo apt install -y ./discord.deb

# Cleanup
rm discord.deb

echo -e "${GREEN}[install-discord]${NC} Discord installed successfully!"
