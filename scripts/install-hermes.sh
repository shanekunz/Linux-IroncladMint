#!/bin/bash
# Install Hermes Agent without running setup, provider login, or key prompts.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

export PATH="$HOME/.local/bin:$PATH"

ensure_hermes_extras() {
    if [ ! -x "$HOME/.hermes/bin/uv" ]; then
        return 0
    fi

    if [ ! -x "$HOME/.hermes/bin/browser-use" ]; then
        echo -e "${YELLOW}[install-hermes]${NC} Installing the isolated browser runtime..."
        UV_NO_CONFIG=1 UV_TOOL_BIN_DIR="$HOME/.hermes/bin" \
            "$HOME/.hermes/bin/uv" tool install browser-use
    fi

    if [ -x "$HOME/.hermes/hermes-agent/venv/bin/python" ]; then
        echo -e "${YELLOW}[install-hermes]${NC} Ensuring Telegram gateway support..."
        "$HOME/.hermes/bin/uv" pip install \
            --python "$HOME/.hermes/hermes-agent/venv/bin/python" \
            "python-telegram-bot[webhooks]==22.8"
    fi
}

echo -e "${YELLOW}[install-hermes]${NC} Checking for Hermes Agent..."

if command -v hermes &> /dev/null; then
    ensure_hermes_extras
    echo -e "${GREEN}[install-hermes]${NC} Hermes Agent is already installed: $(hermes --version 2>/dev/null || echo installed)"
    exit 0
fi

installer="$(mktemp)"
trap 'rm -f "$installer"' EXIT

echo -e "${YELLOW}[install-hermes]${NC} Downloading the official installer..."
curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o "$installer"

bash "$installer" \
    --skip-setup \
    --no-skills \
    --skip-computer-use

ensure_hermes_extras

if command -v hermes &> /dev/null; then
    echo -e "${GREEN}[install-hermes]${NC} Hermes Agent installed without credentials or provider login."
    echo -e "${YELLOW}[install-hermes]${NC} Deploy the hermes dotfiles, then run 'hermes auth add openai-codex' when ready."
else
    echo -e "${RED}[install-hermes]${NC} Installation finished but hermes is not on PATH."
    exit 1
fi
