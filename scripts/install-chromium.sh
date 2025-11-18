#!/bin/bash
# Install Chromium via snap

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-chromium]${NC} Checking for Chromium..."

if command -v chromium &> /dev/null || snap list chromium &> /dev/null; then
    echo -e "${GREEN}[install-chromium]${NC} Chromium is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-chromium]${NC} Installing Chromium via snap..."
sudo snap install chromium

echo -e "${GREEN}[install-chromium]${NC} Chromium installed successfully!"
