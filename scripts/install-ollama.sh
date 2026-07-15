#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

LATEST_URL="https://api.github.com/repos/ollama/ollama/releases/latest"
INSTALL_ROOT="$HOME/.local/lib/ollama"
BIN_DIR="$HOME/.local/bin"

echo -e "${YELLOW}[install-ollama]${NC} Checking for latest Ollama release..."

LATEST_TAG=$(curl -fsSL "$LATEST_URL" | grep -oP '"tag_name":\s*"\Kv[^"]+' | head -n 1)

if [ -z "$LATEST_TAG" ]; then
    echo -e "${RED}[install-ollama]${NC} Could not determine latest Ollama release"
    exit 1
fi

case "$(uname -m)" in
    x86_64)
        ARCHIVE_NAME="ollama-linux-amd64.tar.zst"
        ;;
    aarch64|arm64)
        ARCHIVE_NAME="ollama-linux-arm64.tar.zst"
        ;;
    *)
        echo -e "${RED}[install-ollama]${NC} Unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

TARGET_DIR="$INSTALL_ROOT/$LATEST_TAG"
TARGET_BIN="$TARGET_DIR/bin/ollama"

if [ -x "$TARGET_BIN" ]; then
    echo -e "${GREEN}[install-ollama]${NC} Ollama is already installed: $LATEST_TAG"
    ln -sfn "$TARGET_BIN" "$BIN_DIR/ollama"
    exit 0
fi

mkdir -p "$INSTALL_ROOT" "$BIN_DIR"

TMP_ARCHIVE=$(mktemp --suffix=.tar.zst)
trap 'rm -f "$TMP_ARCHIVE"' EXIT

DOWNLOAD_URL="https://github.com/ollama/ollama/releases/download/$LATEST_TAG/$ARCHIVE_NAME"

echo -e "${YELLOW}[install-ollama]${NC} Downloading $LATEST_TAG..."
curl -L --fail --output "$TMP_ARCHIVE" "$DOWNLOAD_URL"

mkdir -p "$TARGET_DIR"
tar --zstd -xf "$TMP_ARCHIVE" -C "$TARGET_DIR"
ln -sfn "$TARGET_BIN" "$BIN_DIR/ollama"

if command -v "$BIN_DIR/ollama" >/dev/null 2>&1; then
    INSTALLED_VERSION=$($BIN_DIR/ollama --version 2>/dev/null || echo "$LATEST_TAG")
    echo -e "${GREEN}[install-ollama]${NC} Ollama installed successfully: $INSTALLED_VERSION"
else
    echo -e "${RED}[install-ollama]${NC} Installation failed - ollama not found at $BIN_DIR/ollama"
    exit 1
fi
