#!/bin/bash
# Debug script to show what boot entries are detected

GRUB_TMP=$(mktemp)
trap "rm -f $GRUB_TMP" EXIT

# Read GRUB config
pkexec sh -c "cat /boot/grub/grub.cfg" > "$GRUB_TMP" 2>&1 || {
    echo "Failed to read GRUB config"
    exit 1
}

echo "=== Found Menu Entries ==="
echo ""

entry_count=0
grep "menuentry " "$GRUB_TMP" | grep -v "submenu" | while IFS= read -r line; do
    # Extract the display name
    display_name=$(echo "$line" | sed -n "s/.*menuentry '\([^']*\)'.*/\1/p")

    # Extract menuentry_id if it exists
    if echo "$line" | grep -q "menuentry_id_option"; then
        menu_id=$(echo "$line" | sed -n "s/.*menuentry_id_option '\([^']*\)'.*/\1/p")
    else
        menu_id=$((entry_count++))
    fi

    echo "Display: $display_name"
    echo "ID: $menu_id"
    echo "---"
done

echo ""
echo "=== Current Default ==="
if [ -f /boot/grub/grubenv ]; then
    pkexec grep "saved_entry" /boot/grub/grubenv || echo "No saved_entry found"
fi
