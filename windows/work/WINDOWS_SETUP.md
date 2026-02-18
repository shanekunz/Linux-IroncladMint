# Windows Setup (GlazeWM + Kanata)

Use this repo to keep Windows keybind behavior conceptually aligned with Linux i3/Enthium.

## Files

- `windows/work/glazewm/config.yaml`
- `windows/work/windows-kanata/kanata.kbd`

## Install (PowerShell as Admin)

```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.glzr\glazewm\config.yaml" -Target "C:\Users\skunz\projects\Linux-IroncladMint\windows\work\glazewm\config.yaml" -Force
New-Item -ItemType SymbolicLink -Path "C:\Users\skunz\Documents\kanata\kanata.kbd" -Target "C:\Users\skunz\projects\Linux-IroncladMint\windows\work\windows-kanata\kanata.kbd" -Force
```

## Startup Order

Startup order matters.

You need to experiment with whether Kanata or GlazeWM starts first on your machine. The goal is to get behavior where you can think in conceptual keys (for example `mod+b` means browser) without manually translating Enthium letters to physical key locations in GlazeWM.

## Quick Test

1. Start both apps using one startup order.
2. Test a few anchors:
   - `alt+b` browser
   - `alt+return` terminal
   - `alt+c` Claude
   - `alt+shift+s` Sunsama
   - `alt+shift+/` keybind help
   - `alt+h/j/k/l` window nav
3. If mappings feel like physical-key translation, reverse startup order and retest.

## Kanata Auto Start

Use Windows Task Scheduler so Kanata starts at login with highest privileges.

1. Open Task Scheduler -> Create Task.
2. General:
   - Name: `Kanata`
   - Check `Run with highest privileges`
   - Configure for `Windows 10/11`
3. Triggers:
   - `At log on` (your user)
4. Actions:
   - Program/script: path to your Kanata exe
   - Start in: `C:\Users\skunz\Documents\kanata`
5. Conditions/Settings:
   - Disable power/network-only restrictions if you want it always-on.
6. Save, then right-click task -> Run to test.

## Notes

- Windows Kanata config swaps home-row mod behavior to keep muscle memory close to Linux usage.
- `alt+space` is intentionally left for Flow Launcher (or your spotlight-style launcher), not bound in GlazeWM.
- `alt+ctrl+t` toggles taskbar auto-hide and restarts Explorer.
- Keep this doc short on purpose; detailed key list is in `KEYBINDINGS.md`.
