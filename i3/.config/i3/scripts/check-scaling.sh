#!/bin/bash
#
# Scaling Diagnostic Tool
# Checks if different system components are detecting correct scaling
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

EXPECTED_SCALE=1.5
EXPECTED_DPI=144

echo -e "${BLUE}=== Scaling Diagnostic Report ===${NC}\n"

# Check scaling.sh config
echo -e "${BLUE}[1] scaling.sh Configuration${NC}"
if [ -f ~/.config/i3/scripts/scaling.sh ]; then
    SCALE=$(grep "^SCALE=" ~/.config/i3/scripts/scaling.sh | cut -d'=' -f2)
    echo -e "  SCALE=$SCALE"
    if [ "$SCALE" == "$EXPECTED_SCALE" ]; then
        echo -e "  ${GREEN}✓ Correct${NC}"
    else
        echo -e "  ${RED}✗ Expected $EXPECTED_SCALE${NC}"
    fi
else
    echo -e "  ${RED}✗ scaling.sh not found${NC}"
fi
echo ""

# Check X11 DPI
echo -e "${BLUE}[2] X11 DPI Settings${NC}"
XDPI=$(xrdb -query 2>/dev/null | grep "Xft.dpi:" | awk '{print $2}')
echo -e "  Xft.dpi: $XDPI"
if [ "$XDPI" == "$EXPECTED_DPI" ]; then
    echo -e "  ${GREEN}✓ Correct${NC}"
else
    echo -e "  ${RED}✗ Expected $EXPECTED_DPI${NC}"
fi

XRANDR_DPI=$(xrandr --verbose 2>/dev/null | grep " connected" -A 10 | grep "DPI" | head -1 | awk '{print $2}' | cut -d'x' -f1)
echo -e "  xrandr DPI: $XRANDR_DPI"
echo ""

# Check current shell environment
echo -e "${BLUE}[3] Current Shell Environment${NC}"
GDK_SCALE_VAL=${GDK_SCALE:-"not set"}
GDK_DPI_SCALE_VAL=${GDK_DPI_SCALE:-"not set"}
QT_SCALE_VAL=${QT_SCALE_FACTOR:-"not set"}

echo -e "  GDK_SCALE=$GDK_SCALE_VAL"
if [ "$GDK_SCALE_VAL" == "2" ]; then
    echo -e "    ${GREEN}✓ Correct${NC}"
else
    echo -e "    ${RED}✗ Expected 2${NC}"
fi

echo -e "  GDK_DPI_SCALE=$GDK_DPI_SCALE_VAL"
if [ "$GDK_DPI_SCALE_VAL" == "0.75" ]; then
    echo -e "    ${GREEN}✓ Correct (has leading zero)${NC}"
elif [ "$GDK_DPI_SCALE_VAL" == ".75" ]; then
    echo -e "    ${YELLOW}⚠ Missing leading zero (.75 should be 0.75)${NC}"
    echo -e "      ${YELLOW}Some GTK apps may not parse this correctly${NC}"
else
    echo -e "    ${RED}✗ Expected 0.75${NC}"
fi

echo -e "  QT_SCALE_FACTOR=$QT_SCALE_VAL"
if [ "$QT_SCALE_VAL" == "1.5" ] || [ "$QT_SCALE_VAL" == "1.50" ]; then
    echo -e "    ${GREEN}✓ Correct${NC}"
else
    echo -e "    ${RED}✗ Expected 1.5${NC}"
fi

# Calculate effective GTK scaling
if [ "$GDK_SCALE_VAL" != "not set" ] && [ "$GDK_DPI_SCALE_VAL" != "not set" ]; then
    EFFECTIVE_SCALE=$(echo "$GDK_SCALE_VAL * $GDK_DPI_SCALE_VAL" | bc 2>/dev/null || echo "error")
    echo -e "  Effective GTK scale: ${GDK_SCALE_VAL} × ${GDK_DPI_SCALE_VAL} = ${EFFECTIVE_SCALE}x"
    if [ "$EFFECTIVE_SCALE" == "1.5" ]; then
        echo -e "    ${GREEN}✓ Apps should render at 150%${NC}"
    elif [ "$EFFECTIVE_SCALE" == "2" ]; then
        echo -e "    ${RED}✗ Apps will render at 200% (too large!)${NC}"
    fi
fi
echo ""

# Check systemd user environment
echo -e "${BLUE}[4] Systemd User Environment (for systemd services)${NC}"
SYS_GDK_SCALE=$(systemctl --user show-environment 2>/dev/null | grep "^GDK_SCALE=" | cut -d'=' -f2)
SYS_GDK_DPI_SCALE=$(systemctl --user show-environment 2>/dev/null | grep "^GDK_DPI_SCALE=" | cut -d'=' -f2)
SYS_QT_SCALE=$(systemctl --user show-environment 2>/dev/null | grep "^QT_SCALE_FACTOR=" | cut -d'=' -f2)

echo -e "  GDK_SCALE=${SYS_GDK_SCALE:-"not set"}"
echo -e "  GDK_DPI_SCALE=${SYS_GDK_DPI_SCALE:-"not set"}"
echo -e "  QT_SCALE_FACTOR=${SYS_QT_SCALE:-"not set"}"

if [ "$SYS_GDK_DPI_SCALE" == "0.75" ]; then
    echo -e "  ${GREEN}✓ Systemd env has correct format${NC}"
elif [ "$SYS_GDK_DPI_SCALE" == ".75" ]; then
    echo -e "  ${YELLOW}⚠ Systemd env missing leading zero${NC}"
fi
echo ""

# Check GTK gsettings
echo -e "${BLUE}[5] GTK GSettings (GNOME/GTK apps)${NC}"
TEXT_SCALE=$(gsettings get org.gnome.desktop.interface text-scaling-factor 2>/dev/null)
CURSOR_SIZE=$(gsettings get org.gnome.desktop.interface cursor-size 2>/dev/null)
echo -e "  text-scaling-factor: $TEXT_SCALE (expected: 1.5)"
echo -e "  cursor-size: $CURSOR_SIZE (expected: 24)"
echo ""

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo ""
echo -e "${YELLOW}Expected Behavior:${NC}"
echo -e "  • GTK apps: GDK_SCALE=2 × GDK_DPI_SCALE=0.75 = 150%"
echo -e "  • Qt apps: QT_SCALE_FACTOR=1.5 = 150%"
echo -e "  • X11 apps: Xft.dpi=144 = 150%"
echo ""
echo -e "${YELLOW}Common Issues:${NC}"
echo -e "  • Apps at 200%: GDK_DPI_SCALE not set or wrong format (.75 vs 0.75)"
echo -e "  • Apps at 100%: Environment variables not exported to session"
echo -e "  • Inconsistent scaling: Different env vars in shell vs systemd"
echo ""
echo -e "${YELLOW}What to check:${NC}"
echo -e "  • Launch a GTK app (like ${BLUE}nautilus${NC}) - should be 150%"
echo -e "  • Launch a Qt app (like ${BLUE}kate${NC}) - should be 150%"
echo -e "  • Launch from terminal vs rofi - both should match"
