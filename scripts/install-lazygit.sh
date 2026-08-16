#!/bin/bash
# Install lazygit TUI from GitHub releases

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-lazygit]${NC} Checking for the latest lazygit release..."

LAZYGIT_VERSION=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
INSTALLED_VERSION=""
if command -v lazygit &> /dev/null; then
    INSTALLED_VERSION=$(lazygit --version 2>/dev/null | grep -Po 'version=\K[^, ]+' || true)
fi

if [ "$INSTALLED_VERSION" = "$LAZYGIT_VERSION" ]; then
    echo -e "${GREEN}[install-lazygit]${NC} lazygit is already current: $INSTALLED_VERSION"
    exit 0
fi

echo -e "${YELLOW}[install-lazygit]${NC} Installing lazygit ${LAZYGIT_VERSION}..."
mkdir -p "$HOME/.local/bin"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

curl -fsSL -o "$TEMP_DIR/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf "$TEMP_DIR/lazygit.tar.gz" -C "$TEMP_DIR" lazygit
install -m 0755 "$TEMP_DIR/lazygit" "$HOME/.local/bin/lazygit"

echo -e "${GREEN}[install-lazygit]${NC} lazygit ${LAZYGIT_VERSION} installed successfully!"
