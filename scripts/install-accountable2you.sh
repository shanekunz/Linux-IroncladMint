#!/bin/bash
# Install accountable2you via snap

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-accountable2you]${NC} Checking for accountable2you..."

if snap list accountable2you &> /dev/null; then
    echo -e "${GREEN}[install-accountable2you]${NC} accountable2you is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-accountable2you]${NC} Installing accountable2you via snap..."
sudo snap install accountable2you

echo -e "${GREEN}[install-accountable2you]${NC} accountable2you installed successfully!"
