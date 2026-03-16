#!/bin/bash
# Install OpenAI Codex CLI via npm
# https://github.com/openai/codex

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-codex]${NC} Checking for Codex CLI..."

# Ensure user-local bins and mise shims are available
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

if ! command -v npm &> /dev/null; then
    echo -e "${RED}[install-codex]${NC} npm not found. Please run install-mise.sh first to install Node.js"
    exit 1
fi

PREVIOUS_VERSION=""
if command -v codex &> /dev/null; then
    PREVIOUS_VERSION=$(codex --version 2>/dev/null || true)
    if [ -n "$PREVIOUS_VERSION" ]; then
        echo -e "${GREEN}[install-codex]${NC} Codex is already installed: $PREVIOUS_VERSION"
        echo -e "${YELLOW}[install-codex]${NC} Updating to the latest version via npm..."
    else
        echo -e "${YELLOW}[install-codex]${NC} Codex is on PATH but version check failed. Reinstalling..."
    fi
else
    echo -e "${YELLOW}[install-codex]${NC} Installing Codex via npm..."
fi

npm install -g @openai/codex@latest

# Refresh shims for mise-managed Node installations
if command -v mise &> /dev/null; then
    mise reshim || true
fi

if command -v codex &> /dev/null; then
    CODEX_VERSION=$(codex --version 2>/dev/null || echo "installed")
    echo -e "${GREEN}[install-codex]${NC} Codex is ready: $CODEX_VERSION"
    echo -e "${YELLOW}[install-codex]${NC} Run 'codex' to start or 'codex login' if you need to authenticate"
else
    echo -e "${RED}[install-codex]${NC} Installation completed but 'codex' is not on PATH yet"
    echo -e "${YELLOW}[install-codex]${NC} npm prefix: $(npm config get prefix 2>/dev/null || echo unknown)"
    echo -e "${YELLOW}[install-codex]${NC} Restart shell or run: source ~/.bashrc"
    exit 1
fi
