#!/bin/bash
# Rofi-based project selector for launching lazygit
# Shows ~/projects subdirectories with ~/ as default

# Build the menu options
options=()

# Add home directory as first/default option
options+=("~/ (Home)")

# Add all directories from ~/projects if it exists
if [ -d "$HOME/projects" ]; then
    while IFS= read -r dir; do
        # Extract just the directory name for display
        dirname=$(basename "$dir")
        options+=("~/projects/$dirname")
    done < <(find "$HOME/projects" -mindepth 1 -maxdepth 1 -type d | sort)
fi

# Convert array to newline-separated string for rofi
menu=$(printf '%s\n' "${options[@]}")

# Show rofi menu and get selection
# -dmenu: Use dmenu mode (list selection)
# -i: Case insensitive search
# -p: Prompt text
# -format s: Return the selected string
# -select: Pre-select the first option (Home)
selected=$(echo "$menu" | rofi -dmenu -i -p "Open LazyGit in" -format s -select "~/ (Home)")

# Exit if nothing selected (user pressed Escape)
if [ -z "$selected" ]; then
    exit 0
fi

# Extract the actual path from the selection
if [[ "$selected" == "~/ (Home)" ]]; then
    target_dir="$HOME"
else
    # Replace ~/ with actual home path
    target_dir="${selected/#\~/$HOME}"
fi

# Launch ghostty with lazygit in the selected directory
exec ghostty --working-directory="$target_dir" -e lazygit
