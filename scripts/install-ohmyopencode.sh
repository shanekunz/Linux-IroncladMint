#!/bin/bash
# Install Oh My OpenCode - The Best Agent Harness for OpenCode
# https://ohmyopencode.com / https://github.com/code-yeongyu/oh-my-opencode
# Requires: Bun runtime

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-ohmyopencode]${NC} Checking for oh-my-opencode..."

# Check if bun is available, install if not
if ! command -v bun &> /dev/null; then
    echo -e "${YELLOW}[install-ohmyopencode]${NC} Bun not found. Installing bun first..."
    curl -fsSL https://bun.sh/install | bash
    
    # Source bun for current session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    if ! command -v bun &> /dev/null; then
        echo -e "${RED}[install-ohmyopencode]${NC} Failed to install bun"
        exit 1
    fi
    echo -e "${GREEN}[install-ohmyopencode]${NC} Bun installed successfully"
fi

# Check if already installed
if [ -d "$HOME/.config/opencode" ] && [ -f "$HOME/.config/opencode/opencode.json" ]; then
    echo -e "${GREEN}[install-ohmyopencode]${NC} oh-my-opencode is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-ohmyopencode]${NC} Installing oh-my-opencode..."

bunx oh-my-opencode install

echo -e "${GREEN}[install-ohmyopencode]${NC} oh-my-opencode installed successfully!"
echo -e "${YELLOW}[install-ohmyopencode]${NC} Run 'opencode init' to initialize configuration"
