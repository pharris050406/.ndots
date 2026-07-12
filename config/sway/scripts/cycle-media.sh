#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"
mkdir -p "$(dirname "$STATE_FILE")"

# Sort for a stable order. playerctl -l's natural order follows
# playerctld's MRU stack, which shifts any time e.g. a browser tab
# starts autoplaying - exactly what we're trying to avoid.
mapfile -t PLAYERS < <(playerctl -l 2>/dev/null | sort)

if [ "${#PLAYERS[@]}" -eq 0 ]; then
    notify-send -t 2000 "Media Focus" "No active players found"
    exit 1
fi

CURRENT=$(cat "$STATE_FILE" 2>/dev/null)

INDEX=-1
for i in "${!PLAYERS[@]}"; do
    [ "${PLAYERS[$i]}" == "$CURRENT" ] && INDEX=$i && break
done

NEXT_PLAYER="${PLAYERS[$(( (INDEX + 1) % ${#PLAYERS[@]} ))]}"

echo "$NEXT_PLAYER" > "$STATE_FILE"
notify-send -t 1500 "Media Focus" "Now controlling: $NEXT_PLAYER"
