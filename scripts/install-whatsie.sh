#!/bin/bash
# Install Whatsie (WhatsApp client) via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-whatsie]${NC} Checking for Whatsie..."

if flatpak list | grep -q com.ktechpit.whatsie; then
    echo -e "${GREEN}[install-whatsie]${NC} Whatsie is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-whatsie]${NC} Installing Whatsie via Flatpak..."

# Ensure Flatpak is set up
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install
flatpak install -y flathub com.ktechpit.whatsie

echo -e "${GREEN}[install-whatsie]${NC} Whatsie installed successfully!"
