#!/usr/bin/env bash

# you need to install mpd-mpris (apt install go golang)

# 1. Use the SAME path as media-control.sh
STATE_FILE="$HOME/.cache/active_media_player"
mkdir -p "$(dirname "$STATE_FILE")"

# 2. Get list of players
PLAYERS=($(playerctl -l 2>/dev/null))

# 3. If no players, notify and exit
if [ ${#PLAYERS[@]} -eq 0 ]; then
    notify-send -t 2000 "Media Focus" "No active players found"
    exit 1
fi

# 4. Get current player
CURRENT=$(cat "$STATE_FILE" 2>/dev/null | tr -d '\n')

# 5. Determine next player
NEXT_PLAYER=${PLAYERS[0]}
for i in "${!PLAYERS[@]}"; do
   if [[ "${PLAYERS[$i]}" == "$CURRENT" ]]; then
       NEXT_INDEX=$(( (i + 1) % ${#PLAYERS[@]} ))
       NEXT_PLAYER=${PLAYERS[$NEXT_INDEX]}
       break
   fi
done

# 6. Save and Notify
echo "$NEXT_PLAYER" > "$STATE_FILE"
notify-send -t 1500 "Media Focus" "Now controlling: $NEXT_PLAYER"
