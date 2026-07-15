#!/bin/bash
# Interactive boot menu - select which OS to boot into next.
# Also supports direct boot shortcuts, e.g. --once windows --yes.

set -e

if ! command -v rofi &> /dev/null; then
    notify-send "Error" "rofi is not installed"
    exit 1
fi

if ! command -v sudo &> /dev/null; then
    notify-send "Error" "sudo is required"
    exit 1
fi

MENU_FILE=$(mktemp)
MAP_FILE=$(mktemp)
GRUB_TMP=$(mktemp)
trap 'rm -f "$MENU_FILE" "$MAP_FILE" "$GRUB_TMP"' EXIT

BOOT_MODE=""
TARGET_PATTERN=""
SKIP_CONFIRM=0

HELPER="/usr/local/lib/dotfiles/boot-target.sh"

usage() {
    cat <<'EOF'
Usage:
  boot-menu.sh
  boot-menu.sh --once <name-pattern> [--yes]
  boot-menu.sh --default <name-pattern> [--yes]

Examples:
  boot-menu.sh --once windows --yes
  boot-menu.sh --default ubuntu
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --once)
            BOOT_MODE="One-time boot"
            TARGET_PATTERN="$2"
            shift 2
            ;;
        --default)
            BOOT_MODE="Set as default"
            TARGET_PATTERN="$2"
            shift 2
            ;;
        --yes)
            SKIP_CONFIRM=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage
            notify-send "Error" "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [ -n "$BOOT_MODE" ] && [ -z "$TARGET_PATTERN" ]; then
    usage
    notify-send "Error" "Missing boot target pattern"
    exit 1
fi

if ! sudo -n /bin/sh "$HELPER" list > "$MAP_FILE" 2>/dev/null; then
    notify-send "Error" "Passwordless boot helper is not installed or failed"
    exit 1
fi

cut -d'|' -f1 "$MAP_FILE" > "$MENU_FILE"

if [ -n "$TARGET_PATTERN" ]; then
    SELECTED=$(grep -i -m1 "$TARGET_PATTERN" "$MENU_FILE" || true)
    if [ -z "$SELECTED" ]; then
        notify-send "Error" "No boot entry matched: $TARGET_PATTERN"
        exit 1
    fi
else
    SELECTED=$(rofi -dmenu -i -p "Boot to:" -theme-str 'window {width: 600px;}' < "$MENU_FILE")
    if [ -z "$SELECTED" ]; then
        echo "No selection made, cancelling..."
        exit 0
    fi
fi

MENU_ID=$(grep -F -m1 "$SELECTED|" "$MAP_FILE" | cut -d'|' -f2)

if [ -z "$MENU_ID" ]; then
    notify-send "Error" "Could not find menu entry ID for: $SELECTED"
    exit 1
fi

if [ -z "$BOOT_MODE" ]; then
    BOOT_MODE=$(printf 'One-time boot\nSet as default\n' | rofi -dmenu -p "Boot mode:")
    if [ -z "$BOOT_MODE" ]; then
        echo "No boot mode selected, cancelling..."
        exit 0
    fi
fi

if [ "$SKIP_CONFIRM" -ne 1 ]; then
    if [ "$BOOT_MODE" = "One-time boot" ]; then
        CONFIRM=$(printf 'Yes\nNo\n' | rofi -dmenu -p "Reboot once to: $SELECTED?")
    else
        CONFIRM=$(printf 'Yes\nNo\n' | rofi -dmenu -p "Set default boot to: $SELECTED and reboot?")
    fi

    if [ "$CONFIRM" != "Yes" ]; then
        echo "Cancelled"
        exit 0
    fi
fi

if [ "$BOOT_MODE" = "One-time boot" ]; then
    notify-send "Boot Menu" "Rebooting once to: $SELECTED"
else
    notify-send "Boot Menu" "Setting default boot to: $SELECTED and rebooting"
fi

sleep 1

if [ "$BOOT_MODE" = "One-time boot" ]; then
    if ! sudo -n /bin/sh "$HELPER" once "$MENU_ID"; then
        notify-send "Error" "Failed to set one-time boot target or reboot"
        exit 1
    fi
else
    if ! sudo -n /bin/sh "$HELPER" default "$MENU_ID"; then
        notify-send "Error" "Failed to set default boot target or reboot"
        exit 1
    fi
fi
