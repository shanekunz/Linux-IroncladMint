#!/bin/sh
# Root-only helper for passwordless GRUB boot actions.

set -eu

list_entries() {
    grep "menuentry " /boot/grub/grub.cfg | grep -v "submenu" |
        sed -n "s/.*menuentry '\([^']*\)'.*menuentry_id_option '\([^']*\)'.*/\1|\2/p"
}

find_entry_id() {
    target_pattern="$1"
    list_entries | grep -i -m1 "$target_pattern" | cut -d'|' -f2
}

reboot_now() {
    if [ "${DOTFILES_BOOT_NO_REBOOT:-0}" = "1" ]; then
        exit 0
    fi

    reboot
}

command_name="${1:-}"

case "$command_name" in
    list)
        list_entries
        ;;
    once)
        menu_id="${2:-}"
        [ -n "$menu_id" ] || exit 1
        grub-reboot "$menu_id"
        reboot_now
        ;;
    default)
        menu_id="${2:-}"
        [ -n "$menu_id" ] || exit 1
        grub-set-default "$menu_id"
        update-grub
        reboot_now
        ;;
    windows-once)
        menu_id="$(find_entry_id windows)"
        [ -n "$menu_id" ] || exit 1
        grub-reboot "$menu_id"
        reboot_now
        ;;
    *)
        echo "Usage: $0 {list|once <menu_id>|default <menu_id>|windows-once}" >&2
        exit 1
        ;;
esac
