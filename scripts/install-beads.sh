#!/bin/bash
# Install Beads (bd) via the official installer

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-beads]${NC} Checking for Beads CLI..."

# Ensure user-local bins are available in non-login shells.
export PATH="$HOME/.local/bin:$PATH"

if command -v bd &> /dev/null && BEADS_VERSION=$(bd version 2>/dev/null); then
    echo -e "${YELLOW}[install-beads]${NC} Updating Beads from: $BEADS_VERSION"
elif command -v bd &> /dev/null; then
    echo -e "${YELLOW}[install-beads]${NC} Found 'bd' on PATH, but it is not working. Reinstalling..."
fi

echo -e "${YELLOW}[install-beads]${NC} Installing the latest Beads release..."
curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash

if command -v bd &> /dev/null && BEADS_VERSION=$(bd version 2>/dev/null); then
    echo -e "${GREEN}[install-beads]${NC} Beads installed successfully: $BEADS_VERSION"
else
    echo -e "${RED}[install-beads]${NC} Installation failed"
    echo -e "${YELLOW}[install-beads]${NC} Restart your shell or verify ~/.local/bin is on PATH"
    exit 1
fi
