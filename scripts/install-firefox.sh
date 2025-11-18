#!/bin/bash
# Install Firefox from Mozilla PPA (latest version)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-firefox]${NC} Checking for Firefox..."

if command -v firefox &> /dev/null; then
    echo -e "${GREEN}[install-firefox]${NC} Firefox is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-firefox]${NC} Installing Firefox from Mozilla PPA..."

# Add Mozilla team PPA for latest Firefox
sudo add-apt-repository -y ppa:mozillateam/ppa
sudo apt update
sudo apt install -y firefox

echo -e "${GREEN}[install-firefox]${NC} Firefox installed successfully!"
