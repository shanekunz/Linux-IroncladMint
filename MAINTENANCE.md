# Maintenance Backlog

## Installer Update Policy

`scripts/update-system.sh` updates APT, Flatpak, Snap, and mise-managed software, then reruns the install scripts.

- Beads, Claude Code, OpenCode, fzf, Kanata, LazyGit, Starship, and Sunshine update through their installer scripts.
- Glow uses Charm's official APT repository and updates through APT.
- Ollama already resolves and installs the latest GitHub release on every installer run.
- T3 Code and Handy use their built-in application updaters.
- Zoom, Sunsama, Nerd Fonts, and OBSBOT are deliberately not update-managed.
- Gamescope is no longer installed by this repository.
