#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/quickshell/selected-player"
PLAYER=$(cat "$STATE_FILE" 2>/dev/null)
[ -z "$PLAYER" ] && PLAYER="mpd"

# 1. Validation: make sure the selected player is actually running
if ! playerctl -l 2>/dev/null | grep -qx "$PLAYER"; then
    notify-send -t 2000 "Media Control" "Selected player ($PLAYER) not found"
    exit 1
fi

# 2. Execute playback against the pinned player specifically
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
