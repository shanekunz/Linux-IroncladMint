# i3 Keybinds Reference

**Mod = Windows key**

## Apps

**Essentials:**
- `Mod+Return` - Terminal (Ghostty)
- `Mod+Shift+Return` - Terminal in project (selector: ~/projects/* or ~/)
- `Mod+space` - App launcher (Rofi)
- `Mod+e` - File manager (Nemo)
- `Mod+b` - Microsoft Edge
- `Mod+Shift+b` - Firefox
- `Mod+Control+t` - Convert headerless webapp to tabbed browser
- `Mod+a` - Audio mixer

**Development:**
- `Mod+n` - Neovim (project selector: ~/projects/* or ~/)
- `Mod+Shift+n` - OpenCode (project selector: ~/projects/* or ~/)
- `Mod+Alt+g` - LazyGit (project selector: ~/projects/* or ~/)
- `Mod+v` - VS Code
- `Mod+Shift+v` - Clipboard history (CopyQ)
- `Mod+d` - Discord

**AI / Productivity:**
- `Mod+c` - Claude
- `Mod+o` - Obsidian
- `Mod+i` - Voice input (OpenWhispr)
- `Mod+Shift+i` - Kill OpenWhispr
- `Mod+Control+i` - iCloud Drive
- `Mod+Shift+s` - Sunsama
- `Mod+Shift+o` - Outlook
- `Mod+Shift+g` - Gmail

**Work Tools:**
- `Mod+Control+j` - Jira
- `Mod+Control+l` - Linear
- `Mod+Shift+c` - Confluence

**Communication:**
- `Mod+Control+s` - Signal
- `Mod+Control+Alt+s` - LocalSend
- `Mod+Shift+w` - Whatsie (WhatsApp)
- `Mod+Shift+t` - Teams

**Media / Games:**
- `Mod+Shift+a` - Apple Music
- `Mod+Control+g` - Steam

## Window Controls

- `Mod+q` / `Mod+w` - Close window
- `Mod+Escape` - Focus parent container (select groups of windows)
- `Mod+p` - Pin window (follows across workspaces)
- `Mod+x` - Show scratchpad (hidden windows)
- `Mod+Alt+x` - Hide window to scratchpad
- `Mod+Shift+p` - Toggle sticky
- `Mod+Shift+f` - Toggle floating
- `Mod+Control+f` - Toggle focus between tiling/floating
- `Mod+r` - Resize mode
- `Mod+f` - Fullscreen

## Navigation (vim-style)

- `Mod+h/j/k/l` - Focus left/down/up/right
- `Mod+Shift+h/j/k/l` - Move window
- `Mod+Tab` - Window switcher

## Layouts

- `Mod+minus` - Split top/bottom
- `Mod+backslash` - Split left/right
- `Mod+s` - Stacking layout
- `Mod+t` - Tabbed layout
- `Mod+g` - Toggle split layout

## Workspaces

- `Mod+1-0` - Switch to workspace
- `Mod+Control+Left/Right` - Switch to previous/next workspace
- `Mod+Alt+h/l` - Switch to previous/next workspace (vim-style)
- `Mod+Shift+1-0` - Move window to workspace
- `Mod+Control+1-0` - Move window to workspace and follow
- `Mod+Alt+Ctrl+h/l` - Move window to previous/next workspace and follow

## Media & Hardware

- `Mod+grave` (`) - Screenshot tool (Flameshot)
- `Mod+Shift+grave` (`) - Screen recorder (VokoscreenNG)
- `Mod+Delete` - Play/pause media
- `Mod+PgUp/PgDn` - Volume up/down
- `Mod+Shift+PgUp/PgDn` - Monitor brightness (both displays)
- `Mod+Shift+Delete` - Nightlight on (3500K)
- `Mod+Control+Delete` - Nightlight off
- `Mod+Shift+x` - Lock screen
- `Mod+Control+Shift+m` - Toggle Mac microphone (stream Mac mic over network)

## Monitor Modes

- `Mod+m` - Main monitor only (4K OLED @ 165Hz, 150% DPI)
- `Mod+Shift+m` - Both monitors (4K @ 165Hz/144Hz, 150% DPI)
- `Mod+Control+m` - Streaming mode (1680x1050 LED @ 60Hz, no scaling, 16:10 ratio)

## Keyboard Layout

- `Mod+Control+k` - Show keyboard layout image (floating)
- `Mod+Control+e` - Switch to Engrammer (XKB fallback)
- `Mod+Alt+e` - Switch to QWERTY + thumb keys (for typefu Enthium practice)
- `Mod+Control+Shift+e` - Switch to Enthium (Kanata, with symbol layers)
- `Ctrl+Space+Escape` - Emergency exit Kanata (physical keys, always works)

## System

- `Mod+Shift+r` - Restart i3 (also reloads config)
- `Mod+Shift+e` - Exit i3 (logout)
- `Mod+Shift+q` - Shutdown computer
- `Mod+Shift+Control+Alt+s` - Sleep/suspend
- `Mod+Control+r` - Boot menu (select OS to reboot into: one-time or set as default)
- `Mod+Control+b` - Backup system state (OpenClaw, HA, secrets → encrypted archive)
- `Mod+Shift+/` - Show this help file

## Resize Mode (Mod+r to enter)

- `h/j/k/l` or arrow keys - Resize window
- `Escape` or `Enter` - Exit resize mode

## Ghostty Terminal

- `Shift+Enter` - Literal newline (useful in REPLs)
- `Ctrl+Shift+n/p` - Scroll down/up 5 lines
- `Alt+Shift+n/p` - Scroll down/up half page

## Notes

- Mouse auto-centers on focused window
- Custom keyboard layout: Engrammer variant
- Mouse buttons swapped: left/right buttons are swapped
- Streaming mode uses LED monitor to protect OLED from burn-in
- **Voice input**: OpenWhispr uses its own global hotkey (default: backtick, configurable in app) to start/stop dictation. `Mod+i` just opens the settings panel.
