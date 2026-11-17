#!/bin/bash
# Single real monitor at 150% scaling.
# Prefers the OLED on DP-0 at 4K 165Hz. If that mode is not available (a different
# monitor is plugged in), it uses the first connected real output at its preferred
# resolution and refresh rate. HDMI-0 is the dummy plug.
# Pass --no-restart at session startup, where i3 is not running yet.

DUMMY_OUTPUT="HDMI-0"
ALL_OUTPUTS="DP-0 DP-1 DP-2 DP-3 DP-4 DP-5 HDMI-0"

# Print "<output> <mode> <rate>" for the best mode of the first connected real output.
pick_output() {
    xrandr --query | awk -v dummy="$DUMMY_OUTPUT" '
        / connected/ { out = ($1 != dummy) ? $1 : ""; next }
        /disconnected/ { out = ""; next }
        out != "" && /^   [0-9]+x[0-9]+/ {
            # The monitor marks its preferred mode and rate with "+". Use that rate, not the
            # highest: high rates can exceed what the cable or input carries (black screen).
            # xrandr prints the mark attached ("60.00*+") or as its own field ("60.00 +").
            for (i = 2; i <= NF; i++) if ($i ~ /\+/) { r = ($i == "+") ? $(i - 1) : $i; gsub(/[*+]/, "", r); print out, $1, r; done = 1; exit }
            # No preferred mark: keep the first (largest) mode at its first listed rate.
            if (first == "") { r = $2; gsub(/[*+]/, "", r); first = out " " $1 " " r }
        }
        END { if (!done && first != "") print first }
    '
}

# Print the monitor model name stored in an output's EDID (e.g. "MSI G321CU").
edid_name() {
    xrandr --props | sed -n "/^$1 connected/,/^[A-Z]/p" |
        awk '/EDID:/ { f = 1; next } f && /^\t\t[0-9a-f]+$/ { printf "%s", $1; next } f { exit }' |
        grep -o '000000fc00.\{26\}' | head -n 1 | cut -c11- | xxd -r -p | head -n 1 | sed 's/[[:space:]]*$//'
}

if xrandr --query | sed -n '/^DP-0 connected/,/^[A-Z]/p' | grep -q '^   3840x2160 .*164\.99'; then
    OUTPUT="DP-0" MODE="3840x2160" RATE="164.99"
else
    read -r OUTPUT MODE RATE < <(pick_output)
    # Known monitors tested above their preferred rate. Its 144Hz mode shows no picture
    # over the current cable; 120Hz works.
    case "$(edid_name "$OUTPUT")" in
        "MSI G321CU") MODE="3840x2160" RATE="120.00" ;;
    esac
fi

if [ -z "$OUTPUT" ]; then
    notify-send "Monitor" "No connected monitor found besides the $DUMMY_OUTPUT dummy plug" 2>/dev/null
    exit 1
fi

ARGS=()
for o in $ALL_OUTPUTS; do
    [ "$o" != "$OUTPUT" ] && ARGS+=(--output "$o" --off)
done

xrandr --output "$OUTPUT" --mode "$MODE" --rate "$RATE" --rotate normal --pos 0x0 --primary "${ARGS[@]}"
~/.config/i3/scripts/scaling.sh set 1.5

[ "$1" = "--no-restart" ] && exit 0
sleep 0.3
i3-msg restart
