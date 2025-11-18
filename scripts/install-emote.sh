#!/bin/bash
# Install Emote emoji picker via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-emote]${NC} Checking for Emote..."

if flatpak list | grep -q com.tomjwatson.Emote; then
    echo -e "${GREEN}[install-emote]${NC} Emote is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-emote]${NC} Installing Emote via Flatpak..."

# Ensure Flatpak is set up
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install
flatpak install -y flathub com.tomjwatson.Emote

echo -e "${GREEN}[install-emote]${NC} Emote installed successfully!"
