# Dotfiles - Claude Documentation

This file provides context for Claude Code when working with this dotfiles repository.

## Purpose

This repository contains configuration files and automated installation scripts for setting up a complete Linux desktop environment based on i3 window manager. It uses GNU Stow for symlink management to deploy configs from this repo to the home directory.

## Structure

```
dotfiles/
├── scripts/           # Installation scripts
│   ├── install-*.sh  # Individual package installers
│   ├── master-install.sh  # Orchestrates all installations
│   └── stow-dotfiles.sh   # Deploys configs via stow
├── i3/               # i3 window manager configs
├── nvim/             # Neovim/LazyVim configs
├── picom/            # Compositor configs
├── flameshot/        # Screenshot tool configs
├── ghostty/          # Terminal emulator configs
├── rofi/             # App launcher configs
└── [other config dirs]/
```

## Installation System

### Individual Install Scripts (`install-*.sh`)

Each script follows a consistent pattern:
1. Check if tool is already installed (exit early if yes)
2. Install via package manager (apt, flatpak, git clone, etc.)
3. Perform any post-install setup (symlinks, config, etc.)

All scripts are **idempotent** - safe to run multiple times.

### Master Install Script

`scripts/master-install.sh` orchestrates installation in logical groups:
- Core System
- Window Manager Stack
- Development Tools
- Browsers
- Communication
- Productivity
- Media & Gaming
- Utilities

It calls individual install scripts via the `run_script()` function.

## Key Configuration Files

### i3 Window Manager
- **Config**: `i3/.config/i3/config`
- **Keybinds Help**: `i3/.config/i3/keybinds.md` - **MUST be kept in sync with config changes**

### Workflow
When adding/changing i3 keybinds or features:
1. Update `i3/.config/i3/config`
2. **Always update** `i3/.config/i3/keybinds.md` documentation
3. The help file is displayed in-app with `Mod+Shift+/`

### Other Important Docs
- **Main README**: `README.md` - General overview and setup instructions
- **This File**: `CLAUDE.md` - Claude-specific context

## Common Tasks

### Adding a New Package

1. Create `scripts/install-<package>.sh` following the pattern:
   ```bash
   #!/bin/bash
   set -e
   # Check if installed
   # Install if needed
   # Post-install setup
   ```

2. Make it executable: `chmod +x scripts/install-<package>.sh`

3. Add to appropriate section in `scripts/master-install.sh`

4. If it has keybinds, update both:
   - `i3/.config/i3/config`
   - `i3/.config/i3/keybinds.md`

### Modifying i3 Keybinds

**Always update both files:**
- `i3/.config/i3/config` - Actual keybind
- `i3/.config/i3/keybinds.md` - User documentation

The help file is shown with `Mod+Shift+/` - users rely on it being accurate.

## Technology Stack

- **OS**: Linux Mint / Ubuntu-based
- **Display Server**: X11
- **Window Manager**: i3
- **Compositor**: picom
- **Terminal**: Ghostty
- **Editor**: Neovim (LazyVim)
- **Launcher**: Rofi
- **Screenshots**: Flameshot
- **Screen Recording**: VokoscreenNG
- **Config Management**: GNU Stow

## Important Notes

- All install scripts check for existing installations before installing
- The dotfiles use **Stow** for deployment (symlinks from repo to home)
- i3 uses custom keybinds optimized for Engrammer keyboard layout
- Mod key = Windows key (Mod4)
- The system is designed for HiDPI displays (150% scaling)

## Maintenance Reminders

⚠️ **When making changes:**
- Keep `keybinds.md` in sync with `i3/config`
- Test install scripts for idempotency
- Update `README.md` if adding major new features
- Commit related changes together with clear messages
