#!/bin/bash
# Install modern terminal utilities (eza, bat, zoxide, btop)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

install_pkg_if_available() {
    local pkg="$1"
    if apt-cache show "$pkg" >/dev/null 2>&1; then
        sudo apt install -y "$pkg"
        return 0
    fi

    return 1
}

echo -e "${YELLOW}[install-terminal-utils]${NC} Installing terminal utilities..."
sudo apt update

if command -v eza >/dev/null 2>&1; then
    echo -e "${GREEN}[install-terminal-utils]${NC} eza already installed"
else
    if install_pkg_if_available eza; then
        echo -e "${GREEN}[install-terminal-utils]${NC} Installed eza"
    elif install_pkg_if_available exa; then
        echo -e "${GREEN}[install-terminal-utils]${NC} Installed exa (eza fallback)"
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v exa)" "$HOME/.local/bin/eza"
    else
        echo -e "${YELLOW}[install-terminal-utils]${NC} eza/exa package not available on this distro"
    fi
fi

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    echo -e "${GREEN}[install-terminal-utils]${NC} bat already installed"
else
    if install_pkg_if_available bat; then
        echo -e "${GREEN}[install-terminal-utils]${NC} Installed bat"
    elif install_pkg_if_available batcat; then
        echo -e "${GREEN}[install-terminal-utils]${NC} Installed batcat"
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    else
        echo -e "${YELLOW}[install-terminal-utils]${NC} bat package not available on this distro"
    fi
fi

if command -v zoxide >/dev/null 2>&1; then
    echo -e "${GREEN}[install-terminal-utils]${NC} zoxide already installed"
else
    if install_pkg_if_available zoxide; then
        echo -e "${GREEN}[install-terminal-utils]${NC} Installed zoxide"
    else
        echo -e "${YELLOW}[install-terminal-utils]${NC} zoxide package not available on this distro"
    fi
fi

if command -v btop >/dev/null 2>&1; then
    echo -e "${GREEN}[install-terminal-utils]${NC} btop already installed"
else
    if install_pkg_if_available btop; then
        echo -e "${GREEN}[install-terminal-utils]${NC} Installed btop"
    else
        echo -e "${YELLOW}[install-terminal-utils]${NC} btop package not available on this distro"
    fi
fi

echo -e "${GREEN}[install-terminal-utils]${NC} Done."
