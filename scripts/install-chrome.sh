#!/bin/bash
# Install Google Chrome from official repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-chrome]${NC} Checking for Google Chrome..."

if command -v google-chrome &> /dev/null; then
    echo -e "${GREEN}[install-chrome]${NC} Google Chrome is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-chrome]${NC} Installing Google Chrome from official repository..."

# Download and install the .deb (this also adds Google's apt repository for auto-updates)
wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || sudo apt-get -f install -y
rm /tmp/google-chrome-stable_current_amd64.deb

echo -e "${GREEN}[install-chrome]${NC} Google Chrome installed successfully!"
