#!/bin/bash
# Claude Code Status Line Script
# Reads JSON from stdin, outputs formatted status line

# Read JSON from stdin
json=$(cat)

# --- ANSI COLORS ---
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Foreground colors
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
MAGENTA="\033[35m"
WHITE="\033[37m"

# Powerline separator (fallback to | if not supported)
SEP=" │ "

# --- HELPER FUNCTIONS ---

# Format number with K suffix
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000 ]; then
        printf "%.0fK" "$(echo "$num / 1000" | bc -l)"
    else
        printf "%d" "$num"
    fi
}

# Generate progress bar with gradient
progress_bar() {
    local percent=$1
    local width=10
    local full_blocks=$((percent / 10))
    local remainder=$((percent % 10))
    local empty=$((width - full_blocks - 1))

    # Partial block characters based on remainder (0-9)
    local partial=""
    case $remainder in
        0) partial=" "; empty=$((width - full_blocks)) ;;
        1|2) partial="▎" ;;
        3|4) partial="▌" ;;
        5|6) partial="▋" ;;
        7|8) partial="▊" ;;
        9) partial="▉" ;;
    esac

    local bar=""
    for ((i=0; i<full_blocks; i++)); do bar+="█"; done
    [ "$remainder" -gt 0 ] && bar+="$partial"
    for ((i=0; i<empty; i++)); do bar+=" "; done

    echo "$bar"
}

# Get color based on percentage
get_percent_color() {
    local percent=$1
    if [ "$percent" -lt 50 ]; then
        echo "$GREEN"
    elif [ "$percent" -lt 80 ]; then
        echo "$YELLOW"
    else
        echo "$RED"
    fi
}

# --- PARSE JSON ---

current_dir=$(echo "$json" | jq -r '.workspace.current_dir // empty')
transcript_path=$(echo "$json" | jq -r '.transcript_path // empty')
model=$(echo "$json" | jq -r '.model.display_name // empty')
output_style=$(echo "$json" | jq -r '.output_style.name // empty')
cost=$(echo "$json" | jq -r '.cost.total_cost_usd // 0')
lines_added=$(echo "$json" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$json" | jq -r '.cost.total_lines_removed // 0')
bg_shells=$(echo "$json" | jq -r '.background_shells // 0')
context_size=$(echo "$json" | jq -r '.context_window.context_window_size // 200000')

# Current usage for accurate context tracking
current_usage=$(echo "$json" | jq -r '.context_window.current_usage // empty')
if [ -n "$current_usage" ] && [ "$current_usage" != "null" ]; then
    input_tokens=$(echo "$current_usage" | jq -r '.input_tokens // 0')
    cache_read=$(echo "$current_usage" | jq -r '.cache_read_input_tokens // 0')
    cache_create=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0')
    current_tokens=$((input_tokens + cache_read + cache_create))
else
    # Fallback to cumulative totals
    input_tokens=$(echo "$json" | jq -r '.context_window.total_input_tokens // 0')
    output_tokens=$(echo "$json" | jq -r '.context_window.total_output_tokens // 0')
    current_tokens=$((input_tokens + output_tokens))
    cache_read=0
    cache_create=0
fi

# --- BUILD OUTPUT ---

output=""

# === GIT RELATED ===

# Git info (branch + status counts)
if [ -n "$current_dir" ] && [ -d "$current_dir" ]; then
    cd "$current_dir" 2>/dev/null
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git branch --show-current 2>/dev/null)
        if [ -n "$branch" ]; then
            staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
            modified=$(git diff --numstat 2>/dev/null | wc -l)
            untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

            git_status="$branch"
            counts=""
            [ "$staged" -gt 0 ] && counts="$staged staged"
            [ "$modified" -gt 0 ] && counts="${counts:+$counts, }$modified modified"
            [ "$untracked" -gt 0 ] && counts="${counts:+$counts, }$untracked untracked"
            [ -n "$counts" ] && git_status="$git_status ($counts)"

            output="${GREEN}${git_status}${RESET}"
        fi
    fi
fi

# Lines changed (session total)
if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
    output="${output:+$output$SEP}${GREEN}+$lines_added${RESET}/${RED}-$lines_removed${RESET}"
fi

# === CONTEXT PROGRESS BAR ===

if [ "$current_tokens" -gt 0 ]; then
    percent=$((current_tokens * 100 / context_size))
    [ "$percent" -gt 100 ] && percent=100

    tokens_fmt=$(format_tokens "$current_tokens")
    bar=$(progress_bar "$percent")
    color=$(get_percent_color "$percent")

    output="${output:+$output$SEP}${tokens_fmt} ${color}[${bar}]${RESET} ${percent}%"
fi


# === EVERYTHING ELSE ===

# Session duration (from transcript file birth time)
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    created=$(stat -c %W "$transcript_path" 2>/dev/null)
    if [ -n "$created" ] && [ "$created" != "0" ]; then
        now=$(date +%s)
        elapsed=$((now - created))
        hours=$((elapsed / 3600))
        mins=$(((elapsed % 3600) / 60))
        duration=$(printf "%d:%02d" "$hours" "$mins")
        output="${output:+$output$SEP}${duration}"
    fi
fi

# Model name (skip if "default")
if [ -n "$model" ] && [ "$model" != "default" ]; then
    short_model=$(echo "$model" | sed 's/Claude //')
    output="${output:+$output$SEP}${MAGENTA}${short_model}${RESET}"
fi

# Output style (skip normal/default)
if [ -n "$output_style" ] && [ "$output_style" != "normal" ] && [ "$output_style" != "default" ]; then
    output="${output:+$output$SEP}${DIM}[$output_style]${RESET}"
fi


# Background shells
if [ "$bg_shells" != "0" ] && [ "$bg_shells" -gt 0 ]; then
    output="${output:+$output$SEP}${YELLOW}$bg_shells bg${RESET}"
fi

echo -e "$output"
