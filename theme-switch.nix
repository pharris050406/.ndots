{
  pkgs,
  lib,
  themesData,
}:

let
  inherit (themesData) themes;
  themeNames = builtins.attrNames themes;

  caseArm = name: t: ''
    ${name})
      BACKGROUND="${t.background}"; BACKGROUND_PANEL="${t.backgroundPanel}"; FOREGROUND="${t.foreground}"; MUTED="${t.muted}"
      ACCENT1="${t.accent1}"; ACCENT2="${t.accent2}"; ACCENT3="${t.accent3}"; ACCENT4="${t.accent4}"
      ACCENT5="${t.accent5}"; ACCENT6="${t.accent6}"; ACCENT7="${t.accent7}"
      FONT="${t.font}"; UI_FONT_SIZE="${toString t.uiFontSize}"; BAR_FONT_SIZE="${toString t.barFontSize}"
      BAR_COLOR="${t.barColor}"; BAR_OPACITY="${toString t.barOpacity}"
      IS_LIGHT="${if (t.isLight or false) then "true" else "false"}"
      ;;
  '';

  caseArms = lib.concatStrings (lib.mapAttrsToList caseArm themes);
  themeListString = lib.concatStringsSep "\n" themeNames;
in
pkgs.writeShellApplication {
  name = "theme-switch";
  runtimeInputs = with pkgs; [
    wmenu
    mako
    sway
    gawk
    gettext
  ];
  text = ''
    set -euo pipefail

    MAKO_CONF="$HOME/.config/mako/config"
    SWAY_THEME_CONF="$HOME/.config/sway/theme.conf"
    QS_THEME_JSON="$HOME/.cache/theme-colors.json"
    COLORS_ENV="$HOME/.cache/theme-colors.sh"
    STATE_FILE="$HOME/.local/state/ndots-theme"
    HISTORY_FILE="$HOME/.local/state/theme-history"
    RMPC_TEMPLATE="$HOME/.ndots/config/rmpc/theme.ron.template"
    RMPC_THEME="$HOME/.config/rmpc/themes/ndots.ron"
    NVIM_THEME_LUA="$HOME/.cache/nvim/theme.lua"

    render() {
      mkdir -p "$(dirname "$MAKO_CONF")" "$(dirname "$SWAY_THEME_CONF")" \
               "$(dirname "$QS_THEME_JSON")" "$(dirname "$COLORS_ENV")" \
               "$(dirname "$STATE_FILE")" "$(dirname "$HISTORY_FILE")" \
               "$(dirname "$RMPC_THEME")" "$(dirname "$NVIM_THEME_LUA")"

      cat > "$MAKO_CONF" <<EOF
    font=$FONT $UI_FONT_SIZE
    background-color=$BACKGROUND
    text-color=$FOREGROUND
    border-color=$FOREGROUND
    border-size=2
    default-timeout=5000

    [urgency=high]
    border-color=$ACCENT6
    EOF

      cat > "$SWAY_THEME_CONF" <<EOF
    set \$thm_bg $BACKGROUND
    set \$thm_fg $FOREGROUND
    set \$thm_blue $ACCENT2

    set \$menu wmenu-run \
        -f "$FONT $UI_FONT_SIZE" \
        -N "''${BACKGROUND#\#}" \
        -n "''${FOREGROUND#\#}" \
        -S "''${FOREGROUND#\#}" \
        -s "''${BACKGROUND#\#}"
    EOF

      cat > "$QS_THEME_JSON" <<EOF
    {
        "background": "$BACKGROUND_PANEL",
        "foreground": "$FOREGROUND",
        "muted": "$MUTED",
        "accent1": "$ACCENT1",
        "accent2": "$ACCENT2",
        "accent3": "$ACCENT3",
        "accent4": "$ACCENT4",
        "accent5": "$ACCENT5",
        "accent6": "$ACCENT6",
        "accent7": "$ACCENT7",
        "barColor": "$BAR_COLOR",
        "barOpacity": $BAR_OPACITY,
        "font": "$FONT",
        "fontSize": $BAR_FONT_SIZE
    }
    EOF

      cat > "$COLORS_ENV" <<EOF
    export THM_BG="''${BACKGROUND#\#}"
    export THM_FG="''${FOREGROUND#\#}"
    export THM_BLUE="''${ACCENT2#\#}"
    export THM_FONT="$FONT"
    export THM_FONT_SIZE="$UI_FONT_SIZE"
    EOF

      cat > "$NVIM_THEME_LUA" <<EOF
    return {
      name = "$THEME_NAME",
      bg = "$BACKGROUND",
      bg_panel = "$BACKGROUND_PANEL",
      fg = "$FOREGROUND",
      muted = "$MUTED",
      accent1 = "$ACCENT1",
      accent2 = "$ACCENT2",
      accent3 = "$ACCENT3",
      accent4 = "$ACCENT4",
      accent5 = "$ACCENT5",
      accent6 = "$ACCENT6",
      accent7 = "$ACCENT7",
      font = "$FONT",
      is_light = $IS_LIGHT,
    }
    EOF

      if [ -f "$RMPC_TEMPLATE" ]; then
        export THM_BG="#''${BACKGROUND: -6}"
        export THM_BG_PANEL="#''${BACKGROUND_PANEL: -6}"
        export THM_FG="#''${FOREGROUND: -6}"
        export THM_MUTED="#''${MUTED: -6}"
        # NOTE: rmpc's template wants named colors, but the theme data only
        # has ACCENT1..7. This mapping is a guess (ACCENT2=blue is confirmed
        # elsewhere in this script) -- verify against your actual theme data.
        export THM_CYAN="#''${ACCENT1: -6}"
        export THM_BLUE="#''${ACCENT2: -6}"
        export THM_GREEN="#''${ACCENT3: -6}"
        export THM_YELLOW="#''${ACCENT4: -6}"
        export THM_ORANGE="#''${ACCENT5: -6}"
        export THM_RED="#''${ACCENT6: -6}"
        export THM_PURPLE="#''${ACCENT7: -6}"

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
      CHOICE=$(get_ordered_themes | wmenu -i \
          -f "''${THM_FONT:-monospace} ''${THM_FONT_SIZE:-10}" \
          -N "''${THM_BG:-1a1b26}" \
          -n "''${THM_FG:-c0caf5}" \
          -S "''${THM_FG:-c0caf5}" \
          -s "''${THM_BG:-1a1b26}")
      [ -n "$CHOICE" ] && apply_theme "$CHOICE"
    fi
  '';
}
