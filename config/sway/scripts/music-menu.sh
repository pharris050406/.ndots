#!/usr/bin/env bash

source "$HOME/.ndots/config/theme/colors.sh"

command -v wmenu >/dev/null || { echo "wmenu not found"; exit 1; }
command -v mpc >/dev/null || { echo "mpc not found"; exit 1; }

HISTFILE="$HOME/.cache/wmenu-music-history"
touch "$HISTFILE" 2>/dev/null

SELECTION=$(
  {
    cat "$HISTFILE"
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
  } | awk '!seen[$0]++' | wmenu -i -p "Search Music:" \
      -f "$THM_FONT $THM_FONT_SIZE" \
      -N "$THM_BG" \
      -n "$THM_FG" \
      -S "$THM_BLUE" \
      -s "$THM_BG"
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
