#!/bin/bash
# Install T3 Code desktop app (AppImage)
# https://t3.codes

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/bin"
APPLICATIONS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons"
APP_PATH="$INSTALL_DIR/t3-code"
DESKTOP_PATH="$APPLICATIONS_DIR/t3code.desktop"
ICON_PATH="$ICONS_DIR/t3code.png"

echo -e "${YELLOW}[install-t3-code]${NC} Checking for T3 Code..."

if [ -x "$APP_PATH" ] && [ -f "$DESKTOP_PATH" ]; then
    echo -e "${GREEN}[install-t3-code]${NC} T3 Code is already installed"
    exit 0
fi

case "$(uname -m)" in
    x86_64|amd64)
        ASSET_PATTERN='T3-Code-.*-x86_64\.AppImage$'
        ;;
    *)
        echo -e "${RED}[install-t3-code]${NC} No official Linux AppImage is available for $(uname -m)"
        exit 1
        ;;
esac

echo -e "${YELLOW}[install-t3-code]${NC} Finding latest release..."
DOWNLOAD_URL=$(curl -fsSL "https://api.github.com/repos/pingdotgg/t3code/releases/latest" \
    | grep '"browser_download_url"' \
    | cut -d '"' -f 4 \
    | grep -E "$ASSET_PATTERN" \
    | head -1)

if [ -z "$DOWNLOAD_URL" ]; then
    echo -e "${RED}[install-t3-code]${NC} Could not find the latest Linux AppImage"
    exit 1
fi

mkdir -p "$INSTALL_DIR" "$APPLICATIONS_DIR" "$ICONS_DIR"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo -e "${YELLOW}[install-t3-code]${NC} Downloading T3 Code..."
curl -fL "$DOWNLOAD_URL" -o "$TEMP_DIR/t3-code.AppImage"
chmod +x "$TEMP_DIR/t3-code.AppImage"

(
    cd "$TEMP_DIR"
    ./t3-code.AppImage --appimage-extract usr/share/icons/hicolor/512x512/apps/t3code.png > /dev/null
)

install -m 0755 "$TEMP_DIR/t3-code.AppImage" "$APP_PATH"
install -m 0644 "$TEMP_DIR/squashfs-root/usr/share/icons/hicolor/512x512/apps/t3code.png" "$ICON_PATH"

cat > "$DESKTOP_PATH" <<EOF
[Desktop Entry]
Name=T3 Code
Comment=T3 Code desktop build
Exec=$APP_PATH --no-sandbox %U
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupWMClass=t3code
MimeType=x-scheme-handler/t3code;x-scheme-handler/t3code-dev;
Categories=Development;
EOF

if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$APPLICATIONS_DIR"
fi

echo -e "${GREEN}[install-t3-code]${NC} T3 Code installed successfully!"
