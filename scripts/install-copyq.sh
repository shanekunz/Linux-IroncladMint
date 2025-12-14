#!/bin/bash
set -e

# Check if CopyQ is already installed
if command -v copyq &> /dev/null; then
    echo "CopyQ is already installed"
    exit 0
fi

echo "Installing CopyQ..."
sudo apt install -y copyq

echo "CopyQ installed successfully"
