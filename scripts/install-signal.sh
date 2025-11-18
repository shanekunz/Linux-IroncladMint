#!/bin/bash
# Install Signal from official APT repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-signal]${NC} Checking for Signal..."

if command -v signal-desktop &> /dev/null; then
    echo -e "${GREEN}[install-signal]${NC} Signal is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-signal]${NC} Installing Signal from official repository..."

# Install official Signal repository
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
  sudo tee /etc/apt/sources.list.d/signal-xenial.list
rm signal-desktop-keyring.gpg

# Install
sudo apt update
sudo apt install -y signal-desktop

echo -e "${GREEN}[install-signal]${NC} Signal installed successfully!"
