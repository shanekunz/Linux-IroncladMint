#!/bin/bash
# Reboot once into Windows using the passwordless root helper.

set -e

HELPER="/usr/local/lib/dotfiles/boot-target.sh"

if ! command -v sudo &> /dev/null; then
    notify-send "Windows Boot" "sudo is required for the F11 shortcut"
    exit 1
fi

if [ ! -f "$HELPER" ]; then
    notify-send "Windows Boot" "Install the boot-hotkey helper first"
    exit 1
fi

notify-send "Windows Boot" "Rebooting once into Windows"
sleep 1

if ! sudo -n /bin/sh "$HELPER" windows-once; then
    notify-send "Windows Boot" "Passwordless boot helper is not installed or failed"
    exit 1
fi
