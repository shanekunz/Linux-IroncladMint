#!/bin/bash
# Install Claude CLI via npm

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-claude-cli]${NC} Checking for Claude CLI..."

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if claude is already installed
if command -v claude &> /dev/null; then
    echo -e "${GREEN}[install-claude-cli]${NC} Claude CLI is already installed"
    exit 0
fi

echo -e "${YELLOW}[install-claude-cli]${NC} Installing Claude CLI via npm..."
npm install -g @anthropic-ai/claude-code

echo -e "${GREEN}[install-claude-cli]${NC} Claude CLI installed successfully!"
