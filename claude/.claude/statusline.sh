#!/bin/bash
# Claude Code Status Line Script
# Reads JSON from stdin, outputs formatted status line

# Read JSON from stdin
json=$(cat)

# Parse JSON fields using jq
current_dir=$(echo "$json" | jq -r '.workspace.current_dir // empty')
transcript_path=$(echo "$json" | jq -r '.transcript_path // empty')
model=$(echo "$json" | jq -r '.model.display_name // empty')
output_style=$(echo "$json" | jq -r '.output_style.name // empty')
cost=$(echo "$json" | jq -r '.cost.total_cost_usd // 0')
duration_ms=$(echo "$json" | jq -r '.cost.total_duration_ms // 0')
lines_added=$(echo "$json" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$json" | jq -r '.cost.total_lines_removed // 0')
bg_shells=$(echo "$json" | jq -r '.background_shells // 0')
exceeds_200k=$(echo "$json" | jq -r '.exceeds_200k_tokens // false')

# Build status line components
output=""

# Git info (branch + status counts)
if [ -n "$current_dir" ] && [ -d "$current_dir" ]; then
    cd "$current_dir" 2>/dev/null
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git branch --show-current 2>/dev/null)
        if [ -n "$branch" ]; then
            # Count staged, modified, untracked
            staged=$(git diff --cached --numstat 2>/dev/null | wc -l)
            modified=$(git diff --numstat 2>/dev/null | wc -l)
            untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

            git_status="$branch"
            counts=""
            [ "$staged" -gt 0 ] && counts="$staged staged"
            [ "$modified" -gt 0 ] && counts="${counts:+$counts, }$modified modified"
            [ "$untracked" -gt 0 ] && counts="${counts:+$counts, }$untracked untracked"
            [ -n "$counts" ] && git_status="$git_status ($counts)"

            output="$git_status"
        fi
    fi
fi

# Session duration (from transcript file creation time)
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    created=$(stat -c %Y "$transcript_path" 2>/dev/null)
    if [ -n "$created" ]; then
        now=$(date +%s)
        elapsed=$((now - created))
        hours=$((elapsed / 3600))
        mins=$(((elapsed % 3600) / 60))
        duration=$(printf "%02d:%02d" "$hours" "$mins")
        output="${output:+$output | }$duration"
    fi
fi

# Model name (shortened)
if [ -n "$model" ]; then
    # Shorten common model names
    short_model=$(echo "$model" | sed 's/Claude //' | sed 's/Opus /Opus /' | sed 's/Sonnet /Sonnet /')
    output="${output:+$output | }$short_model"
fi

# Output style (if not default)
if [ -n "$output_style" ] && [ "$output_style" != "normal" ]; then
    output="${output:+$output | }[$output_style]"
fi

# Cost metrics
if [ "$cost" != "0" ] || [ "$duration_ms" != "0" ] || [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
    metrics=""

    # Format cost
    if [ "$cost" != "0" ]; then
        cost_fmt=$(printf "\$%.2f" "$cost")
        metrics="$cost_fmt"
    fi

    # API duration in minutes
    if [ "$duration_ms" != "0" ]; then
        api_mins=$((duration_ms / 60000))
        if [ "$api_mins" -gt 0 ]; then
            metrics="${metrics:+$metrics, }${api_mins}min"
        fi
    fi

    # Lines changed
    if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
        metrics="${metrics:+$metrics, }+$lines_added/-$lines_removed"
    fi

    [ -n "$metrics" ] && output="${output:+$output | }$metrics"
fi

# Background shells
if [ "$bg_shells" != "0" ] && [ "$bg_shells" -gt 0 ]; then
    output="${output:+$output | }$bg_shells bg"
fi

# Context warning
if [ "$exceeds_200k" = "true" ]; then
    output="${output:+$output | }⚠️ >200k"
fi

echo "$output"
