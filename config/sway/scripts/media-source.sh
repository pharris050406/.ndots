#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"

get_active_player() {
    local saved=$(cat "$STATE_FILE" 2>/dev/null)
    local players=($(playerctl -l 2>/dev/null))
    
    if [ ${#players[@]} -eq 0 ]; then return; fi
    if [ -n "$saved" ]; then
        for p in "${players[@]}"; do
            if [ "$p" == "$saved" ]; then echo "$p"; return; fi
        done
        local base_saved="${saved%%.*}"
        for p in "${players[@]}"; do
            if [[ "$p" == "$base_saved"* ]]; then
                echo "$p" | tee "$STATE_FILE"
                return
            fi
        done
    fi
    echo "${players[0]}" | tee "$STATE_FILE"
}

LAST_META=""
PLAYER=""

while true; do
    read -r NEW_PLAYER < "$STATE_FILE" 2>/dev/null
    
    # If player changed (like pressing F8), force a fresh update
    if [ "$NEW_PLAYER" != "$PLAYER" ]; then
        PLAYER=$(get_active_player)
        LAST_META=""
    fi

    if [ -z "$PLAYER" ]; then
        if [ "$LAST_META" != "META|Not Playing|0|Not Playing" ]; then
            LAST_META="META|Not Playing|0|Not Playing"
            echo "$LAST_META"
        fi
        sleep 1
        continue
    fi

    # 1. Fetch current status and metadata in ONE call
    CURRENT_META=$(playerctl --player="$PLAYER" metadata --format "META|{{status}}|{{mpris:length}}|{{title}} - {{artist}}" 2>/dev/null)
    
    # If player closed, errored, or returned an empty string
    if [ -z "$CURRENT_META" ]; then
        PLAYER="" # Reset to find a new player next loop
        continue
    fi

    # 2. Push META to Quickshell ONLY if it changed
    if [ "$CURRENT_META" != "$LAST_META" ]; then
        echo "$CURRENT_META"
        LAST_META="$CURRENT_META"
    fi

    # 3. Handle Position Tracking
    STATUS=$(echo "$CURRENT_META" | cut -d'|' -f2)
    if [[ "$STATUS" == "Playing" || "$STATUS" == "Paused" ]]; then
        if [[ "$STATUS" == "Paused" && "$PLAYER" == firefox* ]]; then
            POS=$(playerctl --player="$PLAYER" metadata mpris:position 2>/dev/null)
            if [ -n "$POS" ]; then POS=$(awk "BEGIN {print $POS / 1000000}"); fi
        else
            POS=$(playerctl --player="$PLAYER" position 2>/dev/null)
        fi
        echo "POS|$POS"
    fi

    # Wait 1 second (interrupted instantly if F8 is pressed)
    sleep 1
done
