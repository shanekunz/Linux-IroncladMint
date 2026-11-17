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
- `Mod+Control+u` - Cycle Starship prompt theme (3 presets)
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
- `Mod+Alt+t` - Telegram Web
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
- `Mod+Shift+d` - Turn displays off without locking or suspending (any key or mouse movement wakes them)
- `Mod+Control+Shift+m` - Toggle Mac microphone (stream Mac mic over network)

## Monitor Modes

- `Mod+m` - Single real monitor, 150% DPI: 4K OLED @ 165Hz on DP-0, MSI G321CU @ 4K 120Hz (144Hz gives no picture), or the preferred resolution and refresh rate of whatever real monitor is connected (never the HDMI-0 dummy). Turns off the dummy, so Moonlight then streams that monitor
- `Mod+Shift+m` - Both monitors with second monitor orientation picker (4K @ 165Hz/144Hz, 150% DPI)
- `Mod+Control+m` - Streaming mode resolution picker followed by orientation picker: 4 DP-4 resolutions (HDMI dummy plug fallback when disconnected) plus `2560x1600` on the HDMI dummy plug

## Keyboard Layout

- `Mod+Control+k` - Show keyboard layout image (floating)
- `Mod+Control+q` - Toggle Enthium ↔ QWERTY + thumb keys (Q for QWERTY; triggers on release)
- `Ctrl+Space+Escape` - Emergency exit Kanata (physical keys, always works)

Use the **physical left Windows and Ctrl keys** for the toggle, rather than
Enthium's home-row modifiers. Q has the same physical position in both layouts.
Enthium is the startup default; QWERTY preserves the practice remaps:
Caps Lock → `b`, right thumb/Scroll Lock → `r`.

**Same physical keys in both base layouts:**
- Letters: **Q and M** only. M already has monitor-mode shortcuts.
- Number row: `1–0`, minus, equals, and grave (including their shifted symbols).
- Brackets and backslash; Escape, Tab, Enter, Backspace; left Win, Ctrl, Alt,
  and both Shift keys. Function and arrow keys are also unchanged.
- Left space still taps Space in Enthium, but holding it activates navigation.

Recovery/explicit selection: run
`~/.config/i3/scripts/toggle-keyboard-layout.sh enthium` or the same command with
`qwerty`. Engrammer and the old E-based layout shortcuts have been retired.

## System

- `Mod+Shift+r` - Restart i3 (also reloads config)
- `Mod+Shift+e` - Exit i3 (logout)
- `Mod+Shift+q` - Shutdown computer
- `Mod+Shift+Control+Alt+s` - Sleep/suspend
- `Mod+Control+r` - Boot menu (select OS to reboot into: one-time or set as default)
- `F11` - Reboot once into Windows immediately
- `Mod+Control+b` - Backup system state (OpenClaw, HA, secrets → encrypted archive)
- `Mod+u` - Update entire system (Yes/Cancel prompt, then terminal with output)
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
- Custom keyboard layout: Enthium (Kanata), with a QWERTY toggle
- Mouse buttons swapped: left/right buttons are swapped
- Streaming mode uses the LED monitor (or HDMI dummy plug when disconnected) to protect OLED from burn-in; enables the target before disabling other displays
- **Voice input**: Configure Handy's launch-at-login behavior and global dictation hotkey in its settings.
