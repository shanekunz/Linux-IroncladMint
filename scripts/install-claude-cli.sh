#!/bin/bash
# Install Claude Code CLI via official installer

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-claude-cli]${NC} Checking for Claude CLI..."

# Ensure user-local bins and mise shims are available
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

if command -v claude &> /dev/null; then
    echo -e "${YELLOW}[install-claude-cli]${NC} Updating Claude CLI from: $(claude --version 2>/dev/null || echo "installed")"
fi

echo -e "${YELLOW}[install-claude-cli]${NC} Installing the latest Claude CLI via the official installer..."
curl -fsSL https://claude.ai/install.sh | bash

# Refresh shims for mise-managed Node installations
if command -v mise &> /dev/null; then
    mise reshim || true
fi

if command -v claude &> /dev/null; then
    echo -e "${GREEN}[install-claude-cli]${NC} Claude CLI installed successfully!"
else
    echo -e "${RED}[install-claude-cli]${NC} Claude install completed but 'claude' is not on PATH yet"
    echo -e "${YELLOW}[install-claude-cli]${NC} Restart shell or run: source ~/.bashrc"
    exit 1
fi
