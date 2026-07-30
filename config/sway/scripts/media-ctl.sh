#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"
mkdir -p "$(dirname "$STATE_FILE")"
SAVED=$(cat "$STATE_FILE" 2>/dev/null)

# Get available players
mapfile -t PLAYERS < <(playerctl -l 2>/dev/null | sort)

if [ "${#PLAYERS[@]}" -eq 0 ]; then
    notify-send -t 2000 "Media Focus" "No active players found"
    exit 1
fi

# Resolve the active player
INDEX=-1
PLAYER=""

if [ -n "$SAVED" ]; then
    # Try exact match
    for i in "${!PLAYERS[@]}"; do
        if [ "${PLAYERS[$i]}" == "$SAVED" ]; then
            INDEX=$i
            PLAYER="${PLAYERS[$i]}"
            break
        fi
    done

    # Try base match (fixes changing instance IDs)
    if [ "$INDEX" -eq -1 ]; then
        BASE_SAVED="${SAVED%%.*}"
        for i in "${!PLAYERS[@]}"; do
            if [[ "${PLAYERS[$i]}" == "$BASE_SAVED"* ]]; then
                INDEX=$i
                PLAYER="${PLAYERS[$i]}"
                echo "$PLAYER" > "$STATE_FILE"
                break
            fi
        done
    fi
fi

if [ "$1" == "cycle" ]; then
    # Cycle Logic
    NEXT_PLAYER="${PLAYERS[$(( (INDEX + 1) % ${#PLAYERS[@]} ))]}"
    echo "$NEXT_PLAYER" > "$STATE_FILE"
    notify-send -t 1500 "Media Focus" "Now controlling: $NEXT_PLAYER"
    
    # Pkill your Quickshell sleep watchdog here to update instantly
    pkill -P "$(pgrep -f "media-source.sh" | head -n 1)" sleep 2>/dev/null || true
else
    # Control Logic
    [ -z "$PLAYER" ] && PLAYER="${PLAYERS[0]}" && echo "$PLAYER" > "$STATE_FILE"
    
    # Send the action (play-pause, next, previous) to the player
    playerctl --player="$PLAYER" "$1"
    
    # Wake up the background daemon instantly!
    pkill -P "$(pgrep -f "media-source.sh" | head -n 1)" sleep 2>/dev/null || true
    
    sleep 0.01
    
    TITLE=$(playerctl --player="$PLAYER" metadata --format "{{ title }}" | sed 's/"/\\"/g')
    ARTIST=$(playerctl --player="$PLAYER" metadata --format "{{ artist }}" | sed 's/"/\\"/g')
    ART_URL=$(playerctl --player="$PLAYER" metadata mpris:artUrl 2>/dev/null)

    TMP_ART="/tmp/current_media_art.png"
    ICON="audio-x-generic"

    if [[ "$ART_URL" == https://i.scdn.co/* ]] || [[ "$ART_URL" == https://*.mzstatic.com/* ]]; then
        curl -s --max-filesize 2000000 --connect-timeout 2 "$ART_URL" -o "$TMP_ART" && ICON="$TMP_ART"
    elif [[ "$ART_URL" == file://* ]]; then
        ICON="${ART_URL#file://}"
    fi

    notify-send -t 2500 -h string:x-canonical-private-synchronous:media \
                -i "$ICON" "$TITLE" "$ARTIST"
fi
