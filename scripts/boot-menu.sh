#!/bin/bash
# Interactive boot menu - select which OS to boot into next
# Uses rofi to display available boot entries from GRUB

set -e

# Check if rofi is available
if ! command -v rofi &> /dev/null; then
    notify-send "Error" "rofi is not installed"
    exit 1
fi

# Check if pkexec is available
if ! command -v pkexec &> /dev/null; then
    notify-send "Error" "pkexec is not installed"
    exit 1
fi

# Temporary files for menu entries
MENU_FILE=$(mktemp)
MAP_FILE=$(mktemp)
GRUB_TMP=$(mktemp)
trap "rm -f $MENU_FILE $MAP_FILE $GRUB_TMP" EXIT

# Read GRUB config with pkexec
pkexec sh -c "cat /boot/grub/grub.cfg" > "$GRUB_TMP" 2>&1 || {
    notify-send "Error" "Failed to read GRUB config. Check password entry."
    exit 1
}

# Extract menu entries using grep and sed
# Match lines with menuentry (may have leading whitespace)
grep "menuentry " "$GRUB_TMP" | grep -v "submenu" | while IFS= read -r line; do
    # Extract the display name (text between first pair of single quotes)
    display_name=$(echo "$line" | sed -n "s/.*menuentry '\([^']*\)'.*/\1/p")

    # Extract menuentry_id if it exists
    if echo "$line" | grep -q "menuentry_id_option"; then
        menu_id=$(echo "$line" | sed -n "s/.*menuentry_id_option '\([^']*\)'.*/\1/p")
    else
        # Use numeric index as fallback
        menu_id=$((entry_count++))
    fi

    echo "$display_name|$menu_id"
done > "$MAP_FILE"

# Create display list for rofi (just the names)
cut -d'|' -f1 "$MAP_FILE" > "$MENU_FILE"

# Show rofi menu
SELECTED=$(rofi -dmenu -i -p "Boot to:" -theme-str 'window {width: 600px;}' < "$MENU_FILE")

if [ -z "$SELECTED" ]; then
    echo "No selection made, cancelling..."
    exit 0
fi

# Find the corresponding menuentry_id
MENU_ID=$(grep -F "$SELECTED" "$MAP_FILE" | cut -d'|' -f2)

if [ -z "$MENU_ID" ]; then
    echo "Error: Could not find menu entry ID"
    exit 1
fi

# Ask user for boot mode
BOOT_MODE=$(echo -e "One-time boot\nSet as default" | rofi -dmenu -p "Boot mode:")

if [ -z "$BOOT_MODE" ]; then
    echo "No boot mode selected, cancelling..."
    exit 0
fi

# Confirm with user
if [ "$BOOT_MODE" = "One-time boot" ]; then
    CONFIRM=$(echo -e "Yes\nNo" | rofi -dmenu -p "Reboot once to: $SELECTED?")
else
    CONFIRM=$(echo -e "Yes\nNo" | rofi -dmenu -p "Set default boot to: $SELECTED and reboot?")
fi

if [ "$CONFIRM" != "Yes" ]; then
    echo "Cancelled"
    exit 0
fi

# Set boot entry based on mode
if [ "$BOOT_MODE" = "One-time boot" ]; then
    # One-time boot (reverts to default after)
    if ! pkexec grub-reboot "$MENU_ID"; then
        notify-send "Error" "Failed to set boot entry. Menu ID: $MENU_ID"
        exit 1
    fi
    notify-send "Boot Menu" "Set one-time boot to: $SELECTED (ID: $MENU_ID)"
else
    # Set as permanent default
    if ! pkexec grub-set-default "$MENU_ID"; then
        notify-send "Error" "Failed to set default boot entry. Menu ID: $MENU_ID"
        exit 1
    fi
    # Update GRUB config to persist the change
    if ! pkexec update-grub; then
        notify-send "Error" "Failed to update GRUB config"
        exit 1
    fi
    notify-send "Boot Menu" "Set default boot to: $SELECTED (ID: $MENU_ID)"
fi

# Small delay to show notification
sleep 1

# Reboot
pkexec reboot
