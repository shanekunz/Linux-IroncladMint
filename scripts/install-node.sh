#!/bin/bash
# Install Node.js via NVM (latest LTS and latest current)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-node]${NC} Checking for Node.js..."

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if NVM is installed
if ! command -v nvm &> /dev/null; then
    echo -e "${YELLOW}[install-node]${NC} NVM is not installed. Please run install-nvm.sh first."
    exit 1
fi

# Check if Node is already installed
if command -v node &> /dev/null; then
    echo -e "${GREEN}[install-node]${NC} Node.js is already installed ($(node --version))"
    exit 0
fi

echo -e "${YELLOW}[install-node]${NC} Installing Node.js LTS via NVM..."
nvm install --lts

echo -e "${YELLOW}[install-node]${NC} Installing latest Node.js version..."
nvm install node

echo -e "${YELLOW}[install-node]${NC} Setting LTS as default..."
nvm alias default 'lts/*'

echo -e "${GREEN}[install-node]${NC} Node.js installed successfully!"
echo -e "  LTS version: $(nvm version 'lts/*')"
echo -e "  Latest version: $(nvm version node)"
