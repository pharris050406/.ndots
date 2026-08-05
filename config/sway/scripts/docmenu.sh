#!/usr/bin/env bash
command -v wmenu >/dev/null || { echo "wmenu not found"; exit 1; }
command -v zathura >/dev/null || { echo "zathura not found"; exit 1; }

COLORS_ENV="$HOME/.cache/theme-colors.sh"
[ -f "$COLORS_ENV" ] && . "$COLORS_ENV"

DOCS="${DOC_DIR:-$HOME/Documents}"
HISTFILE="$HOME/.cache/wmenu-doc-history"
[ -d "$DOCS" ] || { echo "no such dir: $DOCS"; exit 1; }
touch "$HISTFILE" 2>/dev/null

CURRENT_ITEMS=$(
  find "$DOCS" -type f \
    -iregex '.*\.\(pdf\|ps\|eps\|djvu\|cbz\|cbr\|cb7\|cbt\)$' \
    -printf '%P\n' | sort
)
[ -z "$CURRENT_ITEMS" ] && { echo "no documents in $DOCS"; exit 0; }

if [ -s "$HISTFILE" ]; then
  VALID_HIST=$(grep -F -x -f <(echo "$CURRENT_ITEMS") <(awk 'NF' "$HISTFILE") || true)
  awk 'NF' <<< "$VALID_HIST" > "$HISTFILE"
fi

SELECTION=$(
  {
    cat "$HISTFILE"
    echo "$CURRENT_ITEMS"
  } | awk 'NF && !seen[$0]++' \
    | wmenu -i -p "doc" -f "$THM_FONT $THM_FONT_SIZE" \
            -N "$THM_BG" -n "$THM_FG" -S "$THM_FG" -s "$THM_BG"
)
[ -z "$SELECTION" ] && exit 0

grep -v -F -x "$SELECTION" "$HISTFILE" > "$HISTFILE.tmp" 2>/dev/null
{ echo "$SELECTION"; cat "$HISTFILE.tmp"; } | awk 'NF' | head -n 20 > "$HISTFILE"
rm -f "$HISTFILE.tmp"

setsid -f zathura "$DOCS/$SELECTION" >/dev/null 2>&1
