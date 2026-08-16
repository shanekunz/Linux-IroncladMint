#!/bin/bash
# Install Sunshine game streaming server

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-sunshine]${NC} Checking for the latest Sunshine release..."

RELEASE_JSON=$(curl -fsSL https://api.github.com/repos/LizardByte/Sunshine/releases/latest)
SUNSHINE_VERSION=$(printf '%s' "$RELEASE_JSON" | jq -r '.tag_name | ltrimstr("v")')
DOWNLOAD_URL=$(printf '%s' "$RELEASE_JSON" | jq -r '.assets[] | select(.name == "sunshine-ubuntu-22.04-amd64.deb") | .browser_download_url')
INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' sunshine 2>/dev/null || true)

if [ -n "$INSTALLED_VERSION" ] && dpkg --compare-versions "$INSTALLED_VERSION" ge "$SUNSHINE_VERSION"; then
    echo -e "${GREEN}[install-sunshine]${NC} Sunshine is already current: $INSTALLED_VERSION"
    exit 0
fi

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo -e "${YELLOW}[install-sunshine]${NC} Could not find the Ubuntu 22.04 amd64 release package"
    exit 1
fi

echo -e "${YELLOW}[install-sunshine]${NC} Installing Sunshine ${SUNSHINE_VERSION}..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
curl -fsSL -o "$TEMP_DIR/sunshine.deb" "$DOWNLOAD_URL"
sudo apt install -y "$TEMP_DIR/sunshine.deb"

echo -e "${GREEN}[install-sunshine]${NC} Sunshine ${SUNSHINE_VERSION} installed successfully!"
