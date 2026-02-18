#!/usr/bin/env bash
# WSL-safe installer: CLI/dev tools only (no desktop/i3/media/system services)
# Usage:
#   ./scripts/install-wsl-safe.sh
set -u

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

is_wsl() {
  grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null
}

run_script() {
  local script="$1"
  if [ ! -f "$SCRIPT_DIR/$script" ]; then
    echo -e "${YELLOW}Skipping missing script:${NC} $script"
    return 0
  fi

  echo -e "${BLUE}==>${NC} Running $script"
  if bash "$SCRIPT_DIR/$script"; then
    OK+=("$script")
  else
    FAIL+=("$script")
    echo -e "${RED}Failed:${NC} $script"
  fi
  echo ""
}

backup_conflict_target() {
  local rel_path="$1"
  local target_path="$HOME/$rel_path"

  # Nothing to do if target doesn't exist
  if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
    return 0
  fi

  if [ -z "${BACKUP_DIR:-}" ]; then
    BACKUP_DIR="$HOME/.dotfiles-wsl-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo -e "${YELLOW}Created backup dir:${NC} $BACKUP_DIR"
  fi

  mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
  mv "$target_path" "$BACKUP_DIR/$rel_path"
  echo -e "${YELLOW}Backed up:${NC} ~/$rel_path -> $BACKUP_DIR/$rel_path"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}      WSL-Safe Dotfiles Installer       ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

if ! is_wsl; then
  echo -e "${YELLOW}Warning:${NC} This does not look like WSL. Script continues anyway."
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo -e "${RED}sudo not found.${NC} This script expects a standard Ubuntu/WSL setup."
  exit 1
fi

echo -e "${YELLOW}Refreshing sudo credentials...${NC}"
sudo -v || exit 1
echo ""

# Make sure user-local bins and mise shims are visible to child scripts
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

OK=()
FAIL=()

# Core CLI/dev tools (WSL-safe)
CORE=(
  "install-essentials.sh"
  "install-stow.sh"
  "install-git.sh"
  "install-gh.sh"
  "install-ripgrep.sh"
  "install-fd.sh"
  "install-fzf.sh"
  "install-vim.sh"
  "install-neovim.sh"
  "install-tmux.sh"
  "install-mise.sh"
  "install-python-tools.sh"
  "install-lazygit.sh"
  "install-glow.sh"
  "install-commitizen.sh"
  "install-opencode.sh"
  "install-claude-cli.sh"
  "install-openspec.sh"
)

for s in "${CORE[@]}"; do
  run_script "$s"
done

# Stow dotfiles (safe subset only, avoid desktop WM configs in WSL)
echo -e "${BLUE}==>${NC} Stowing WSL-safe dotfiles subset"
mkdir -p "$HOME/.config"

# Pre-backup known conflict-prone files so stow can run cleanly
backup_conflict_target ".bashrc" "bash/.bashrc"
backup_conflict_target ".profile" "bash/.profile"
backup_conflict_target ".gitconfig" "git/.gitconfig"
backup_conflict_target ".claude/settings.json" "claude/.claude/settings.json"
backup_conflict_target ".claude/statusline.sh" "claude/.claude/statusline.sh"

pushd "$REPO_DIR" >/dev/null || exit 1

# Keep this intentionally narrow for WSL terminal/dev workflow.
STOW_PKGS=(
  "bash"
  "git"
  "nvim"
  "lazygit"
  "claude"
)

for pkg in "${STOW_PKGS[@]}"; do
  if [ -d "$pkg" ]; then
    echo "Stowing: $pkg"
    if stow -t "$HOME" "$pkg"; then
      OK+=("stow:$pkg")
    else
      FAIL+=("stow:$pkg")
    fi
  else
    echo -e "${YELLOW}Skipping missing package:${NC} $pkg"
  fi
done

popd >/dev/null || exit 1
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}               Summary                  ${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Succeeded:${NC} ${#OK[@]}"
for x in "${OK[@]}"; do echo "  - $x"; done

echo -e "${RED}Failed:${NC} ${#FAIL[@]}"
for x in "${FAIL[@]}"; do echo "  - $x"; done

echo ""
if [ "${#FAIL[@]}" -gt 0 ]; then
  echo -e "${YELLOW}Completed with failures.${NC} Re-run after fixing failed items."
  exit 1
fi

echo -e "${GREEN}WSL-safe install completed successfully.${NC}"
