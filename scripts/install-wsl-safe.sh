#!/usr/bin/env bash
# WSL-safe installer: CLI/dev tools plus WSLg-friendly apps (no desktop/i3/media/system services)
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
  local backup_parent

  # Nothing to do if target doesn't exist
  if [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
    return 0
  fi

  if [ -z "${BACKUP_DIR:-}" ]; then
    BACKUP_DIR="$HOME/.dotfiles-wsl-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo -e "${YELLOW}Created backup dir:${NC} $BACKUP_DIR"
  fi

  if [ -e "$BACKUP_DIR/$rel_path" ] || [ -L "$BACKUP_DIR/$rel_path" ]; then
    if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
      rm -rf "$target_path"
    else
      rm -f "$target_path"
    fi
    return 0
  fi

  backup_parent="$BACKUP_DIR/$(dirname "$rel_path")"
  if [ -L "$backup_parent" ] || { [ -e "$backup_parent" ] && [ ! -d "$backup_parent" ]; }; then
    if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
      rm -rf "$target_path"
    else
      rm -f "$target_path"
    fi
    return 0
  fi

  mkdir -p "$backup_parent"
  mv "$target_path" "$BACKUP_DIR/$rel_path"
  echo -e "${YELLOW}Backed up:${NC} ~/$rel_path -> $BACKUP_DIR/$rel_path"
}

is_repo_symlink() {
  local target_path="$1"
  local resolved_path

  if [ ! -L "$target_path" ]; then
    return 1
  fi

  resolved_path="$(readlink -f "$target_path" 2>/dev/null || true)"
  [ -n "$resolved_path" ] && [[ "$resolved_path" == "$REPO_DIR/"* ]]
}

remove_repo_symlink_conflict() {
  local rel_path="$1"
  local current_path="$HOME/$rel_path"

  while [[ "$current_path" == "$HOME"/* ]]; do
    if is_repo_symlink "$current_path"; then
      echo -e "${YELLOW}Removing old repo symlink:${NC} ~/${current_path#$HOME/}"
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

collect_conflict_paths() {
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

stow_wsl_package() {
  local pkg="$1"
  local output
  local rel_path

  echo "Stowing: $pkg"

  if output=$(stow -v 1 -t "$HOME" "$pkg" 2>&1); then
    OK+=("stow:$pkg")
    return 0
  fi

  collect_conflict_paths "$output"

  for rel_path in "${CONFLICT_PATHS[@]}"; do
    if remove_repo_symlink_conflict "$rel_path"; then
      :
    else
      backup_conflict_target "$rel_path"
    fi
  done

  if stow -t "$HOME" "$pkg"; then
    OK+=("stow:$pkg")
  else
    FAIL+=("stow:$pkg")
  fi
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

# Core CLI/dev tools and WSLg-friendly apps
CORE=(
  "install-essentials.sh"
  "install-stow.sh"
  "install-git.sh"
  "install-gh.sh"
  "install-ripgrep.sh"
  "install-fd.sh"
  "install-fzf.sh"
  "install-terminal-utils.sh"
  "install-starship.sh"
  "install-vim.sh"
  "install-neovim.sh"
  "install-tmux.sh"
  "install-mise.sh"
  "install-python-tools.sh"
  "install-lazygit.sh"
  "install-glow.sh"
  "install-commitizen.sh"
  "install-codex.sh"
  "install-opencode.sh"
  "install-superset.sh"
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
backup_conflict_target ".bashrc"
backup_conflict_target ".profile"
backup_conflict_target ".gitconfig"
backup_conflict_target ".claude/settings.json"
backup_conflict_target ".claude/statusline.sh"

pushd "$REPO_DIR" >/dev/null || exit 1

# Keep this intentionally narrow for WSL terminal/dev workflow.
STOW_PKGS=(
  "bash"
  "git"
  "bin"
  "nvim"
  "lazygit"
  "starship"
  "tmux"
  "opencode-common"
  "opencode-wsl"
  "claude"
)

for pkg in "${STOW_PKGS[@]}"; do
  if [ -d "$pkg" ]; then
    stow_wsl_package "$pkg"
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
