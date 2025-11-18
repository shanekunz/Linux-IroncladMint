#!/bin/bash
# Install Discord via Flatpak for automatic updates

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-discord]${NC} Checking for Discord..."

if flatpak list | grep -q "com.discordapp.Discord"; then
    echo -e "${GREEN}[install-discord]${NC} Discord is already installed (Flatpak)"
    exit 0
fi

echo -e "${YELLOW}[install-discord]${NC} Installing Discord via Flatpak..."

flatpak install -y flathub com.discordapp.Discord

echo -e "${GREEN}[install-discord]${NC} Discord installed successfully!"
