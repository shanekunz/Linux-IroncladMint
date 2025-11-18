#!/bin/bash
# Install LocalSend file sharing via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-localsend]${NC} Checking for LocalSend..."

if flatpak list | grep -q org.localsend.localsend_app; then
    echo -e "${GREEN}[install-localsend]${NC} LocalSend is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-localsend]${NC} Installing LocalSend via Flatpak..."

# Ensure Flatpak is set up
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install
flatpak install -y flathub org.localsend.localsend_app

echo -e "${GREEN}[install-localsend]${NC} LocalSend installed successfully!"
