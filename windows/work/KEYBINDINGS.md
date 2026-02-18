# GlazeWM Keybindings (Windows)

All keybinds from `windows/work/glazewm/config.yaml`.

## Navigation

| Keys | Action |
|---|---|
| `alt+h`, `alt+left` | focus left |
| `alt+l`, `alt+right` | focus right |
| `alt+k`, `alt+up` | focus up |
| `alt+j`, `alt+down` | focus down |

## Move Window

| Keys | Action |
|---|---|
| `alt+shift+h`, `alt+shift+left` | move left |
| `alt+shift+l`, `alt+shift+right` | move right |
| `alt+shift+k`, `alt+shift+up` | move up |
| `alt+shift+j`, `alt+shift+down` | move down |

## Workspaces

| Keys | Action |
|---|---|
| `alt+1..9`, `alt+0` | focus workspace 1..10 |
| `alt+ctrl+1..9`, `alt+ctrl+0` | move to workspace and follow |
| `alt+shift+1..9`, `alt+shift+0` | move to workspace (stay) |

## Workspace Navigation

| Keys | Action |
|---|---|
| `alt+ctrl+right`, `alt+ctrl+l` | next active workspace |
| `alt+ctrl+left`, `alt+ctrl+h` | previous active workspace |
| `alt+ctrl+d`, `alt+tab` | recent workspace |
| `alt+ctrl+shift+h` | move workspace left |
| `alt+ctrl+shift+l` | move workspace right |

## Layout and Window State

| Keys | Action |
|---|---|
| `alt+backslash`, `alt+t`, `alt+g` | toggle tiling direction |
| `alt+ctrl+space` | toggle tiling |
| `alt+shift+f` | toggle floating |
| `alt+f` | toggle fullscreen |
| `alt+m` | toggle minimized |
| `alt+q`, `alt+w` | close |

## System

| Keys | Action |
|---|---|
| `alt+r` | enter resize mode |
| `alt+shift+r` | reload config |
| `alt+ctrl+f` | cycle focus |
| `alt+shift+'` | redraw WM |
| `alt+ctrl+o` | toggle pause |
| `alt+delete` | media play/pause |
| `alt+shift+delete` | media next |
| `alt+ctrl+delete` | media previous |
| `alt+ctrl+t` | toggle taskbar auto-hide (restarts Explorer) |
| `alt+shift+e` | exit WM |
| `alt+shift+x` | lock workstation |

## App Launchers

| Keys | Action |
|---|---|
| `alt+return`, `alt+enter`, `alt+shift+return` | Alacritty |
| `alt+b` | Microsoft Edge |
| `alt+shift+b` | Firefox |
| `alt+e` | Explorer |
| `alt+v` | VS Code |
| `alt+c` | Claude (web) |
| `alt+shift+s` | Sunsama |
| `alt+a` | Volume Mixer |
| `alt+grave`, `alt+shift+period` | Snipping Tool capture |
| `alt+shift+slash` | open keybind reference in Notepad |
| `alt+ctrl+slash` | open GlazeWM config in Notepad |
| `alt+shift+v` | clipboard reminder (`Win+V`) |
| `alt+shift+o` | Outlook |
| `alt+shift+t` | Teams |

## Resize Mode

| Keys | Action |
|---|---|
| `h`, `left` | resize width -2% |
| `l`, `right` | resize width +2% |
| `j`, `down` | resize height +2% |
| `k`, `up` | resize height -2% |
| `escape`, `enter` | exit resize mode |

## Note

Startup order between Kanata and GlazeWM matters. Tune startup order so conceptual shortcuts stay consistent (for example, `mod+b` always means browser) without manual Enthium-to-physical translation.

`alt+space` is intentionally unbound in GlazeWM for Flow Launcher (or equivalent spotlight launcher).
