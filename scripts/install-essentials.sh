#!/bin/bash
# Install essential build tools and utilities

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[install-essentials]${NC} Installing essential build tools..."

# Update package list
sudo apt update

# Install essential packages (apt will skip already installed packages)
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    jq \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release

echo -e "${GREEN}[install-essentials]${NC} Essential tools installed successfully!"
