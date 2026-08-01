#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"

get_active_player() {
    local saved=$(cat "$STATE_FILE" 2>/dev/null)
    # Use timeout to prevent playerctl -l from hanging
    local players=($(timeout 0.5 playerctl -l 2>/dev/null))
    
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

# Clean up any leftover processes on script start
pkill -f "playerctl" 2>/dev/null || true

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

    # 1. Fetch current status and metadata in ONE call (with 0.5s timeout to kill hangs)
    CURRENT_META=$(timeout 0.5 playerctl --player="$PLAYER" metadata --format "META|{{status}}|{{mpris:length}}|{{title}} - {{artist}}" 2>/dev/null)
    
    # If player closed, errored, timed out, or returned an empty string
    if [ -z "$CURRENT_META" ]; then
        PLAYER="" # Reset to find a new player next loop
        sleep 1
        continue
    fi

    # 2. Push META to Quickshell ONLY if it changed
    META_CHANGED=false
    if [ "$CURRENT_META" != "$LAST_META" ]; then
        echo "$CURRENT_META"
        LAST_META="$CURRENT_META"
        META_CHANGED=true
    fi

    # 3. Handle Position Tracking (with 0.3s timeout)
    STATUS=$(echo "$CURRENT_META" | cut -d'|' -f2)
    
    # Only push POS if Playing, OR if the metadata just changed (to sync initial pause state)
    if [[ "$STATUS" == "Playing" ]] || [ "$META_CHANGED" = true ]; then
        POS=$(timeout 0.3 playerctl --player="$PLAYER" position 2>/dev/null)
        if [ -n "$POS" ]; then
            echo "POS|${POS%.*}"
        fi
    fi

    # Wait 1 second (interrupted instantly if F8 is pressed)
    sleep 1
done
