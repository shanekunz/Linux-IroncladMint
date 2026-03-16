#!/bin/bash
# Install or update Superset desktop app (Linux AppImage)

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/bin"
APP_PATH="$INSTALL_DIR/superset"
DATA_DIR="$HOME/.local/share/superset"
VERSION_FILE="$DATA_DIR/version"
DESKTOP_DIR="$HOME/.local/share/applications"
DESKTOP_FILE="$DESKTOP_DIR/superset.desktop"
API_URL="https://api.github.com/repos/superset-sh/superset/releases/latest"

TMP_DIR=$(mktemp -d)
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo -e "${YELLOW}[install-superset]${NC} Checking latest Superset release..."

RELEASE_JSON=$(curl -fsSL "$API_URL")

LATEST_TAG=$(printf '%s\n' "$RELEASE_JSON" | grep -m1 '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL=$(printf '%s\n' "$RELEASE_JSON" | grep -oE 'https://[^[:space:]"]*(Superset|superset)-[^[:space:]"]*x86_64\.AppImage' | head -1)

if [ -z "$LATEST_TAG" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}[install-superset]${NC} Failed to determine the latest Linux AppImage release"
    exit 1
fi

LATEST_VERSION="${LATEST_TAG#desktop-v}"
INSTALLED_VERSION=""

if [ -f "$VERSION_FILE" ]; then
    INSTALLED_VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")
fi

mkdir -p "$INSTALL_DIR" "$DATA_DIR" "$DESKTOP_DIR"

if [ -x "$APP_PATH" ] && [ "$INSTALLED_VERSION" = "$LATEST_VERSION" ]; then
    echo -e "${GREEN}[install-superset]${NC} Superset is already up to date (${LATEST_VERSION})"
else
    echo -e "${YELLOW}[install-superset]${NC} Downloading Superset ${LATEST_VERSION}..."
    curl -fL "$DOWNLOAD_URL" -o "$TMP_DIR/superset.AppImage"
    chmod +x "$TMP_DIR/superset.AppImage"
    mv "$TMP_DIR/superset.AppImage" "$APP_PATH"
    printf '%s\n' "$LATEST_VERSION" > "$VERSION_FILE"
    echo -e "${GREEN}[install-superset]${NC} Installed Superset ${LATEST_VERSION}"
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Superset
Comment=IDE for the AI Agents Era
Exec=$APP_PATH
Icon=utilities-terminal
Type=Application
Categories=Development;
Terminal=false
StartupNotify=true
EOF

if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" > /dev/null 2>&1 || true
fi

echo -e "${GREEN}[install-superset]${NC} Launcher entry ready"
echo -e "${YELLOW}[install-superset]${NC} Run 'superset' to start the app"
