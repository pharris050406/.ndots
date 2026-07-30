{ pkgs, lib, themesData }:

let
  inherit (themesData) themes;
  themeNames = builtins.attrNames themes;

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
  themeListString = lib.concatStringsSep "\n" themeNames;
in
pkgs.writeShellApplication {
  name = "theme-switch";
  runtimeInputs = with pkgs; [ wmenu mako sway gawk gettext ];
  text = ''
    set -euo pipefail

    MAKO_CONF="$HOME/.config/mako/config"
    SWAY_THEME_CONF="$HOME/.config/sway/theme.conf"
    QS_THEME_JSON="$HOME/.cache/theme-colors.json"
    COLORS_ENV="$HOME/.cache/theme-colors.sh"
    STATE_FILE="$HOME/.local/state/ndots-theme"
    HISTORY_FILE="$HOME/.local/state/theme-history"
    GTK3_CSS="$HOME/.config/gtk-3.0/gtk.css"
    GTK4_CSS="$HOME/.config/gtk-4.0/gtk.css"
    RMPC_TEMPLATE="$HOME/.ndots/config/rmpc/theme.ron.template"
    RMPC_THEME="$HOME/.config/rmpc/themes/ndots.ron"

    render() {
      mkdir -p "$(dirname "$MAKO_CONF")" "$(dirname "$SWAY_THEME_CONF")" \
               "$(dirname "$QS_THEME_JSON")" "$(dirname "$COLORS_ENV")" \
               "$(dirname "$STATE_FILE")" "$(dirname "$HISTORY_FILE")" \
               "$(dirname "$GTK3_CSS")" "$(dirname "$GTK4_CSS")" \
               "$(dirname "$RMPC_THEME")"

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

    set \$menu wmenu-run \
        -f "$FONT $UI_FONT_SIZE" \
        -N "''${BG#\#}" \
        -n "''${FG#\#}" \
        -S "''${FG#\#}" \
        -s "''${BG#\#}"
    EOF

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
    
      cat > "$GTK3_CSS" <<EOF
    @define-color theme_bg_color $BG;
    @define-color theme_fg_color $FG;
    @define-color theme_selected_bg_color $BLUE;
    @define-color theme_selected_fg_color $BG;
    @define-color theme_base_color $BG_PANEL;
    @define-color theme_text_color $FG;
    EOF

      cat > "$GTK4_CSS" <<EOF
    @define-color window_bg_color $BG;
    @define-color window_fg_color $FG;
    @define-color view_bg_color $BG_PANEL;
    @define-color view_fg_color $FG;
    @define-color accent_bg_color $BLUE;
    @define-color accent_fg_color $BG;
    @define-color accent_color $BLUE;
    EOF

      if [ -f "$RMPC_TEMPLATE" ]; then
        export THM_BG="#''${BG: -6}"
        export THM_BG_PANEL="#''${BG_PANEL: -6}"
        export THM_FG="#''${FG: -6}"
        export THM_MUTED="#''${MUTED: -6}"
        export THM_BLUE="#''${BLUE: -6}"
        export THM_CYAN="#''${CYAN: -6}"
        export THM_GREEN="#''${GREEN: -6}"
        export THM_YELLOW="#''${YELLOW: -6}"
        export THM_ORANGE="#''${ORANGE: -6}"
        export THM_RED="#''${RED: -6}"
        export THM_PURPLE="#''${PURPLE: -6}"

        # shellcheck disable=SC2016
        envsubst '$THM_BG $THM_BG_PANEL $THM_FG $THM_MUTED $THM_BLUE $THM_CYAN $THM_GREEN $THM_YELLOW $THM_ORANGE $THM_RED $THM_PURPLE' < "$RMPC_TEMPLATE" > "$RMPC_THEME"
      fi

      echo "$THEME_NAME" > "$STATE_FILE"

      makoctl reload >/dev/null 2>&1 || true
      swaymsg reload >/dev/null 2>&1 || true
    }

    record_history() {
      local theme="$1"
      mkdir -p "$(dirname "$HISTORY_FILE")"
      if [ -f "$HISTORY_FILE" ]; then
        local tmp
        tmp=$(mktemp)
        { echo "$theme"; grep -v -x "$theme" "$HISTORY_FILE" || true; } > "$tmp"
        mv "$tmp" "$HISTORY_FILE"
      else
        echo "$theme" > "$HISTORY_FILE"
      fi
    }

    get_ordered_themes() {
      local hist_file="$HISTORY_FILE"
      [ -f "$hist_file" ] || hist_file="/dev/null"

      gawk -v themes='${themeListString}' '
        BEGIN {
          n = split(themes, valid_arr, "\n");
          for (i = 1; i <= n; i++) {
            if (valid_arr[i] != "") valid[valid_arr[i]] = 1;
          }
        }
        {
          if ($0 in valid && !seen[$0]) {
            print $0;
            seen[$0] = 1;
          }
        }
        END {
          for (i = 1; i <= n; i++) {
            t = valid_arr[i];
            if (t != "" && !seen[t]) {
              print t;
              seen[t] = 1;
            }
          }
        }
      ' "$hist_file"
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
      record_history "$THEME_NAME"
      render
    }

    if [ "''${1:-}" = "--list" ]; then
      get_ordered_themes
      exit 0
    fi

    if [ $# -ge 1 ]; then
      apply_theme "$1"
    else
      # shellcheck source=/dev/null
      [ -f "$COLORS_ENV" ] && . "$COLORS_ENV"
      CHOICE=$(get_ordered_themes | wmenu -p "Theme:" \
          -f "''${THM_FONT:-monospace} ''${THM_FONT_SIZE:-10}" \
          -N "''${THM_BG:-1a1b26}" \
          -n "''${THM_FG:-ffffff}" \
          -S "''${THM_FG:-ffffff}" \
          -s "''${THM_BG:-1a1b26}")
      [ -n "$CHOICE" ] && apply_theme "$CHOICE"
    fi
  '';
}
