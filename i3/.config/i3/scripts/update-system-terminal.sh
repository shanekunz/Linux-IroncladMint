#!/bin/bash

"$HOME/projects/dotfiles/scripts/update-system.sh"
status=$?
printf '\nUpdate finished (exit code %s). Press Enter to close...' "$status"
read -r
exit "$status"
