# Dotfiles - Linux Mint + i3 Configuration

Comprehensive, modular, and idempotent dotfiles system for Linux Mint with i3 window manager.

## Overview

This repository contains my complete Linux Mint system configuration, including:

- **52+ modular installation scripts** for automated setup
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
- Discord (Flatpak)
- Zoom
- Signal (official repo)
- Whatsie (WhatsApp client, Flatpak)
- Teams for Linux (Flatpak)
- LocalSend (Flatpak)
- Telegram (Flatpak)

### Productivity
- Obsidian (Flatpak)
- Todoist (Flatpak)
- Sunsama (AppImage)
- Emote (emoji picker)

### Media & Gaming
- OBS Studio (latest PPA)
- Steam
- RetroArch
- Sunshine (game streaming)

### Utilities
- accountable2you (snap)
- glow (markdown renderer)
- Flatpak + Flathub
- Kanata (keyboard remapper with Enthium v13 layout)
- CopyQ (clipboard manager)

### Smart Home (Optional)
- Home Assistant (Docker)
- Matter Server (Docker) - for Apple Home / Matter device integration

### Custom Builds
- Obsbot Tiny 2 controller (Rust)

### Web Applications (PWAs)
Created using custom webapp script (via install-webapps.sh):
- ChatGPT
- Claude
- Gmail
- Outlook
- Linear
- Jira
- Confluence
- Limitless
- Apple Music
- Brain.fm

## Dotfiles Structure

```
~/dotfiles/
├── bash/                    # .bashrc, .profile (sources ~/.secrets)
├── git/                     # .gitconfig
├── x11/                     # .Xresources, .xprofile (HiDPI scaling)
├── i3/.config/i3/          # Complete i3 setup + keybinds.md
├── nvim/.config/nvim/      # LazyVim configuration
├── ghostty/.config/ghostty/
├── rofi/.config/rofi/
├── picom/.config/picom/
├── i3blocks/.config/i3blocks/
├── lazygit/.config/lazygit/
├── flameshot/.config/flameshot/
├── kanata/.config/kanata/  # Enthium v13 keyboard layout
├── kanata/docs/             # Kanata layer diagrams + KLE JSON sources
├── nitrogen/.config/nitrogen/
├── signal/.config/Signal/
├── sunshine/.config/sunshine/
├── retroarch/.config/retroarch/
├── copyq/.config/copyq/    # Clipboard manager commands
├── environment.d/          # HiDPI env vars (GDK_SCALE, QT_SCALE_FACTOR)
├── gh/.config/gh/          # GitHub CLI preferences
├── mise/.config/mise/      # Tool version manager config
├── bin/.local/bin/         # webapp script, lazygit, sunsama
├── home-scripts/           # .secrets.template for API keys
├── obsbot/.local/          # Obsbot source and binary
└── scripts/                # 55+ installation scripts
```

## Kanata Layout Documentation

Kanata keymap visuals and their editable sources are in `kanata/docs/`.

- Config source of truth: `kanata/.config/kanata/kanata.kbd`
- Diagram source of truth: `kanata/docs/*.json` (Keyboard Layout Editor format)
- Rendered diagrams: `kanata/docs/*.png`

When changing Kanata layers, keep config and diagrams in sync. See
`kanata/docs/README.md` for the update workflow and KLE link.

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
# Note: Use 'x' format for dimensions, not comma
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
  - Mouse auto-centering (on focus and new windows)
  - DPI management with xrandr
  - Monitor management (main-only, dual, streaming modes)
  - Environment scaling setup
  - Scaling diagnostics tool

### Key Bindings

**App Launchers** (Mod+letter for quick access):
- 20+ app hotkeys for instant launching
- Organized by category: Development, Productivity, Work Tools, Communication
- See `~/.config/i3/keybinds.md` for complete reference or press **Mod+Shift+?**

**Window Management**:
- Mod+Escape - Focus parent container (manipulate groups of windows)
- Vim-style navigation (hjkl)
- Split controls for 2x2 grids and complex layouts

## Secrets Management

API keys and tokens are stored in `~/.secrets` (not tracked in git):

```bash
# First time setup - copy template and fill in your keys
cp ~/dotfiles/home-scripts/.secrets.template ~/.secrets
chmod 600 ~/.secrets
nano ~/.secrets
```

The `.bashrc` automatically sources this file. Keys included:
- `JIRA_API_TOKEN` - Atlassian API token
- `LINEAR_API_KEY` - Linear project management
- `OPENAI_API_KEY` - OpenAI API
- `BRAVE_API_KEY` - Brave Search API
- Add your own as needed

## System State Backup

For data NOT in dotfiles (OpenClaw, HomeAssistant, etc.), use the backup script:

```bash
# Run manually
./scripts/backup-system-state.sh

# Or use hotkey: Mod+Control+b
```

This creates an **encrypted archive** in `~/system-backup/` containing:
- OpenClaw (memory, credentials, agent auth, skills config)
- HomeAssistant config and token
- Matter server device pairings
- `~/.secrets` file
- GOG CLI, OpenCode, JIRA configs
- Keyrings

Upload the encrypted backup to your cloud storage (iCloud, Google Drive, etc.) for disaster recovery.

## Dotfiles Backup

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

### Keyring Password Prompts

If you get password prompts for Edge, git, or GOG on startup, the GNOME keyring password doesn't match your login password:

```bash
./scripts/fix-keyring.sh
```

Choose option 1 to reset all keyrings, then log out/in and set the new keyring password to match your login password.

### HomeAssistant / Matter Server Setup

To set up Home Assistant with Matter support (for Apple Home devices):

```bash
# Install Docker first if needed
sudo apt install docker.io
sudo usermod -aG docker $USER
# Log out and back in

# Run the setup script
./scripts/setup-homeassistant.sh
```

Access Home Assistant at http://localhost:8123

Data is stored in:
- `~/homeassistant/` - HA config, automations, database
- `~/matter-server/` - Matter device pairings

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
**Last Updated**: February 2026
