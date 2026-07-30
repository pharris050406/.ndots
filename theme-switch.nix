{ pkgs, lib, themesData }:

let
  inherit (themesData) themes;
  themeNames = builtins.attrNames themes;

  # One `name) VAR="val" ...;;` case arm per theme, generated from themes.nix
  # so the palette data only ever lives in one place.
  caseArm = name: t: ''
    ${name})
      BG="${t.bg}"; BG_PANEL="${t.bgPanel}"; FG="${t.fg}"; MUTED="${t.muted}"
      BLUE="${t.blue}"; CYAN="${t.cyan}"; GREEN="${t.green}"; YELLOW="${t.yellow}"
      ORANGE="${t.orange}"; RED="${t.red}"; PURPLE="${t.purple}"
      FONT="${t.font}"; UI_FONT_SIZE="${toString t.uiFontSize}"; BAR_FONT_SIZE="${toString t.barFontSize}"
      BAR_COLOR="${t.barColor}"; BAR_OPACITY="${toString t.barOpacity}"
      ;;
  '';

  caseArms = lib.concatStrings (lib.mapAttrsToList caseArm themes);
  themeList = lib.concatStringsSep "\n" themeNames;
in
pkgs.writeShellApplication {
  name = "theme-switch";
  runtimeInputs = with pkgs; [ wmenu mako sway ];
  text = ''
    set -euo pipefail

    MAKO_CONF="$HOME/.config/mako/config"
    SWAY_THEME_CONF="$HOME/.config/sway/theme.conf"
    QS_THEME_JSON="$HOME/.cache/theme-colors.json"
    COLORS_ENV="$HOME/.cache/theme-colors.sh"
    STATE_FILE="$HOME/.local/state/ndots-theme"

    render() {
      mkdir -p "$(dirname "$MAKO_CONF")" "$(dirname "$SWAY_THEME_CONF")" \
               "$(dirname "$QS_THEME_JSON")" "$(dirname "$COLORS_ENV")" "$(dirname "$STATE_FILE")"

      cat > "$MAKO_CONF" <<EOF
    font=$FONT $UI_FONT_SIZE
    background-color=$BG
    text-color=$FG
    border-color=$FG
    border-size=2
    default-timeout=5000

    [urgency=high]
    border-color=$RED
    EOF

      cat > "$SWAY_THEME_CONF" <<EOF
    set \$thm_bg $BG
    set \$thm_fg $FG
    set \$thm_blue $BLUE

    set \$menu wmenu-run \\
        -f "$FONT $UI_FONT_SIZE" \\
        -N "''${BG#\#}" \\
        -n "''${FG#\#}" \\
        -S "''${FG#\#}" \\
        -s "''${BG#\#}"
    EOF

      # Write a JSON file to the cache directory instead of a QML file
      cat > "$QS_THEME_JSON" <<EOF
    {
        "bg": "$BG_PANEL",
        "fg": "$FG",
        "muted": "$MUTED",
        "blue": "$BLUE",
        "cyan": "$CYAN",
        "green": "$GREEN",
        "yellow": "$YELLOW",
        "orange": "$ORANGE",
        "red": "$RED",
        "purple": "$PURPLE",
        "barColor": "$BAR_COLOR",
        "barOpacity": $BAR_OPACITY,
        "font": "$FONT",
        "fontSize": $BAR_FONT_SIZE
    }
    EOF

      cat > "$COLORS_ENV" <<EOF
    export THM_BG="''${BG#\#}"
    export THM_FG="''${FG#\#}"
    export THM_BLUE="''${BLUE#\#}"
    export THM_FONT="$FONT"
    export THM_FONT_SIZE="$UI_FONT_SIZE"
    EOF

    echo "$THEME_NAME" > "$STATE_FILE"

    makoctl reload >/dev/null 2>&1 || true
    swaymsg reload >/dev/null 2>&1 || true
    
    }

    apply_theme() {
      THEME_NAME="$1"
      case "$THEME_NAME" in
    ${caseArms}
        *)
          echo "Unknown theme: $THEME_NAME" >&2
          echo "Available: ${lib.concatStringsSep ", " themeNames}" >&2
          exit 1
          ;;
      esac
      render
    }

    if [ "''${1:-}" = "--list" ]; then
      printf '%s\n' ${lib.concatMapStringsSep " " (n: "\"${n}\"") themeNames}
      exit 0
    fi

    if [ $# -ge 1 ]; then
      apply_theme "$1"
    else
      # shellcheck source=/dev/null
      [ -f "$COLORS_ENV" ] && . "$COLORS_ENV"
      CHOICE=$(printf '${themeList}\n' | wmenu -p "Theme:" \
          -f "''${THM_FONT:-monospace} ''${THM_FONT_SIZE:-10}" \
          -N "''${THM_BG:-1a1b26}" \
          -n "''${THM_FG:-ffffff}" \
          -S "''${THM_FG:-ffffff}" \
          -s "''${THM_BG:-1a1b26}")
      [ -n "$CHOICE" ] && apply_theme "$CHOICE"
    fi
  '';
}
