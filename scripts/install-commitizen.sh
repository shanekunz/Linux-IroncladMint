#!/bin/bash
# Install Commitizen via pipx for conventional commits

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-commitizen]${NC} Checking for Commitizen..."

# Check if commitizen is already installed
if command -v cz &> /dev/null; then
    echo -e "${GREEN}[install-commitizen]${NC} Commitizen is already installed"
    exit 0
fi

# Ensure pipx is installed
if ! command -v pipx &> /dev/null; then
    echo -e "${YELLOW}[install-commitizen]${NC} Installing pipx first..."
    sudo apt install -y pipx
    pipx ensurepath
fi

echo -e "${YELLOW}[install-commitizen]${NC} Installing Commitizen via pipx..."
pipx install commitizen

echo -e "${GREEN}[install-commitizen]${NC} Commitizen installed successfully!"
