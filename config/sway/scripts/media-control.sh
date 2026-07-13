#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"
SAVED_PLAYER=$(cat "$STATE_FILE" 2>/dev/null)

# Get available players
mapfile -t PLAYERS < <(playerctl -l 2>/dev/null)

if [ "${#PLAYERS[@]}" -eq 0 ]; then
    notify-send -t 2000 "Media Control" "No media players running"
    exit 1
fi

# 1. Validation & Resolution
PLAYER=""

if [ -n "$SAVED_PLAYER" ]; then
    # Try exact match first
    for p in "${PLAYERS[@]}"; do
        if [ "$p" == "$SAVED_PLAYER" ]; then
            PLAYER="$p"
            break
        fi
    done

    # Try base name match (for firefox.instance changes)
    if [ -z "$PLAYER" ]; then
        BASE_SAVED="${SAVED_PLAYER%%.*}"
        for p in "${PLAYERS[@]}"; do
            if [[ "$p" == "$BASE_SAVED"* ]]; then
                PLAYER="$p"
                echo "$PLAYER" > "$STATE_FILE" # Update state file with new instance
                break
            fi
        done
    fi
fi

# Fallback to the first available player
if [ -z "$PLAYER" ]; then
    PLAYER="${PLAYERS[0]}"
    echo "$PLAYER" > "$STATE_FILE"
fi

# 2. Execute playback against the resolved player
playerctl --player="$PLAYER" "$1"
sleep 0.01 # Wait for metadata to catch up

# 3. Get Metadata
TITLE=$(playerctl --player="$PLAYER" metadata --format "{{ title }}" | sed 's/"/\\"/g')
ARTIST=$(playerctl --player="$PLAYER" metadata --format "{{ artist }}" | sed 's/"/\\"/g')
ART_URL=$(playerctl --player="$PLAYER" metadata mpris:artUrl 2>/dev/null)

# 4. Secure Image Handling
TMP_ART="/tmp/current_media_art.png"
ICON="audio-x-generic" # Default fallback

if [[ "$ART_URL" == https://i.scdn.co/* ]] || [[ "$ART_URL" == https://*.mzstatic.com/* ]]; then
    curl -s --max-filesize 2000000 --connect-timeout 2 "$ART_URL" -o "$TMP_ART" && ICON="$TMP_ART"
elif [[ "$ART_URL" == file://* ]]; then
    ICON="${ART_URL#file://}"
fi

# 5. Notify
notify-send -t 2500 -h string:x-canonical-private-synchronous:media \
            -i "$ICON" \
            "$TITLE" \
            "$ARTIST"
