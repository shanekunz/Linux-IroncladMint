#!/bin/bash
# Toggle Enthium (Kanata) and QWERTY with the existing practice thumb remaps.
# An explicit mode is also accepted for repeatable session startup/recovery.
set -euo pipefail

mode="${1:-toggle}"
case "$mode" in
    toggle|enthium|qwerty) ;;
    *) echo "Usage: $0 [toggle|enthium|qwerty]" >&2; exit 2 ;;
esac

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/keyboard-layout-${UID}.lock"
flock -n 9 || exit 0

if [[ "$mode" == toggle ]]; then
    if pgrep -u "$UID" -x kanata >/dev/null; then
        mode=qwerty
    else
        mode=enthium
    fi
fi

# Wait for Kanata to release its devices before resetting the XKB map.
pkill -u "$UID" -x kanata || true
for ((attempt = 0; attempt < 50; attempt++)); do
    pgrep -u "$UID" -x kanata >/dev/null || break
    sleep 0.05
done
if pgrep -u "$UID" -x kanata >/dev/null; then
    notify-send 'Keyboard' 'Could not stop Kanata; layout unchanged'
    exit 1
fi

setxkbmap -layout us -variant '' -option ''
if [[ "$mode" == qwerty ]]; then
    # Caps Lock -> b; firmware-remapped right space (Scroll Lock) -> r.
    xmodmap -e 'clear Lock' -e 'keycode 66 = b B b B' -e 'keycode 78 = r R r R'
    notify-send 'Keyboard' 'QWERTY + thumb keys'
else
    # Close the lock descriptor in the long-lived child.
    kanata -c "$HOME/.config/kanata/kanata.kbd" 9>&- &
    kanata_pid=$!
    sleep 0.3
    if ! kill -0 "$kanata_pid" 2>/dev/null; then
        notify-send 'Keyboard' 'Kanata failed to start; using US QWERTY'
        exit 1
    fi
    notify-send 'Keyboard' 'Enthium (Kanata)'
fi
