#!/bin/bash
#
# MASTER SCALING SYSTEM - Single Source of Truth
# ================================================
# Controls all DPI/scaling for the entire system
#
# USAGE:
#   Execute: ./scaling.sh set <scale>    # Change scaling (e.g., ./scaling.sh set 1.5)
#   Source:  source ./scaling.sh         # Load values into environment
#
# SCALE VALUES:
#   1.0  = 100% scaling (96 DPI)
#   1.25 = 125% scaling (120 DPI)
#   1.5  = 150% scaling (144 DPI) [Default]
#   2.0  = 200% scaling (192 DPI)
#
# WORKFLOWS:
#   System Startup:
#     1. .xprofile sources this script
#     2. i3 starts, runs env-scaling.sh (also sources this)
#     3. All apps get correct scaling
#
#   Monitor Switching:
#     1. User presses Mod+m (or Mod+Shift+m)
#     2. monitor-*.sh runs xrandr + calls this script with "set" command
#     3. This script updates everything and restarts i3bar
#     4. All apps see new scaling
#

# ============================================================================
# CONFIGURATION - Single source of truth for all scaling values
# ============================================================================

# Current scale factor (user-facing value)
# This is the ONLY value that should be manually edited
SCALE=1.0

# All other values are calculated from SCALE:
DPI=$(printf "%.0f" $(echo "$SCALE * 96" | bc))           # 1.5 * 96 = 144
CURSOR_SIZE=$(printf "%.0f" $(echo "$SCALE * 16" | bc))   # 1.5 * 16 = 24

# GTK3/GTK4 scaling strategy:
# For fractional scaling (1.25, 1.5, 1.75), rely on X11 DPI only
# For integer scaling (2.0+), use GDK_SCALE
# This prevents compounding/multiplication issues
if [ "$SCALE" == "2" ] || [ "$SCALE" == "2.0" ] || [ "$SCALE" == "2.00" ]; then
    # Exactly 2.0 - use integer scaling
    GDK_SCALE=2
    GDK_DPI_SCALE=1.00
elif (( $(echo "$SCALE > 2" | bc -l) )); then
    # Greater than 2.0 - use GDK_SCALE with fine-tuning
    GDK_SCALE=2
    GDK_DPI_SCALE=$(printf "%.2f" $(echo "$SCALE / 2" | bc -l))
else
    # Fractional scaling (1.0, 1.25, 1.5, 1.75) - rely on X11 DPI
    # Don't set GDK_SCALE to avoid compounding with X11 DPI
    unset GDK_SCALE
    unset GDK_DPI_SCALE
fi

# Qt applications - rely on X11 DPI for fractional, use scale for integer
if [ "$SCALE" == "2" ] || [ "$SCALE" == "2.0" ] || [ "$SCALE" == "2.00" ] || (( $(echo "$SCALE > 2" | bc -l) )); then
    QT_SCALE_FACTOR=$(printf "%.2f" $SCALE)
else
    # For fractional scaling, let Qt use X11 DPI
    unset QT_SCALE_FACTOR
fi
QT_AUTO_SCREEN_SCALE_FACTOR=0

# Electron apps (VSCode, Discord, Obsidian, etc.)
ELECTRON_FORCE_IS_PACKAGED=1

# ============================================================================
# FUNCTIONS
# ============================================================================

calculate_values() {
    # Recalculate all derived values from SCALE
    DPI=$(printf "%.0f" $(echo "$SCALE * 96" | bc -l))
    CURSOR_SIZE=$(printf "%.0f" $(echo "$SCALE * 16" | bc -l))

    # Use same logic as main config
    if [ "$SCALE" == "2" ] || [ "$SCALE" == "2.0" ] || [ "$SCALE" == "2.00" ]; then
        GDK_SCALE=2
        GDK_DPI_SCALE=1.00
    elif (( $(echo "$SCALE > 2" | bc -l) )); then
        GDK_SCALE=2
        GDK_DPI_SCALE=$(printf "%.2f" $(echo "$SCALE / 2" | bc -l))
    else
        # Fractional scaling - rely on X11 DPI only
        unset GDK_SCALE
        unset GDK_DPI_SCALE
    fi

    # Qt scaling
    if [ "$SCALE" == "2" ] || [ "$SCALE" == "2.0" ] || [ "$SCALE" == "2.00" ] || (( $(echo "$SCALE > 2" | bc -l) )); then
        QT_SCALE_FACTOR=$(printf "%.2f" $SCALE)
    else
        unset QT_SCALE_FACTOR
    fi
}

export_environment() {
    # Export scaling variables to current shell session (only if set)
    [ -n "${GDK_SCALE+x}" ] && export GDK_SCALE
    [ -n "${GDK_DPI_SCALE+x}" ] && export GDK_DPI_SCALE
    [ -n "${QT_SCALE_FACTOR+x}" ] && export QT_SCALE_FACTOR
    export QT_AUTO_SCREEN_SCALE_FACTOR
    export ELECTRON_FORCE_IS_PACKAGED
}

apply_to_systemd() {
    # Make environment variables available to systemd user services
    # Build list of variables that are actually set
    local vars="QT_AUTO_SCREEN_SCALE_FACTOR ELECTRON_FORCE_IS_PACKAGED"
    [ -n "${GDK_SCALE+x}" ] && vars="$vars GDK_SCALE"
    [ -n "${GDK_DPI_SCALE+x}" ] && vars="$vars GDK_DPI_SCALE"
    [ -n "${QT_SCALE_FACTOR+x}" ] && vars="$vars QT_SCALE_FACTOR"

    systemctl --user import-environment $vars 2>/dev/null || true
    dbus-update-activation-environment --systemd $vars 2>/dev/null || true
}

apply_to_gsettings() {
    # Update GNOME/GTK settings
    gsettings set org.gnome.desktop.interface text-scaling-factor "$SCALE" 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" 2>/dev/null || true
}

update_xresources() {
    # Update .Xresources file with new DPI values
    if [ -f ~/.Xresources ]; then
        sed -i "s/^Xft.dpi:.*/Xft.dpi: $DPI/" ~/.Xresources
        sed -i "s/^Xcursor.size:.*/Xcursor.size: $CURSOR_SIZE/" ~/.Xresources
        xrdb -merge ~/.Xresources 2>/dev/null || true
    fi
}

apply_to_xserver() {
    # Force X server DPI setting
    xrandr --dpi "$DPI" 2>/dev/null || true
}

persist_config() {
    # Save current SCALE to this script for persistence across restarts
    sed -i "s/^SCALE=.*/SCALE=$SCALE/" "$0"
}

set_scaling() {
    local new_scale=$1

    if [ -z "$new_scale" ]; then
        echo "Error: Scale factor required"
        echo "Usage: $0 set <scale>"
        echo "Example: $0 set 1.5"
        return 1
    fi

    # Validate scale factor
    if ! echo "$new_scale" | grep -qE '^[0-9]+\.?[0-9]*$'; then
        echo "Error: Invalid scale factor: $new_scale"
        echo "Valid examples: 1.0, 1.25, 1.5, 2.0"
        return 1
    fi

    echo "Setting scaling to ${new_scale}x (${DPI} DPI)..."

    # Update SCALE and recalculate everything
    SCALE=$new_scale
    calculate_values

    # Apply to all systems
    update_xresources
    apply_to_xserver
    export_environment
    apply_to_systemd
    apply_to_gsettings
    persist_config

    # Don't auto-restart i3 - let caller handle it to avoid race conditions
    # (Monitor scripts need to restart i3 AFTER both xrandr and scaling are set)

    # Notify user
    notify-send "Display Scaling" "Scale: ${SCALE}x (${DPI} DPI)\nCursor: ${CURSOR_SIZE}px" -t 3000 2>/dev/null || true

    echo "Scaling updated successfully!"
    echo "  Scale:  ${SCALE}x"
    echo "  DPI:    ${DPI}"
    echo "  Cursor: ${CURSOR_SIZE}px"
}

show_current() {
    echo "Current Scaling Configuration:"
    echo "  Scale Factor:  ${SCALE}x"
    echo "  DPI:           ${DPI}"
    echo "  Cursor Size:   ${CURSOR_SIZE}px"
    echo ""
    echo "GTK Settings:"
    echo "  GDK_SCALE:         $GDK_SCALE"
    echo "  GDK_DPI_SCALE:     $GDK_DPI_SCALE"
    echo ""
    echo "Qt Settings:"
    echo "  QT_SCALE_FACTOR:   $QT_SCALE_FACTOR"
}

show_help() {
    echo "MASTER SCALING SYSTEM"
    echo ""
    echo "Usage:"
    echo "  $0 set <scale>     Set scaling factor (e.g., 1.5 for 150%)"
    echo "  $0 current         Show current scaling settings"
    echo "  $0 help            Show this help"
    echo ""
    echo "Common Scale Factors:"
    echo "  1.0  = 100% (96 DPI)   - Normal"
    echo "  1.25 = 125% (120 DPI)  - Slightly larger"
    echo "  1.5  = 150% (144 DPI)  - Default for 4K"
    echo "  2.0  = 200% (192 DPI)  - Very large"
    echo ""
    echo "To load values into your shell:"
    echo "  source $0"
}

# ============================================================================
# MAIN - Command line interface
# ============================================================================

# If sourced (not executed), just export the variables
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Being sourced - export environment variables
    export_environment
    return 0
fi

# Being executed - handle commands
case "${1:-}" in
    set)
        set_scaling "$2"
        ;;
    current)
        show_current
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command: ${1:-}"
        echo ""
        show_help
        exit 1
        ;;
esac
