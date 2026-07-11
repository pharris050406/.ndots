#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/active_media_player"
TARGET=$(cat "$STATE_FILE" 2>/dev/null | tr -d '\n')

# 1. Validation: If target is empty OR the player is no longer in the list
if [ -z "$TARGET" ] || ! playerctl -l 2>/dev/null | grep -q "^$TARGET$"; then
    # Get the first available player from the list
    NEW_TARGET=$(playerctl -l 2>/dev/null | head -n 1)
    
    if [ -z "$NEW_TARGET" ]; then
       notify-send -t 2000 "Media Control" "No active players found"
        exit 1
    fi

    # Update target and save it to the cache so it's ready for next time
    TARGET="$NEW_TARGET"
    echo "$TARGET" > "$STATE_FILE"
    
    # Optional: Brief notification to let you know it switched automatically
    notify-send -t 1000 "Media Focus" "Auto-switched to: $TARGET"
fi

# 2. Execute playback
playerctl -p "$TARGET" "$1"
sleep 0.01 # Increased slightly to ensure metadata is ready


# 2. Get Metadata (Quoted to prevent shell injection)
TITLE=$(playerctl -p "$TARGET" metadata --format "{{ title }}" | sed 's/"/\\"/g')
ARTIST=$(playerctl -p "$TARGET" metadata --format "{{ artist }}" | sed 's/"/\\"/g')
ART_URL=$(playerctl -p "$TARGET" metadata mpris:artUrl)

# 3. Secure Image Handling
TMP_ART="/tmp/current_media_art.png"
ICON="audio-x-generic" # Default fallback

if [[ "$ART_URL" == https://i.scdn.co/* ]] || [[ "$ART_URL" == https://*.mzstatic.com/* ]]; then
    # Only download if it's from known Spotify/Apple CDN domains
    # --max-filesize: Stop if the file is over 2MB
    # --connect-timeout: Don't hang if the internet is down
    curl -s --max-filesize 2000000 --connect-timeout 2 "$ART_URL" -o "$TMP_ART" && ICON="$TMP_ART"
    
elif [[ "$ART_URL" == file://* ]]; then
    # Local files are generally safe
    ICON="${ART_URL#file://}"
fi

# 4. Notify (using quoted variables)
notify-send -t 2500 -h string:x-canonical-private-synchronous:media \
            -i "$ICON" \
            "$TITLE" \
            "$ARTIST"
