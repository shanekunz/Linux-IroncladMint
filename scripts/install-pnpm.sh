#!/bin/bash
# Install pnpm via npm

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-pnpm]${NC} Checking for pnpm..."

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if pnpm is already installed
if command -v pnpm &> /dev/null; then
    echo -e "${GREEN}[install-pnpm]${NC} pnpm is already installed ($(pnpm --version))"
    exit 0
fi

echo -e "${YELLOW}[install-pnpm]${NC} Installing pnpm via npm..."
npm install -g pnpm

echo -e "${GREEN}[install-pnpm]${NC} pnpm installed successfully!"
