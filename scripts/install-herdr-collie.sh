#!/usr/bin/env bash
# Minimal Herdr + Collie runtime and authenticated Cloudflare sharing tools.
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
command -v mise >/dev/null || { echo 'Install mise first: ./scripts/install-mise.sh' >&2; exit 1; }
mise use --global herdr@latest caddy@latest
if ! command -v cloudflared >/dev/null; then
    mise use --global cloudflared@latest
fi
mise reshim

if command -v collie >/dev/null; then
    echo 'Collie is already installed.'
else
    installer=$(mktemp)
    trap 'rm -f "$installer"' EXIT
    curl -fsSL https://colliepwa.dev/install.sh -o "$installer"
    # Upstream verifies both the release checksum and integrity manifest.
    bash "$installer"
fi

echo 'Ready. Sharing is opt-in: python3 scripts/low-lantern-share.py start'
