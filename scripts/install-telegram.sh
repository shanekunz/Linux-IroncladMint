#!/bin/bash
# Install Telegram Desktop via Flatpak
set -e

if flatpak list | grep -q "org.telegram.desktop"; then
    echo "Telegram is already installed"
    exit 0
fi

echo "Installing Telegram Desktop..."
flatpak install -y flathub org.telegram.desktop

echo "Telegram installed successfully!"
