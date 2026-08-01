#!/usr/bin/env bash

command -v wmenu >/dev/null || { echo "wmenu not found"; exit 1; }
command -v mpc >/dev/null || { echo "mpc not found"; exit 1; }

COLORS_ENV="$HOME/.cache/theme-colors.sh"
# shellcheck source=/dev/null
[ -f "$COLORS_ENV" ] && . "$COLORS_ENV"

HISTFILE="$HOME/.cache/wmenu-music-history"
touch "$HISTFILE" 2>/dev/null

# 1. Fetch current MPD items
CURRENT_ITEMS=$(
  {
    mpc lsplaylists | sed 's/^/Playlist: /'
    mpc list album | grep '\S' | sed 's/^/Album: /'
    mpc listall | awk -F/ '{
      fname = $NF
      sub(/\.[^.]+$/, "", fname)
      artist = (NF >= 2) ? $1 : ""
      if (artist != "") {
        print "Track: " fname " - " artist
      } else {
        print "Track: " fname
      }
    }'
  }
)

# 2. Prune dead entries from HISTFILE (only keep entries that exist in MPD)
if [ -s "$HISTFILE" ]; then
  VALID_HIST=$(grep -F -x -f "$HISTFILE" <(echo "$CURRENT_ITEMS") 2>/dev/null || true)
  echo "$VALID_HIST" > "$HISTFILE"
fi

# 3. Combine valid history + current MPD items
SELECTION=$(
  {
    cat "$HISTFILE"
    echo "$CURRENT_ITEMS"
  } | awk 'NF && !seen[$0]++' | wmenu -f "$THM_FONT $THM_FONT_SIZE" -N "$THM_BG" -n "$THM_FG" -S "$THM_FG" -s "$THM_BG"
)

[ -z "$SELECTION" ] && exit 0

grep -v -F -x "$SELECTION" "$HISTFILE" > "$HISTFILE.tmp" 2>/dev/null
echo "$SELECTION" | cat - "$HISTFILE.tmp" | head -n 20 > "$HISTFILE"
rm -f "$HISTFILE.tmp"

if [[ "$SELECTION" == Playlist:* ]]; then
  NAME="${SELECTION#Playlist: }"
  mpc clear
  mpc load "$NAME"
  mpc play

elif [[ "$SELECTION" == Album:* ]]; then
  NAME="${SELECTION#Album: }"
  mpc clear
  mpc findadd album "$NAME"
  mpc play

elif [[ "$SELECTION" == Track:* ]]; then
  NAME="${SELECTION#Track: }"
  URI=$(mpc listall | awk -F/ -v sel="$NAME" '{
    fname = $NF
    sub(/\.[^.]+$/, "", fname)
    artist = (NF >= 2) ? $1 : ""
    display = (artist != "") ? fname " - " artist : fname
    if (display == sel) {
      print $0
      exit
    }
  }')
  
  if [ -n "$URI" ]; then
    mpc clear
    mpc add "$URI"
    mpc play
  fi
fi
