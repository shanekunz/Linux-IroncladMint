# Dotfiles - Linux Mint + i3 Configuration

Comprehensive, modular, and idempotent dotfiles system for Linux Mint with i3 window manager.

## Overview

This repository contains my complete Linux Mint system configuration, including:

- **52+ modular installation scripts** for automated setup
- **i3 window manager** configuration with custom keybindings and scripts
- **Neovim** setup with LazyVim and custom plugins
- **Development environment** (Git, Node.js, Rust, Python, VS Code, tmux)
- **Productivity tools** (Obsidian, Todoist, Teams, Sunsama, etc.)
- **Web applications** as PWAs using custom webapp script
- **All dotfiles** managed with GNU Stow for easy deployment
- **User services** for persistent background apps via `systemd --user`

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
./scripts/stow-dotfiles.sh  # Recommended: deploy managed packages with backups
stow nvim                   # Just neovim config
stow i3                     # Just i3 config
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
- tmux
- Starship prompt
- eza, bat, zoxide, btop
- **mise** - Universal version manager (Node.js, .NET, Rust, Python, Go, and 100+ tools)
- OpenCode
- Claude CLI
- Hermes Agent
- Herdr + Collie, with opt-in authenticated Cloudflare sharing

#### Low Lantern: temporary browser access

Minimal Linux setup for [Low Lantern](https://github.com/shanekunz/low-lantern):

```bash
git clone https://github.com/shanekunz/low-lantern.git ~/projects/low-lantern
./scripts/install-herdr-collie.sh
python3 scripts/low-lantern-share.py start
```

The installer uses mise for Herdr/Caddy (and cloudflared if missing) and Collie's
checksum-verified binary installer. It is also included in `master-install.sh`.
Sharing starts only with the explicit `start` command. This requires a running
systemd user manager, Python 3, and an existing authenticated agent CLI.

The sharing helper prints an HTTPS URL and generated browser-login credentials.
It runs Herdr, a loopback-only Caddy password gate, and a Cloudflare quick tunnel
as user services; Collie connects to Herdr and trusts only the proxy's overwritten
device header for writes. Both the UI and API require the password. Credentials
and generated config stay in `~/.local/state/low-lantern-share/` (private permissions).
It checks public authentication and backend connectivity before reporting success.

Start a workspace and your already-authenticated agent if this is the first run:

```bash
herdr workspace create --cwd ~/projects/low-lantern --label Low-Lantern
# Use the root_pane.pane_id returned above:
herdr agent start friend --kind opencode --pane w1:p1
# Or open `herdr` locally and launch your preferred agent in its shell.
```

Open the URL, enter the username/password, select the agent, and type a reply.
The friend operates your real terminal and existing agent account. A browser tab
is sufficient; Collie also offers PWA installation in Settings.
The September 20 Linux smoke test used OpenCode with `openai/gpt-6-astra` and
verified a reply through Collie's browser UI. Codex's saved ChatGPT credentials
were expired; it needs a fresh `codex login` before use. Collie's terminal view
works without an agent session-history integration.

```bash
python3 scripts/low-lantern-share.py status  # URL, credentials, process status
python3 scripts/low-lantern-share.py stop    # close public access; keep agents alive
```

The temporary URL lasts while its tunnel process runs; restarting the tunnel
changes it. Rerun `start` to obtain/configure the new address after a stop, crash,
or reboot. Quick-tunnel services are session-only, not boot-enabled. The host
must stay awake and online. Logs: `journalctl --user -u low-lantern-tunnel.service`
(also `low-lantern-herdr.service`, `low-lantern-proxy.service`, and `collie.service`).

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
- ChatGPT (official Linux desktop app)

### Media & Gaming

- OBS Studio (latest PPA)
- Shotcut (video editor for quick trims and short-form edits, stable Flathub release)
- Steam
- RetroArch
- Sunshine (game streaming)

Install or update Shotcut independently with `./scripts/install-shotcut.sh`
(requires `./scripts/install-flatpak.sh` first). Uses the system-wide stable
Flathub package [recommended by Shotcut](https://shotcut.org/download/), with
dependencies, app-menu integration, and updates managed by Flatpak.
Launch from the app menu or with `flatpak run org.shotcut.Shotcut`.

On NVIDIA systems, the installer also ensures Flatpak has a graphics driver
matching the running kernel driver and any newer driver installed by APT for
the next boot. If Shotcut stops launching after an NVIDIA
update with `Could not initialize GLX`, rerun `./scripts/install-shotcut.sh`.

The installer applies personal timeline shortcuts: **`,`** splits at the playhead,
and **`.`** ripple-deletes the selected clip (closes the gap). **S/X** also work;
the default comma/period Nudge shortcuts are cleared to prevent conflicts.
Reapply with `python3 scripts/configure-shotcut.py`, then save your project and
restart Shotcut. Further changes are available under **Help > Actions and Shortcuts**.

For quick TikTok cuts: add your clip to the timeline, press **`,`** at the start
and end of the unwanted section, select that segment, and press **`.`**.
**Settings > Timeline > Rectangle Selection** lets you drag-select whole clips;
it does not select a time slice inside an unsplit clip. Drag a clip's left/right
edge to trim its beginning/end instead.
Export as H.264/MP4, retaining the source's vertical dimensions for portrait footage.
See the [Shotcut shortcuts](https://shotcut.org/howtos/keyboard-shortcuts/).

### Utilities

- accountable2you (snap)
- glow (markdown renderer)
- Flatpak + Flathub
- Kanata (keyboard remapper with Enthium v15 layout)
- CopyQ (clipboard manager)

### Smart Home (Optional)

- Home Assistant (Docker)
- Matter Server (Docker) - for Apple Home / Matter device integration

### Custom Builds

- Obsbot Tiny 2 controller (Rust)

### Web Applications (PWAs)

Created using custom webapp script (via install-webapps.sh):

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
├── starship/.config/starship.toml
├── tmux/.tmux.conf
├── rofi/.config/rofi/
├── picom/.config/picom/
├── i3blocks/.config/i3blocks/
├── lazygit/.config/lazygit/
├── flameshot/.config/flameshot/
├── kanata/.config/kanata/  # Enthium v15 keyboard layout
├── kanata/docs/             # Kanata layer diagrams + KLE JSON sources
├── nitrogen/.config/nitrogen/
├── copyq/.config/copyq/    # Clipboard manager commands
├── environment.d/          # HiDPI env vars (GDK_SCALE, QT_SCALE_FACTOR)
├── systemd-user/           # User-level systemd services
├── gh/.config/gh/          # GitHub CLI preferences
├── mise/.config/mise/      # Tool version manager config
├── claude/.claude/         # Claude settings, statusline, commands, agents, skills
├── opencode-common/.config/opencode/ # Shared OpenCode commands, agents, themes, CLI settings
├── opencode-linux/.config/opencode/ # Linux-specific OpenCode config
├── opencode-wsl/.config/opencode/ # WSL-specific OpenCode config and skills
├── hermes/.hermes/       # Personal Hermes identity, memory, tools, and curated skills
├── bin/.local/bin/         # webapp script, lazygit, sunsama
├── home-scripts/           # .secrets.template for API keys
├── obsbot/.local/          # Obsbot source and binary
└── scripts/                # 55+ installation scripts
```

## AI Tooling

This repo now carries your personal Claude, OpenCode, and Hermes setup plus the shared AI workflow assets you use day to day.

- Claude keeps personal settings in `claude/.claude/settings.json` and `claude/.claude/statusline.sh`.
- OpenCode V2 keeps shared UI config in `opencode-common/.config/opencode/themes/` and `cli.json`; host configs and file-based agents use native V2 fields.
- Shared OpenCode slash commands and agents live in `opencode-common/.config/opencode/`.
- The skill tracker uses the V2 plugin API in `plugins/skill-tracker/index.js` and keeps the existing usage/audit files. Run its regression test with `node --test scripts/tests/skill-tracker.test.mjs`.
- OpenCode host-specific MCP defaults and skills live in `opencode-linux/.config/opencode/` and `opencode-wsl/.config/opencode/`.
- PostHog MCP uses `https://mcp.posthog.com/mcp`. Codex and Linux OpenCode keep the endpoint in their tracked host configs. Add it to Claude with `claude mcp add --transport http --scope user posthog https://mcp.posthog.com/mcp`. Authenticate each client with `codex mcp login posthog`, `claude mcp login posthog`, and `opencode mcp auth posthog`; OAuth credentials stay machine-local. The PostHog wizard v2.94 writes the old OpenCode MCP shape. For OpenCode V2 use `opencode mcp add posthog --url https://mcp.posthog.com/mcp --global`, which writes `mcp.servers.posthog`. Preserve the Codex config symlink when a CLI atomically replaces it.
- Hermes uses a curated Claw profile in `hermes/.hermes/`, with Docker-backed tools, approval-gated memory and skill learning, and credential-free integration scaffolding.

This keeps your machine self-contained in one dotfiles repo while preserving the reusable AI tooling you were previously sourcing from a separate repository.

## User Services

The repo keeps service definitions for long-running background apps without
requiring all of them to run at boot. The current startup policy, preserved
data locations, Docker workloads, and recovery commands are documented in
[`OPTIONAL_SERVICES.md`](OPTIONAL_SERVICES.md).

Hermes is the active assistant gateway. Ollama, mcporter, OpenClaw, and the
OpenCode Telegram topics bot are installed but manual-start by default. Restore
that policy at any time with:

```bash
./scripts/disable-optional-autostart.sh
```

### OpenCode Telegram Bot

This repo includes `systemd-user/.config/systemd/user/opencode-telegram-group-topics-bot.service` plus the helper command `~/.local/bin/opencode-telegram-group-topics-bot-service`.

Why keep the service definition:

- Starts and stops cleanly without removing the project or its configuration
- Can be enabled again if the bot returns to regular use
- Uses the same `.env` that already lives in your bot repo

One-time setup:

```bash
cd ~/projects/opencode-telegram-group-topics-bot
npm install
npm run build
cd ~/dotfiles
./scripts/stow-dotfiles.sh
systemctl --user daemon-reload
systemctl --user start opencode-telegram-group-topics-bot.service
```

Useful commands:

```bash
opencode-telegram-group-topics-bot-service status
opencode-telegram-group-topics-bot-service logs
opencode-telegram-group-topics-bot-service stop
opencode-telegram-group-topics-bot-service start
opencode-telegram-group-topics-bot-service restart
```

Local development handoff:

```bash
opencode-telegram-group-topics-bot-service stop
cd ~/projects/opencode-telegram-group-topics-bot
npm run dev
```

That uses the same repo-local config as the service. When you are done testing, stop your manual process and start the service again:

```bash
opencode-telegram-group-topics-bot-service start
```

If it becomes a daily service again, enable autostart explicitly:

```bash
systemctl --user enable --now opencode-telegram-group-topics-bot.service
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
./scripts/stow-dotfiles.sh
```

This script auto-detects WSL vs native Linux and stows the matching OpenCode host package:

- `opencode-common` on every machine
- `opencode-wsl` on WSL
- `opencode-linux` on native Linux

If you need to force the host profile for testing, use:

```bash
DOTFILES_HOST=wsl ./scripts/stow-dotfiles.sh
DOTFILES_HOST=linux ./scripts/stow-dotfiles.sh
```

### Undeploy Dotfiles

```bash
cd ~/dotfiles
stow -D -t ~ bash git x11 i3 nvim ghostty starship rofi picom i3blocks lazygit flameshot nitrogen bin obsbot gtk-3.0 gtk-4.0 home-scripts kanata claude environment.d mise gh copyq opencode-common tmux opencode-linux opencode-wsl
```

### Deploy Individual Package

```bash
cd ~/dotfiles
stow nvim  # Just deploy Neovim config
```

Do not manually stow both `opencode-linux` and `opencode-wsl` into the same home directory. The helper script above picks the correct one and also migrates old repo-owned symlinks if you switch layouts later.

### WSL-Only Install Path

For a terminal-focused WSL setup, use the narrower installer instead of `master-install.sh`:

```bash
./scripts/install-wsl-safe.sh
```

That installs a CLI-safe package set, stows only the WSL-friendly dotfiles subset, and avoids desktop/i3/media services that do not belong in WSL.

If you accidentally run `./scripts/master-install.sh`, `./bootstrap.sh`, or `./scripts/bootstrap.sh` inside WSL, they now stop and require an explicit `y` confirmation before continuing with the full Linux Mint path.

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

For data NOT in dotfiles (retired OpenClaw state, Hermes runtime state,
HomeAssistant, etc.), use the backup script:

```bash
# Run manually
./scripts/backup-system-state.sh

# Or use hotkey: Mod+Control+b
```

This creates an **encrypted archive** in `~/system-backup/` containing:

- OpenClaw (complete retained state, including workspaces and history)
- Hermes (memory, sessions, authentication, and runtime databases)
- mcporter configuration and credentials
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

For the full repo-specific update flow, run:

```bash
./scripts/update-system.sh
```

This script safely:

- Pulls the latest dotfiles changes with `git pull --ff-only` when the repo is clean
- Runs `apt`, `flatpak`, and `snap` updates where available
- Ensures system Flatpaks have NVIDIA graphics drivers matching both the running driver and the installed APT driver before reboot
- Updates `mise` itself and installed `mise`-managed tools
- Re-runs the dotfiles install scripts (`master-install.sh` on Linux, `install-wsl-safe.sh` on WSL), including managed direct installs such as Beads, Claude Code, OpenCode, fzf, Kanata, LazyGit, Starship, and Sunshine
- Re-deploys dotfiles with `stow-dotfiles.sh`

Some desktop applications use their own built-in updater and are intentionally not replaced by this script.

After an NVIDIA driver update, reboot to load the new kernel driver. The update
script prepares its matching Flatpak driver before reboot; it also retains the
match for the currently running driver. To run just this check and repair, use
`./scripts/sync-flatpak-nvidia.sh`. It skips systems without Flatpak or NVIDIA and
leaves installed matching drivers in place. If a required driver cannot be
downloaded from Flathub, it reports the failure and stops the update.

Manual equivalent:

```bash
sudo apt update && sudo apt upgrade
flatpak update
./scripts/sync-flatpak-nvidia.sh
snap refresh
```

### Update LazyVim

See the [Neovim Configuration](#neovim-configuration) section above for instructions on pulling LazyVim upstream updates.

### Update Development Tools with mise

```bash
mise upgrade           # Upgrade mise itself
mise up                # Update all installed tools
mise use --global node@lts    # Update Node.js
mise use --global dotnet@8       # Update .NET
mise use --global rust@latest    # Update Rust
```

## Package Version Strategy

This setup prioritizes **latest versions** over Ubuntu's stable (often outdated) packages:

- **PPAs** for Git, Neovim, Firefox, OBS
- **Flatpak** for Obsidian, Todoist, Teams (always latest)
- **Official repos** for VS Code, Signal, Edge, GitHub CLI
- **Direct downloads** for Discord, Zoom
- **mise** - Universal version manager for Node.js, .NET, Rust, Python, Go, and more
- **Beads** - Agent task tracker installed via official CLI installer

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

The containers are manual-start and use Docker restart policy `no`. Start or
stop them without changing their saved configuration:

```bash
docker start matter-server homeassistant
docker stop homeassistant matter-server
```

Data is stored in:

- `~/homeassistant/` - HA config, automations, database
- `~/matter-server/` - Matter device pairings
- `OPTIONAL_SERVICES.md` - startup policy and recovery commands

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
**Last Updated**: April 2026
