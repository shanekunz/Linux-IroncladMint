#!/bin/bash
# Install Sunshine game streaming server

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}[install-sunshine]${NC} Checking for the latest Sunshine release..."

RELEASE_JSON=$(curl -fsSL https://api.github.com/repos/LizardByte/Sunshine/releases/latest)
SUNSHINE_VERSION=$(printf '%s' "$RELEASE_JSON" | jq -r '.tag_name | ltrimstr("v")')

# Linux Mint inherits Ubuntu package ABI compatibility from its base codename.
. /etc/os-release
case "${UBUNTU_CODENAME:-$VERSION_CODENAME}" in
    jammy)
        UBUNTU_VERSION="22.04"
        ;;
    noble)
        UBUNTU_VERSION="24.04"
        ;;
    *)
        echo -e "${YELLOW}[install-sunshine]${NC} Unsupported Ubuntu base: ${UBUNTU_CODENAME:-${VERSION_CODENAME:-unknown}}"
        exit 1
        ;;
esac

PACKAGE_NAME="sunshine-ubuntu-${UBUNTU_VERSION}-amd64.deb"
DOWNLOAD_URL=$(printf '%s' "$RELEASE_JSON" | jq -r --arg package "$PACKAGE_NAME" '.assets[] | select(.name == $package) | .browser_download_url')
INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' sunshine 2>/dev/null || true)

if [ -n "$INSTALLED_VERSION" ] && dpkg --compare-versions "$INSTALLED_VERSION" ge "$SUNSHINE_VERSION"; then
    echo -e "${GREEN}[install-sunshine]${NC} Sunshine is already current: $INSTALLED_VERSION"
    exit 0
fi

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo -e "${YELLOW}[install-sunshine]${NC} Could not find the ${PACKAGE_NAME} release package"
    exit 1
fi

echo -e "${YELLOW}[install-sunshine]${NC} Installing Sunshine ${SUNSHINE_VERSION}..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
curl -fsSL -o "$TEMP_DIR/sunshine.deb" "$DOWNLOAD_URL"
sudo apt install -y "$TEMP_DIR/sunshine.deb"

echo -e "${GREEN}[install-sunshine]${NC} Sunshine ${SUNSHINE_VERSION} installed successfully!"
