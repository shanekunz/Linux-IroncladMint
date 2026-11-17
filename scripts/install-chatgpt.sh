#!/bin/bash
# Install the official ChatGPT desktop app for Linux.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PACKAGE_URL_BASE="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest"
TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

remove_legacy_webapp() {
    local desktop_file="$HOME/.local/share/applications/chatgpt.desktop"

    if [ -f "$desktop_file" ] && grep -q '/webapp.*ChatGPT' "$desktop_file"; then
        rm "$desktop_file"
        echo -e "${GREEN}[install-chatgpt]${NC} Removed legacy ChatGPT web app launcher"
    fi
}

echo -e "${YELLOW}[install-chatgpt]${NC} Checking for ChatGPT..."

if dpkg-query -W -f='${Status}' chatgpt 2>/dev/null | grep -q 'install ok installed'; then
    remove_legacy_webapp
    echo -e "${GREEN}[install-chatgpt]${NC} ChatGPT is already installed"
    exit 0
fi

case "$(dpkg --print-architecture)" in
    amd64)
        PACKAGE_NAME="chatgpt_amd64.deb"
        ;;
    arm64)
        PACKAGE_NAME="chatgpt_arm64.deb"
        ;;
    *)
        echo "ChatGPT installation currently supports amd64 and arm64 only."
        exit 1
        ;;
esac

echo -e "${YELLOW}[install-chatgpt]${NC} Downloading ChatGPT..."
curl --fail --location --output "$TEMP_DIR/$PACKAGE_NAME" "$PACKAGE_URL_BASE/$PACKAGE_NAME"

echo -e "${YELLOW}[install-chatgpt]${NC} Installing ChatGPT..."
sudo apt install -y "$TEMP_DIR/$PACKAGE_NAME"
remove_legacy_webapp

echo -e "${GREEN}[install-chatgpt]${NC} ChatGPT installed successfully!"
