#!/usr/bin/env bash

# --- BASE COLORS ---
BG="#1a1b26"
BG_PANEL="#80000000"
FG="#ffffff"
MUTED="#565f89"
BLUE="#7aa2f7"
CYAN="#00f7ff"
GREEN="#40eb34"
YELLOW="#e0af68"
ORANGE="#ff8000"
RED="#f7768e"
PURPLE="#c800ff"

# --- FONTS ---
FONT="JetBrainsMono Nerd Font"
BAR_FONT_SIZE="13"
UI_FONT_SIZE="10"

# --- UI SPECIFICS (wmenu & mako) ---
UI_BG="$BG"    # Translucent Tokyo Night background (80% opacity)
UI_OUTLINE="#ffffff" # White outlines
BAR_COLOR="#1e1e2e"
BAR_OPACITY="0.85"

# Helper function to strip '#' from hex strings for wmenu
clean_hex() { echo "$1" | tr -d '#'; }

UI_BG_HEX=$(clean_hex "$UI_BG")
FG_HEX=$(clean_hex "$FG")
OUTLINE_HEX=$(clean_hex "$UI_OUTLINE")


# # 1. Generate the Quickshell Component
# # Superseded by theme.nix -> xdg.configFile."quickshell/Theme.qml" in home.nix
# cat <<EOF > "$HOME/.ndots/config/quickshell/Theme.qml"
# import QtQuick
#
# QtObject {
#     property color colBg: "$BG_PANEL"
#     property color colFg: "$FG"
#     property color colMuted: "$MUTED"
#     property color colBlue: "$BLUE"
#     property color colCyan: "$CYAN"
#     property color colGreen: "$GREEN"
#     property color colYellow: "$YELLOW"
#     property color colOrange: "$ORANGE"
#     property color colRed: "$RED"
#     property color colPurple: "$PURPLE"
#
#     property color barColor: "$BAR_COLOR"
#     property real barOpacity: $BAR_OPACITY
#
#     property string fontFamily: "$FONT"
#     property int fontSize: $BAR_FONT_SIZE
# }
# EOF

# # 2. Generate the Sway Include File
# # Uses UI_FONT_SIZE, translucent background, and white text selection
# cat <<EOF > "$HOME/.ndots/config/sway/theme.conf"
# set \$thm_bg $BG
# set \$thm_fg $FG
# set \$thm_blue $BLUE
#
# set \$menu wmenu-run -f "$FONT $UI_FONT_SIZE" -N $UI_BG_HEX -n $FG_HEX -S $OUTLINE_HEX -s $UI_BG_HEX
# EOF

# 3. Generate the Bash Source File (for music-menu.sh)
# Safely exports cleaned hexes so wmenu doesn't crash!
# cat <<EOF > "$HOME/.ndots/config/theme/colors.sh"
# export THM_BG="$UI_BG_HEX"
# export THM_FG="$FG_HEX"
# export THM_BLUE="$OUTLINE_HEX"
# export THM_FONT="$FONT"
# export THM_FONT_SIZE="$UI_FONT_SIZE"
# EOF

# 4. Generate and Reload Mako Configuration
# Uses UI_FONT_SIZE, translucent background, and white borders
# mkdir -p "$HOME/.config/mako"
# cat <<EOF > "$HOME/.config/mako/config"
# font=$FONT $UI_FONT_SIZE
# background-color=$UI_BG
# text-color=$FG
# border-color=$UI_OUTLINE
# border-size=2
# default-timeout=5000
#
# [urgency=high]
# border-color=$RED
# EOF
#
# makoctl reload 2>/dev/null || true

echo "System-wide theme successfully applied!"
