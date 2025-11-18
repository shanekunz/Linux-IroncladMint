#!/bin/bash
# Install GitHub CLI (gh) from official repository

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-gh]${NC} Checking for GitHub CLI..."

if command -v gh &> /dev/null; then
    echo -e "${GREEN}[install-gh]${NC} GitHub CLI is already installed ($(gh --version | head -n1))"
    exit 0
fi

echo -e "${YELLOW}[install-gh]${NC} Installing GitHub CLI from official repository..."

# Add GitHub CLI repository
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt update
sudo apt install -y gh

echo -e "${GREEN}[install-gh]${NC} GitHub CLI installed successfully!"
