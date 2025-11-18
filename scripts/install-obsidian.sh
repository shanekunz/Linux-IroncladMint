#!/bin/bash
# Install Obsidian via Flatpak

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-obsidian]${NC} Checking for Obsidian..."

if flatpak list | grep -q md.obsidian.Obsidian; then
    echo -e "${GREEN}[install-obsidian]${NC} Obsidian is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-obsidian]${NC} Installing Obsidian via Flatpak..."

# Ensure Flatpak is set up
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install
flatpak install -y flathub md.obsidian.Obsidian

echo -e "${GREEN}[install-obsidian]${NC} Obsidian installed successfully!"
