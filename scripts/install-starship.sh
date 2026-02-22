#!/bin/bash
# Install Starship prompt binary to ~/.local/bin

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-starship]${NC} Checking for starship..."

if command -v starship >/dev/null 2>&1; then
    echo -e "${GREEN}[install-starship]${NC} starship is already installed ($(starship --version))"
    exit 0
fi

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)
        TARGET="x86_64-unknown-linux-gnu"
        ;;
    aarch64|arm64)
        TARGET="aarch64-unknown-linux-gnu"
        ;;
    *)
        echo -e "${RED}[install-starship]${NC} Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

URL="https://github.com/starship/starship/releases/latest/download/starship-${TARGET}.tar.gz"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "${YELLOW}[install-starship]${NC} Downloading starship binary..."
curl -fsSL "$URL" -o "$TMP_DIR/starship.tar.gz"

echo -e "${YELLOW}[install-starship]${NC} Installing to ~/.local/bin..."
tar -xzf "$TMP_DIR/starship.tar.gz" -C "$TMP_DIR"
mkdir -p "$HOME/.local/bin"
install -m 0755 "$TMP_DIR/starship" "$HOME/.local/bin/starship"

echo -e "${GREEN}[install-starship]${NC} starship installed successfully!"
echo -e "${YELLOW}Note:${NC} Re-source your shell: source ~/.bashrc"
