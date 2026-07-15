#!/bin/bash
# Install Handy local voice-to-text dictation app.

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

HANDY_VERSION="0.9.3"
HANDY_DEB="Handy_${HANDY_VERSION}_amd64.deb"
HANDY_URL="https://github.com/cjpais/Handy/releases/download/v${HANDY_VERSION}/${HANDY_DEB}"
HANDY_SHA256="b160734a465c848aacec8ec3e738596cf41f19279a5048e96c740e5b6e3cb073"
TEMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo -e "${YELLOW}[install-handy]${NC} Checking for Handy..."

if command -v handy &> /dev/null; then
    INSTALLED_VERSION=$(dpkg-query -W -f='${Version}' handy 2>/dev/null || true)
    echo -e "${GREEN}[install-handy]${NC} Handy is already installed${INSTALLED_VERSION:+ (version ${INSTALLED_VERSION})}"
    exit 0
fi

if [[ "$(dpkg --print-architecture)" != "amd64" ]]; then
    echo "Handy installation currently supports amd64 only."
    exit 1
fi

echo -e "${YELLOW}[install-handy]${NC} Downloading Handy ${HANDY_VERSION}..."
curl --fail --location --output "${TEMP_DIR}/${HANDY_DEB}" "${HANDY_URL}"

echo "${HANDY_SHA256}  ${TEMP_DIR}/${HANDY_DEB}" | sha256sum --check --status

echo -e "${YELLOW}[install-handy]${NC} Installing Handy..."
sudo apt install -y "${TEMP_DIR}/${HANDY_DEB}"

echo -e "${GREEN}[install-handy]${NC} Handy installed successfully!"
echo "Launch it with 'handy --start-hidden', choose a local model, then configure its shortcut."
