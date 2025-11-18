# Dotfiles - Linux Mint + i3 Configuration

Comprehensive, modular, and idempotent dotfiles system for Linux Mint with i3 window manager.

## Overview

This repository contains my complete Linux Mint system configuration, including:

- **50+ modular installation scripts** for automated setup
- **i3 window manager** configuration with custom keybindings and scripts
- **Neovim** setup with LazyVim and custom plugins
- **Development environment** (Git, Node.js, Rust, Python, VS Code)
- **Productivity tools** (Obsidian, Todoist, Teams, Sunsama, etc.)
- **Web applications** as PWAs using custom webapp script
- **All dotfiles** managed with GNU Stow for easy deployment

## Philosophy

Inspired by the "You installed Omarchy, Now What?" approach, adapted for Linux Mint:

1. **Idempotent scripts** - Safe to run multiple times
2. **Modular design** - Install only what you need
3. **Latest packages** - Uses PPAs, Flatpak, and official repos (not Ubuntu's outdated packages)
4. **Portable** - One repository, easy to deploy on any Linux Mint system

## Quick Start

### Fresh Linux Mint Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/shanekunz/Linux-IroncladMint.git ~/dotfiles
cd ~/dotfiles

# Run the bootstrap script (installs core packages + deploys dotfiles)
chmod +x bootstrap.sh
./bootstrap.sh
```

The bootstrap script will:
1. Install essential prerequisites (git, stow, flatpak)
2. Install core packages (i3, neovim, terminal tools, dev tools)
3. Install common applications (browsers, discord, obsidian, vscode)
4. Deploy all dotfiles using GNU Stow
5. Backup any existing configs to `~/.config-backup-TIMESTAMP/`

### Existing System (Selective Install)

```bash
# Install individual packages as needed
./scripts/install-PACKAGE.sh

# Example: Install only neovim and i3
./scripts/install-neovim.sh
./scripts/install-i3.sh

# Deploy dotfiles with stow (from the dotfiles directory)
cd ~/dotfiles
stow nvim    # Just neovim config
stow i3      # Just i3 config
stow */      # All configs (skip scripts and .git)
```

## What Gets Installed

### Core System
- GNU Stow (dotfiles management)
- Build essentials, curl, wget, git
- Caskaydia Cove Nerd Font

### i3 Window Manager Stack
- i3-wm, i3blocks, i3lock
- rofi (application launcher)
- picom (compositor)
- nitrogen (wallpaper manager)
- flameshot (screenshots)
- dunst (notifications)
- Network manager applet
- Blueman (Bluetooth)
- feh, arandr

### Development Tools
- Git (latest via PPA)
- GitHub CLI
- Lazygit (TUI)
- Neovim (latest via PPA)
- Visual Studio Code
- Ghostty terminal
- **mise** - Universal version manager (Node.js, .NET, Rust, Python, Go, and 100+ tools)
- Claude CLI

### Browsers
- Firefox (Mozilla PPA)
- Chromium (snap)
- Microsoft Edge

### Communication
- Discord
- Zoom
- Signal (official repo)
- WhatSie (WhatsApp client)

### Productivity
- Obsidian (Flatpak)
- Todoist (Flatpak)
- Teams for Linux (Flatpak)
- Sunsama
- Emote (emoji picker)

### Media & Gaming
- OBS Studio (latest PPA)
- Steam
- RetroArch
- Sunshine (game streaming)

### Utilities
- accountable2you (snap)
- LocalSend (Flatpak)
- Flatpak + Flathub

### Custom Builds
- Obsbot Tiny 2 controller (Rust)

### Web Applications (PWAs)
Created using custom webapp script:
- ChatGPT
- Claude
- Linear
- Limitless
- Apple Music
- Brain.fm
- Outlook
- Jira
- Confluence

## Dotfiles Structure

```
~/dotfiles/
├── bash/                    # .bashrc, .profile
├── git/                     # .gitconfig
├── x11/                     # .Xresources
├── i3/.config/i3/          # Complete i3 setup
├── nvim/.config/nvim/      # LazyVim configuration
├── ghostty/.config/ghostty/
├── rofi/.config/rofi/
├── picom/.config/picom/
├── i3blocks/.config/i3blocks/
├── lazygit/.config/lazygit/
├── flameshot/.config/flameshot/
├── nitrogen/.config/nitrogen/
├── signal/.config/Signal/
├── sunshine/.config/sunshine/
├── retroarch/.config/retroarch/
├── bin/.local/bin/         # webapp script, lazygit, sunsama
├── obsbot/.local/          # Obsbot source and binary
└── scripts/                # 51 installation scripts
```

## Neovim Configuration

The Neovim setup uses LazyVim as a base with your custom plugins tracked directly in the dotfiles repo.

### Custom Plugins

Your custom plugins are in `~/dotfiles/nvim/.config/nvim/lua/plugins/`:
- `alpha.lua` - Dashboard
- `dap-dotnet.lua` - .NET debugging
- `sql.lua` - SQL tools
- `example.lua` - Template for new plugins

Add new plugins by creating files in this directory following LazyVim's plugin format.

### Update LazyVim Base (Optional)

To pull the latest LazyVim starter template updates:

```bash
cd ~/dotfiles

# Add LazyVim as a remote (one-time setup)
git remote add lazyvim-upstream https://github.com/LazyVim/starter

# Fetch latest LazyVim changes
git fetch lazyvim-upstream

# Create a temporary branch to review changes
git checkout -b lazyvim-update

# Pull LazyVim changes into nvim folder
git checkout lazyvim-upstream/main -- nvim/.config/nvim/init.lua
git checkout lazyvim-upstream/main -- nvim/.config/nvim/lua/config/lazy.lua
git checkout lazyvim-upstream/main -- nvim/.config/nvim/lua/config/options.lua
# Add other base files you want to update

# Review changes
git diff main

# If satisfied, merge into main
git checkout main
git merge lazyvim-update

# Delete temporary branch
git branch -d lazyvim-update

# Re-add your custom plugins if they were overwritten
# Your plugins should still be in lua/plugins/
```

**Note:** LazyVim updates are usually not necessary. Only do this if you want new LazyVim features or fixes. Your custom plugins in `lua/plugins/` will not be affected by LazyVim updates.

## Individual Script Usage

All scripts are idempotent and can be run independently:

```bash
# Install a specific tool
./scripts/install-neovim.sh

# Install category
./scripts/install-i3.sh
./scripts/install-rofi.sh
# ... etc

# Or use the master script
./scripts/master-install.sh
```

## Stow Management

### Deploy Dotfiles

```bash
cd ~/dotfiles
stow bash git x11 i3 nvim ghostty rofi picom i3blocks
```

### Undeploy Dotfiles

```bash
cd ~/dotfiles
stow -D bash git x11 i3 nvim ghostty rofi picom i3blocks
```

### Deploy Individual Package

```bash
cd ~/dotfiles
stow nvim  # Just deploy Neovim config
```

## Web Apps

The custom `webapp` script creates Progressive Web Apps using Microsoft Edge in app mode:

### Create Custom Web App

```bash
webapp "App Name" "https://example.com" "1400x900"
```

### Customize Jira/Confluence URLs

Create `webapp-urls.local.conf` in the dotfiles directory to override URLs:

```bash
cp webapp-urls.conf webapp-urls.local.conf
nano webapp-urls.local.conf  # Edit your organization's URLs
./scripts/install-webapps.sh  # Re-run to apply changes
```

The `.local.conf` file is gitignored and won't be committed to your repository.

## i3 Configuration

### Custom Features

- **Mod key**: Windows key (Mod4)
- **Gaps**: 8px inner, 4px outer
- **HiDPI Scaling**: Comprehensive 150% scaling for 4K displays
  - Xft.dpi, GTK, Qt, and Electron apps all configured
  - Automatic cursor scaling
  - Environment variables managed via .xprofile
- **Custom scripts** in `~/.config/i3/scripts/`:
  - Mouse centering on focus
  - DPI management with xrandr
  - Monitor management (main-only, dual, streaming modes)
  - Environment scaling setup

### Key Bindings

**App Launchers** (Mod+letter for quick access):
- 20+ app hotkeys for instant launching
- Organized by category: Development, Productivity, Work Tools, Communication
- See `~/.config/i3/keybinds.md` for complete reference or press **Mod+Shift+?**

**Window Management**:
- Mod+Escape - Focus parent container (manipulate groups of windows)
- Vim-style navigation (hjkl)
- Split controls for 2x2 grids and complex layouts

## Backup

The `stow-dotfiles.sh` script automatically backs up existing dotfiles before deployment:

```
~/dotfiles-backup-YYYYMMDD-HHMMSS/
```

## Maintenance

### Update All System Packages

```bash
sudo apt update && sudo apt upgrade
flatpak update
snap refresh
```

### Update LazyVim

See the [Neovim Configuration](#neovim-configuration) section above for instructions on pulling LazyVim upstream updates.

### Update Development Tools with mise

```bash
mise upgrade           # Upgrade mise itself
mise up                # Update all installed tools
mise use --global node@lts    # Update Node.js
mise use --global dotnet@latest  # Update .NET
mise use --global rust@latest    # Update Rust
```

## Package Version Strategy

This setup prioritizes **latest versions** over Ubuntu's stable (often outdated) packages:

- **PPAs** for Git, Neovim, Firefox, OBS
- **Flatpak** for Obsidian, Todoist, Teams (always latest)
- **Official repos** for VS Code, Signal, Edge, GitHub CLI
- **Direct downloads** for Discord, Zoom
- **mise** - Universal version manager for Node.js, .NET, Rust, Python, Go, and more

## Troubleshooting

### Bootstrap Script Issues

**PPA not available for your version:**
- Edit the script to use a different PPA or install from apt
- Or skip that package (scripts are modular)

**Package not found:**
- Check if the package name changed
- Update the script with the new package name

**Permission denied:**
```bash
chmod +x bootstrap.sh
chmod +x scripts/*.sh
```

**Script fails partway through:**
- Check the error message for the specific package
- Fix that individual install script
- Re-run bootstrap (scripts are idempotent, safe to re-run)

### Stow Conflicts

If stow reports conflicts:

```bash
# Backup existing configs are automatically created at:
~/.config-backup-TIMESTAMP/

# Or manually move conflicting files:
mv ~/.bashrc ~/.bashrc.backup
cd ~/dotfiles && stow bash
```

### Flatpak Apps Not Appearing

Log out and log back in after installing Flatpak apps, or update desktop database:

```bash
sudo update-desktop-database
```

### Web Apps Not Working

Ensure Microsoft Edge is installed and the webapp script is executable:

```bash
which microsoft-edge
chmod +x ~/.local/bin/webapp
```

### Individual Script Failures

All scripts are independent. If one fails:

```bash
# Check what went wrong
cat scripts/install-PACKAGE.sh

# Fix the issue and re-run just that script
./scripts/install-PACKAGE.sh
```

## System Requirements

- Linux Mint (tested on Linux Mint 21+)
- 10+ GB free disk space (for all programs)
- Internet connection

## Credits

- Inspired by the "You installed Omarchy, Now What?" workflow
- LazyVim by [@folke](https://github.com/folke)
- GNU Stow for dotfiles management

## License

MIT License - Feel free to use and modify for your own setup!

---

**Author**: Shane Kunz
**Email**: shanemkunz@gmail.com
**Last Updated**: November 2025
