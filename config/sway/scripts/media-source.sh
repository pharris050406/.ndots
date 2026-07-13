#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"

get_active_player() {
    local saved=$(cat "$STATE_FILE" 2>/dev/null)
    local players=($(playerctl -l 2>/dev/null))
    
    if [ ${#players[@]} -eq 0 ]; then
        return
    fi

    if [ -n "$saved" ]; then
        # Exact match
        for p in "${players[@]}"; do
            if [ "$p" == "$saved" ]; then
                echo "$p"
                return
            fi
        done
        
        # Base match (Firefox instance ID changed)
        local base_saved="${saved%%.*}"
        for p in "${players[@]}"; do
            if [[ "$p" == "$base_saved"* ]]; then
                echo "$p"
                echo "$p" > "$STATE_FILE"
                return
            fi
        done
    fi
    
    # Fallback to first available
    echo "${players[0]}"
    echo "${players[0]}" > "$STATE_FILE"
}

while true; do
    PLAYER=$(get_active_player)

    if [ -z "$PLAYER" ]; then
        echo "META|Not Playing|0|Not Playing"
        sleep 2
        continue
    fi

    # 1. Start the event listener for instant updates
    playerctl --player="$PLAYER" metadata --format "META|{{status}}|{{mpris:length}}|{{title}} - {{artist}}" --follow 2>/dev/null &
    META_PID=$!

    CURRENT_TITLE=""

    # 2. The Watchdog Loop (Runs every 1 second to fetch position)
    while kill -0 $META_PID 2>/dev/null; do
        NEW_PLAYER=$(get_active_player)
        if [ "$NEW_PLAYER" != "$PLAYER" ]; then
            break # Player changed, restart pipeline
        fi

        # Actively poll the title
        ACTUAL_TITLE=$(playerctl --player="$PLAYER" metadata --format "{{title}}" 2>/dev/null)

        # If the track changed, but --follow dropped the event (Spotify freeze)
        if [ -n "$CURRENT_TITLE" ] && [ "$ACTUAL_TITLE" != "$CURRENT_TITLE" ]; then
            # Force an immediate metadata update to QML
            playerctl --player="$PLAYER" metadata --format "META|{{status}}|{{mpris:length}}|{{title}} - {{artist}}" 2>/dev/null
            
            # Break the loop to kill the frozen follower and restart it
            break 
        fi
        CURRENT_TITLE="$ACTUAL_TITLE"

        STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)
        if [[ "$STATUS" == "Playing" || "$STATUS" == "Paused" ]]; then
            POS=$(playerctl --player="$PLAYER" position 2>/dev/null)
            echo "POS|$POS"
        fi
        sleep 1
    done

    # Clean up the stuck background process before looping
    kill $META_PID 2>/dev/null
    wait $META_PID 2>/dev/null
done
