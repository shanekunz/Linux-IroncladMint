#!/bin/bash
# Streaming mode with selectable resolution and orientation
# Prefer DP-4 for most modes, falling back to the HDMI-0 dummy plug when disconnected.
# The MacBook-native 16:10 mode always uses HDMI-0.

# Define resolution options
OPTIONS="Current (1680x1050)\n1080p (1920x1080)\n1440p (2560x1440)\n4K (3840x2160)\nMacBook 13.3 Native (2560x1600)"

# Show rofi menu
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Select Streaming Resolution" -theme-str 'window {width: 400px;}')

# Exit if no selection
if [ -z "$CHOICE" ]; then
    exit 0
fi

# Parse selection and set resolution
case "$CHOICE" in
    "Current (1680x1050)")
        MODE="1680x1050"
        RATE="59.95"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "1080p (1920x1080)")
        MODE="1920x1080"
        RATE="60.00"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "1440p (2560x1440)")
        MODE="2560x1440"
        RATE="144.00"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "4K (3840x2160)")
        MODE="3840x2160"
        RATE="144.00"
        TARGET_OUTPUT="DP-4"
        SCALE="1.0"
        ;;
    "MacBook 13.3 Native (2560x1600)")
        MODE="2560x1600"
        RATE="59.97"
        TARGET_OUTPUT="HDMI-0"
        SCALE="1.25"
        ;;
    *)
        exit 1
        ;;
esac

# Validate the target before changing any outputs. Disconnected DisplayPort monitors
# can still advertise cached modes, so check connection status explicitly.
XRANDR_STATE=$(xrandr --query) || exit 1
is_connected() {
    awk -v output="$1" '$1 == output && $2 == "connected" { found = 1 } END { exit !found }' <<< "$XRANDR_STATE"
}
fail() {
    echo "Streaming display: $*" >&2
    notify-send "Streaming display" "$*" 2>/dev/null || true
    exit 1
}

if ! is_connected "$TARGET_OUTPUT"; then
    if [ "$TARGET_OUTPUT" = "DP-4" ] && is_connected HDMI-0; then
        TARGET_OUTPUT="HDMI-0"
    else
        fail "No connected display available for streaming."
    fi
fi

# Use the requested rate when advertised, otherwise the mode's first available
# rate (e.g. the dummy plug supports 4K at 59.94Hz rather than DP-4's 144Hz).
RATE=$(awk -v output="$TARGET_OUTPUT" -v mode="$MODE" -v rate="$RATE" '
    /^[^[:space:]]/ { selected = ($1 == output && $2 == "connected"); next }
    selected && $1 == mode {
        fallback = $2
        gsub(/[*+]/, "", fallback)
        for (i = 2; i <= NF; i++) {
            value = $i
            gsub(/[*+]/, "", value)
            if (value != "" && value + 0 == rate + 0) { print value; exit }
        }
        print fallback; exit
    }
' <<< "$XRANDR_STATE")
[ -n "$RATE" ] || fail "$TARGET_OUTPUT does not support $MODE. Display unchanged."

ROTATION=$(~/.config/i3/scripts/select-monitor-orientation.sh) || exit 0

# Enable the target successfully before turning off other displays. Never pass
# --off for the target itself: that can leave X with an 8x8 desktop.
TARGET_ARGS=(--output "$TARGET_OUTPUT" --mode "$MODE" --rate "$RATE" --rotate "$ROTATION" --pos 0x0 --primary)
xrandr "${TARGET_ARGS[@]}" || fail "Could not enable $TARGET_OUTPUT at $MODE."
OFF_ARGS=()
while read -r output; do
    [ "$output" != "$TARGET_OUTPUT" ] && OFF_ARGS+=(--output "$output" --off)
done < <(awk '/^[^[:space:]]/ && ($2 == "connected" || $2 == "disconnected") { print $1 }' <<< "$XRANDR_STATE")
xrandr "${TARGET_ARGS[@]}" "${OFF_ARGS[@]}" || fail "Could not finish switching displays."
~/.config/i3/scripts/scaling.sh set "$SCALE"
sleep 0.3
xrandr "${TARGET_ARGS[@]}" "${OFF_ARGS[@]}" || fail "Could not reapply streaming display mode."
i3-msg restart
