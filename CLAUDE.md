# Dotfiles - Claude Documentation

This file provides context for Claude Code when working with this dotfiles repository.

## Purpose

This repository contains configuration files and automated installation scripts for setting up a complete Linux desktop environment based on i3 window manager. It uses GNU Stow for symlink management to deploy configs from this repo to the home directory.

**Note**: i3 keybinds are optimized for the Engrammer keyboard layout.

## Quick Reference

Essential commands and files:
- **Deploy configs**: `./scripts/stow-dotfiles.sh`
- **Full install**: `./scripts/master-install.sh`
- **Main i3 config**: `i3/.config/i3/config`
- **Reload i3**: `Mod+Shift+R` (in i3) or `i3-msg reload`
- **View keybinds**: `Mod+Shift+/` (in i3)
- **⚠️ Always sync**: `keybinds.md` ↔ `i3/config` when changing keybinds

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

## Installation System Architecture

The installation system uses a **layered architecture** to avoid redundancy:

```
┌─────────────────────────────────────────────┐
│ bootstrap.sh (Fresh Install Orchestrator)   │
│  1. Check git prerequisite                  │
│  2. Call master-install.sh                  │
│  3. Deploy dotfiles with stow               │
│  4. Run install-webapps.sh                  │
│  5. Post-install notes                      │
└─────────────────────────────────────────────┘
                    │
                    ├─ calls ─────────────────┐
                    │                          │
                    ▼                          ▼
┌──────────────────────────────┐   ┌──────────────────────┐
│ master-install.sh            │   │ stow-dotfiles.sh     │
│ (Package Installation Only)  │   │ (Config Deployment)  │
│  • Core System               │   └──────────────────────┘
│  • Window Manager Stack      │              │
│  • Development Tools         │              └─ deploys ─┐
│  • Browsers                  │                           │
│  • Communication             │                           ▼
│  • Productivity              │              ┌──────────────────────┐
│  • Media & Gaming            │              │ install-webapps.sh   │
│  • Networking                │              │ (Needs webapp script │
│  • Utilities                 │              │  from stow first)    │
│  • Custom Builds             │              └──────────────────────┘
└──────────────────────────────┘
                    │
                    └─ calls ───────┐
                                    │
                                    ▼
                    ┌─────────────────────────────┐
                    │ install-*.sh (52 scripts)   │
                    │ • Idempotent                │
                    │ • Check before install      │
                    │ • Self-contained            │
                    └─────────────────────────────┘
```

### Key Principles

1. **No Duplication**: bootstrap.sh calls master-install.sh rather than duplicating package lists
2. **Separation of Concerns**:
   - `install-*.sh` = Individual package installation
   - `master-install.sh` = Orchestrates all package installations
   - `bootstrap.sh` = Complete system setup (packages + dotfiles)
   - `stow-dotfiles.sh` = Dotfiles deployment only
3. **Idempotency**: All scripts safe to run multiple times
4. **Modularity**: Can run individual install scripts, master-install.sh, or full bootstrap

### Individual Install Scripts (`install-*.sh`)

Each script follows a consistent pattern:
1. Check if tool is already installed (exit early if yes)
2. Install via package manager (apt, flatpak, git clone, etc.)
3. Perform any post-install setup (symlinks, config, etc.)

All 52 scripts are **idempotent** - safe to run multiple times.

### Master Install Script

`scripts/master-install.sh` installs ALL packages in logical groups:
- Core System (essentials, stow, flatpak)
- Window Manager Stack (i3, rofi, picom, etc.)
- Development Tools (git, neovim, vscode, mise, etc.)
- Browsers (firefox, chromium, edge)
- Communication (discord, zoom, signal, whatsie, telegram)
- Productivity (obsidian, todoist, teams, etc.)
- Media & Gaming (obs, steam, retroarch, sunshine)
- Networking (tailscale)
- Utilities (nerd-font, localsend, webapp-script)
- Custom Builds (obsbot)

**Does NOT**: Deploy dotfiles or run install-webapps.sh (see notes below)

### Bootstrap Script

`bootstrap.sh` is the **orchestrator** for fresh installations:
1. Checks git is installed (prerequisite)
2. **Calls master-install.sh** to install all packages
3. Deploys dotfiles via stow (with automatic backup)
4. Runs install-webapps.sh (now that webapp script is deployed)
5. Shows post-install instructions

**Usage**: `./bootstrap.sh` (one command for complete setup)

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

### Secrets Management
- **Template**: `home-scripts/.secrets.template` - API keys template (tracked)
- **User file**: `~/.secrets` - Actual API keys (NOT tracked, user creates from template)
- **Bashrc**: Sources `~/.secrets` automatically
- Keys: JIRA_API_TOKEN, LINEAR_API_KEY, OPENAI_API_KEY, BRAVE_API_KEY, etc.

### Utility Scripts (not install scripts)
These scripts are for system maintenance, not package installation:
- `scripts/backup-system-state.sh` - Backup OpenClaw, HomeAssistant, secrets (encrypted)
- `scripts/setup-homeassistant.sh` - Create HomeAssistant + Matter Docker containers
- `scripts/fix-keyring.sh` - Fix GNOME keyring password prompts on i3

## Important Notes

### Script Architecture Rules

⚠️ **CRITICAL - Avoid Redundancy:**
- **NEVER** duplicate the list of install scripts between bootstrap.sh and master-install.sh
- bootstrap.sh should **CALL** master-install.sh, not replicate its functionality
- Only maintain the package list in ONE place: master-install.sh
- bootstrap.sh is an orchestrator, not a package installer

### Why This Matters

Previously, bootstrap.sh and master-install.sh both contained duplicate lists of all 52 install scripts. This caused:
- Maintenance burden (updating two files for every new package)
- Sync issues (scripts could get out of sync)
- Confusion about which file is the "source of truth"

**Current Architecture** (correct):
- `master-install.sh` = Source of truth for all package installations
- `bootstrap.sh` = Calls master-install.sh + adds dotfiles deployment
- No duplication, clear separation of concerns

### Package Installation Dependency Order

**Important**: `install-webapps.sh` requires the webapp script to be deployed first:
1. master-install.sh runs `install-webapp-script.sh` (deploys to ~/.local/bin via stow)
2. Dotfiles must be stowed for the script to be available
3. Then `install-webapps.sh` can use the webapp command

This is why:
- master-install.sh mentions webapps but doesn't run it (user must stow first)
- bootstrap.sh can run it automatically (stows in Phase 2, webapps in Phase 3)

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

3. Add **ONLY** to appropriate section in `scripts/master-install.sh`
   - **Do NOT** add to bootstrap.sh (it calls master-install.sh automatically)
   - Choose the right category: Core System, Window Manager, Development Tools, etc.
   - Use `run_script "install-<package>.sh"`

4. If it has keybinds, update both:
   - `i3/.config/i3/config`
   - `i3/.config/i3/keybinds.md`

5. Test both paths:
   - `./scripts/install-<package>.sh` (individual install)
   - `./scripts/master-install.sh` (includes your new script)
   - `./bootstrap.sh` (full system setup - automatically includes via master-install.sh)

### Modifying i3 Keybinds

**Always update both files:**
- `i3/.config/i3/config` - Actual keybind
- `i3/.config/i3/keybinds.md` - User documentation

The help file is shown with `Mod+Shift+/` - users rely on it being accurate.

### Testing Configuration Changes

**i3 changes:**
- Reload config: `Mod+Shift+R` or `i3-msg reload`
- Restart i3: `Mod+Shift+E` then select restart
- Check syntax: `i3-msg -t get_config` (returns current config if valid)

**Stow deployments:**
- Verify symlinks: `ls -la ~/<target>` to check if it points to dotfiles repo
- Re-stow: `cd ~/dotfiles && stow -R <package>` (restow to fix conflicts)
- Unstow: `cd ~/dotfiles && stow -D <package>` (remove symlinks)

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
- **Voice Input**: OpenWhispr (local or cloud Whisper transcription)
- **Config Management**: GNU Stow

## Important Notes

- All install scripts check for existing installations before installing
- The dotfiles use **Stow** for deployment (symlinks from repo to home)
- Mod key = Windows key (Mod4)
- The system is designed for HiDPI displays (150% scaling)

### Working with Claude Code

**Sudo Commands**: Claude Code cannot execute sudo commands via tool calls. When sudo is required:
1. Claude must stop and ask the user to run the command manually
2. Claude should provide the exact command in plain text for the user to copy
3. User will run the command in their terminal
4. Claude can continue after user confirms execution

## Maintenance Reminders

⚠️ **When making changes:**
- Keep `keybinds.md` in sync with `i3/config`
- Keep `kanata/.config/kanata/kanata.kbd` in sync with `kanata/docs/` diagrams
- Test install scripts for idempotency
- Update `README.md` if adding major new features
- Commit related changes together with clear messages
