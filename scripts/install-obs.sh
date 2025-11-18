#!/bin/bash
# Install OBS Studio from official PPA

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-obs]${NC} Checking for OBS Studio..."

if command -v obs &> /dev/null; then
    echo -e "${GREEN}[install-obs]${NC} OBS Studio is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-obs]${NC} Installing OBS Studio from official PPA..."

# Add OBS Studio PPA
sudo add-apt-repository -y ppa:obsproject/obs-studio
sudo apt update
sudo apt install -y obs-studio

echo -e "${GREEN}[install-obs]${NC} OBS Studio installed successfully!"
