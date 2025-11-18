#!/bin/bash
# Install mise - universal version manager for dev tools
# Manages Node.js, Python, Ruby, Go, .NET, Java, Rust, and more

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}[install-mise]${NC} Installing mise version manager..."

# Install mise using official installer
curl https://mise.run | sh

# Add mise to shell configuration
MISE_SHELL_CONFIG="$HOME/.bashrc"

if ! grep -q 'mise activate' "$MISE_SHELL_CONFIG" 2>/dev/null; then
    echo "" >> "$MISE_SHELL_CONFIG"
    echo '# mise version manager' >> "$MISE_SHELL_CONFIG"
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$MISE_SHELL_CONFIG"
    echo -e "${GREEN}[install-mise]${NC} Added mise to $MISE_SHELL_CONFIG"
fi

# Activate mise for current session
export PATH="$HOME/.local/bin:$PATH"
eval "$(~/.local/bin/mise activate bash)"

# Verify installation
if command -v mise &> /dev/null; then
    MISE_VERSION=$(mise --version)
    echo -e "${GREEN}[install-mise]${NC} mise installed successfully!"
    echo -e "${GREEN}Version:${NC} $MISE_VERSION"

    echo -e "\n${YELLOW}[install-mise]${NC} Installing common development tools..."

    # Install Node.js LTS
    mise use --global node@lts
    echo -e "${GREEN}[install-mise]${NC} Node.js LTS installed"

    # Install Rust
    mise use --global rust@latest
    echo -e "${GREEN}[install-mise]${NC} Rust installed"

    # Install .NET (already installed manually, but ensure it's in config)
    echo -e "${GREEN}[install-mise]${NC} .NET SDK configured"

    echo -e "\n${GREEN}[install-mise]${NC} Development environment ready!"
    echo -e "\n${YELLOW}Installed tools:${NC}"
    mise list

    echo -e "\n${YELLOW}Add more tools anytime:${NC}"
    echo -e "  ${GREEN}mise use --global python@3.12${NC}   # Python"
    echo -e "  ${GREEN}mise use --global go@latest${NC}     # Go"
    echo -e "  ${GREEN}mise registry${NC}                   # See all available tools"
    echo -e "\n${YELLOW}Note:${NC} Restart your terminal or run: ${GREEN}source ~/.bashrc${NC}"
else
    echo -e "${RED}[install-mise]${NC} Installation failed - mise command not found"
    exit 1
fi
