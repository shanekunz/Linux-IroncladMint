#!/bin/bash
# Set HiDPI scaling environment variables for i3 session
# This ensures all applications launched from i3 inherit proper scaling

# Source master scaling system
if [ -f ~/.config/i3/scripts/scaling.sh ]; then
    source ~/.config/i3/scripts/scaling.sh
    apply_to_systemd
else
    # Fallback if scaling.sh doesn't exist
    export GDK_SCALE=2
    export GDK_DPI_SCALE=0.75
    export QT_SCALE_FACTOR=1.5
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export ELECTRON_FORCE_IS_PACKAGED=1

    systemctl --user import-environment GDK_SCALE GDK_DPI_SCALE QT_SCALE_FACTOR QT_AUTO_SCREEN_SCALE_FACTOR ELECTRON_FORCE_IS_PACKAGED 2>/dev/null || true
    dbus-update-activation-environment --systemd GDK_SCALE GDK_DPI_SCALE QT_SCALE_FACTOR QT_AUTO_SCREEN_SCALE_FACTOR ELECTRON_FORCE_IS_PACKAGED 2>/dev/null || true
fi
