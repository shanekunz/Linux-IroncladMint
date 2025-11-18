#!/bin/bash
# Install latest Git from official PPA

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-git]${NC} Checking for Git..."

if command -v git &> /dev/null; then
    echo -e "${GREEN}[install-git]${NC} Git is already installed ($(git --version))"
    exit 0
fi

echo -e "${YELLOW}[install-git]${NC} Installing Git from official PPA..."
sudo add-apt-repository -y ppa:git-core/ppa
sudo apt update
sudo apt install -y git

echo -e "${GREEN}[install-git]${NC} Git installed successfully!"
