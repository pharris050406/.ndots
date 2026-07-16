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

while true; do
    PLAYER=$(get_active_player)

    if [ -z "$PLAYER" ]; then
        echo "META|Not Playing|0|Not Playing"
        sleep 2
        continue
    fi

    playerctl --player="$PLAYER" metadata --format "META|{{status}}|{{mpris:length}}|{{title}} - {{artist}}" --follow 2>/dev/null &
    META_PID=$!
    CURRENT_TITLE=""

    # The Watchdog Loop
    while kill -0 $META_PID 2>/dev/null; do
        # 1. Native bash read (0 forks instead of running playerctl -l)
        read -r NEW_PLAYER < "$STATE_FILE"
        if [ "$NEW_PLAYER" != "$PLAYER" ]; then
            break 
        fi

        # 2. Get Title and Status in one single process call
        RAW_DATA=$(playerctl --player="$PLAYER" metadata --format "{{status}}|{{title}}" 2>/dev/null)
        if [ -z "$RAW_DATA" ]; then break; fi # Player closed
        
        IFS='|' read -r STATUS ACTUAL_TITLE <<< "$RAW_DATA"

        if [ -n "$CURRENT_TITLE" ] && [ "$ACTUAL_TITLE" != "$CURRENT_TITLE" ]; then
            playerctl --player="$PLAYER" metadata --format "META|{{status}}|{{mpris:length}}|{{title}} - {{artist}}" 2>/dev/null
            break 
        fi
        CURRENT_TITLE="$ACTUAL_TITLE"

        # 3. Position logic
        if [[ "$STATUS" == "Playing" || "$STATUS" == "Paused" ]]; then
            if [[ "$STATUS" == "Paused" && "$PLAYER" == firefox* ]]; then
                POS=$(playerctl --player="$PLAYER" metadata mpris:position 2>/dev/null)
                if [ -n "$POS" ]; then POS=$(awk "BEGIN {print $POS / 1000000}"); fi
            else
                POS=$(playerctl --player="$PLAYER" position 2>/dev/null)
            fi
            echo "POS|$POS"
        fi
        
        sleep 1
    done

    kill $META_PID 2>/dev/null
    wait $META_PID 2>/dev/null
done
