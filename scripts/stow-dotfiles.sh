#!/bin/bash
# Deploy dotfiles using GNU Stow

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get the dotfiles directory (parent of scripts directory)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Dotfiles Deployment with Stow${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error:${NC} GNU Stow is not installed"
    echo -e "Run: ${BLUE}./install-stow.sh${NC} first"
    exit 1
fi

# Backup existing files
echo -e "${YELLOW}Creating backup of existing dotfiles...${NC}"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# List of files/directories to back up
declare -a to_backup=(
    ".bashrc"
    ".profile"
    ".gitconfig"
    ".tmux.conf"
    ".Xresources"
    ".config/i3"
    ".config/nvim"
    ".config/ghostty"
    ".config/starship"
    ".config/rofi"
    ".config/picom"
    ".config/i3blocks"
    ".config/lazygit"
    ".config/flameshot"
    ".config/nitrogen"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/kanata"
    ".config/environment.d"
    ".config/mise"
    ".config/gh"
    ".config/copyq"
    ".config/opencode"
    ".local/bin/webapp"
    ".local/bin/lazygit"
    ".local/bin/sunsama"
    ".claude"
    "scripts"
)

for item in "${to_backup[@]}"; do
    if [ -e "$HOME/$item" ] && [ ! -L "$HOME/$item" ]; then
        echo -e "  Backing up: $item"
        mkdir -p "$BACKUP_DIR/$(dirname "$item")"
        cp -r "$HOME/$item" "$BACKUP_DIR/$item" 2>/dev/null || true
    fi
done

echo -e "${GREEN}Backup created at:${NC} $BACKUP_DIR"
echo ""

backup_conflicting_path() {
    local relative_path="$1"
    local target_path="$HOME/$relative_path"
    local backup_path="$BACKUP_DIR/$relative_path"
    local backup_parent

    if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
        return 0
    fi

    if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
            rm -rf "$target_path"
        else
            rm -f "$target_path"
        fi
        return 0
    fi

    backup_parent="$(dirname "$backup_path")"
    if [ -L "$backup_parent" ] || { [ -e "$backup_parent" ] && [ ! -d "$backup_parent" ]; }; then
        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
            rm -rf "$target_path"
        else
            rm -f "$target_path"
        fi
        return 0
    fi

    mkdir -p "$backup_parent"

    mv "$target_path" "$backup_path"
}

print_stow_output() {
    local output="$1"
    local line

    while IFS= read -r line; do
        if [[ "$line" == BUG* ]]; then
            continue
        fi
        printf '%s\n' "$line"
    done <<< "$output"
}

is_wsl() {
    grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null
}

detect_host_variant() {
    case "${DOTFILES_HOST:-auto}" in
        wsl|linux)
            printf '%s\n' "$DOTFILES_HOST"
            ;;
        auto|"")
            if is_wsl; then
                printf 'wsl\n'
            else
                printf 'linux\n'
            fi
            ;;
        *)
            echo -e "${RED}Error:${NC} DOTFILES_HOST must be 'auto', 'wsl', or 'linux'"
            exit 1
            ;;
    esac
}

collect_conflicts() {
    local output="$1"
    local line
    local conflict_path

    CONFLICT_PATHS=()

    while IFS= read -r line; do
        conflict_path=""

        if [[ "$line" == *"existing target is neither a link nor a directory: "* ]]; then
            conflict_path="${line##*: }"
        elif [[ "$line" == *"existing target is not owned by stow: "* ]]; then
            conflict_path="${line##*: }"
        elif [[ "$line" == *"existing target is stowed to a different package: "* ]]; then
            conflict_path="${line##*: }"
            conflict_path="${conflict_path%% => *}"
        fi

        if [ -n "$conflict_path" ]; then
            CONFLICT_PATHS+=("$conflict_path")
        fi
    done <<< "$output"
}

is_repo_symlink() {
    local target_path="$1"
    local resolved_path

    if [ ! -L "$target_path" ]; then
        return 1
    fi

    resolved_path="$(readlink -f "$target_path" 2>/dev/null || true)"
    [ -n "$resolved_path" ] && [[ "$resolved_path" == "$DOTFILES_DIR/"* ]]
}

remove_repo_symlink_conflict() {
    local relative_path="$1"
    local current_path="$HOME/$relative_path"

    while [[ "$current_path" == "$HOME"/* ]]; do
        if is_repo_symlink "$current_path"; then
            echo -e "    Removing old repo symlink: ${current_path#$HOME/}"
            rm -f "$current_path"
            return 0
        fi

        if [ "$current_path" = "$HOME" ]; then
            break
        fi

        current_path="$(dirname "$current_path")"
    done

    return 1
}

stow_package() {
    local package="$1"
    shift
    local -a extra_args=("$@")
    local output

    echo -e "  Stowing: ${BLUE}$package${NC}"

    if output=$(stow -v 1 -t "$HOME" "${extra_args[@]}" "$package" 2>&1); then
        print_stow_output "$output"
        STOWED_PACKAGES+=("$package")
        return 0
    fi

    print_stow_output "$output"
    collect_conflicts "$output"

    if [ ${#CONFLICT_PATHS[@]} -eq 0 ]; then
        FAILED_PACKAGES+=("$package")
        return 0
    fi

    echo -e "    ${YELLOW}Resolving conflicts by moving existing files into backup...${NC}"

    local relative_path
    for relative_path in "${CONFLICT_PATHS[@]}"; do
        if remove_repo_symlink_conflict "$relative_path"; then
            :
        else
            echo -e "    Backing up conflict: $relative_path"
            backup_conflicting_path "$relative_path"
        fi
    done

    if output=$(stow -v 1 -t "$HOME" "${extra_args[@]}" "$package" 2>&1); then
        print_stow_output "$output"
        RESOLVED_PACKAGES+=("$package")
        return 0
    fi

    print_stow_output "$output"
    FAILED_PACKAGES+=("$package")
}

# Change to dotfiles directory
cd "$DOTFILES_DIR"

# Deploy dotfiles with stow
echo -e "${YELLOW}Deploying dotfiles with stow...${NC}"

HOST_VARIANT="$(detect_host_variant)"
echo -e "${YELLOW}Host profile:${NC} $HOST_VARIANT"

if [ "$HOST_VARIANT" = "wsl" ]; then
    echo -e "${YELLOW}WSL note:${NC} For a fresh WSL setup, ${BLUE}./scripts/install-wsl-safe.sh${NC} is the recommended no-surprises entrypoint."
fi

# List of packages to stow
declare -a packages=(
    "bash"
    "git"
    "x11"
    "i3"
    "nvim"
    "ghostty"
    "starship"
    "rofi"
    "picom"
    "i3blocks"
    "lazygit"
    "flameshot"
    "nitrogen"
    "bin"
    "obsbot"
    "gtk-3.0"
    "gtk-4.0"
    "home-scripts"
    "kanata"
    "claude"
    "environment.d"
    "mise"
    "gh"
    "copyq"
    "opencode-common"
    "tmux"
)

if [ "$HOST_VARIANT" = "wsl" ]; then
    packages+=("opencode-wsl")
else
    packages+=("opencode-linux")
fi

declare -a STOWED_PACKAGES=()
declare -a RESOLVED_PACKAGES=()
declare -a FAILED_PACKAGES=()
declare -a MISSING_PACKAGES=()
declare -a CONFLICT_PATHS=()

for package in "${packages[@]}"; do
    if [ -d "$package" ]; then
        case "$package" in
            x11)
                stow_package "$package" "--ignore=^etc$"
                ;;
            *)
                stow_package "$package"
                ;;
        esac
    else
        echo -e "  ${YELLOW}Skipping:${NC} $package (directory not found)"
        MISSING_PACKAGES+=("$package")
    fi
done

echo ""
if [ ${#FAILED_PACKAGES[@]} -eq 0 ] && [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   Dotfiles Deployed Successfully!${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}   Dotfiles Deployment Incomplete${NC}"
    echo -e "${RED}========================================${NC}"
fi

echo ""
echo -e "${YELLOW}What was done:${NC}"
echo -e "  • Backed up existing dotfiles to: $BACKUP_DIR"
echo -e "  • Stowed packages: ${#STOWED_PACKAGES[@]}"
echo -e "  • Resolved package conflicts automatically: ${#RESOLVED_PACKAGES[@]}"
echo -e "  • Failed packages: ${#FAILED_PACKAGES[@]}"
echo -e "  • Missing package directories: ${#MISSING_PACKAGES[@]}"

if [ ${#RESOLVED_PACKAGES[@]} -gt 0 ]; then
    echo -e "  • Conflict resolution applied to: ${RESOLVED_PACKAGES[*]}"
fi

if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo -e "  • Packages still failing: ${FAILED_PACKAGES[*]}"
fi

if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    echo -e "  • Missing directories: ${MISSING_PACKAGES[*]}"
fi

echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review the symlinks: ${BLUE}ls -la ~/.bashrc ~/.gitconfig ~/.tmux.conf ~/.config/i3${NC}"
echo -e "  2. Source your bash config: ${BLUE}source ~/.bashrc${NC}"
echo -e "  3. Start tmux or reload it: ${BLUE}tmux source-file ~/.tmux.conf${NC}"
echo -e "  4. Log out and log back in for all changes to take effect"
echo ""
echo -e "${YELLOW}To undo:${NC}"
echo -e "  Run: ${BLUE}cd $DOTFILES_DIR && stow -D -t ~ bash git x11 i3 nvim ...${NC}"
echo ""

if [ ${#FAILED_PACKAGES[@]} -gt 0 ] || [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    exit 1
fi
