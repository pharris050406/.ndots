#!/bin/sh
LEN=22 # How many characters you want visible at once

while true; do
    # Get the current track or set a default if stopped
    TRACK=$(mpc current)
    if [ -z "$TRACK" ]; then
        echo "Stopped"
        mpc idle player > /dev/null
        continue
    fi

    # If the title fits, print it static and wait for a player change
    if [ $(echo -n "$TRACK" | wc -m) -le $LEN ]; then
        echo "$TRACK"
        mpc idle player > /dev/null
    else
        # Pad the string with a spacer so it separates neatly when looping
        PADDED="$TRACK   "
        TOTAL_LEN=$(echo -n "$PADDED" | wc -m)
        
        # Scroll loop
        for i in $(seq 0 $TOTAL_LEN); do
            # Double-check if the song changed mid-scroll step
            if [ "$(mpc current)" != "$TRACK" ]; then break; fi
            
            # Cut the moving string window
            VISIBLE=$(echo -n "$PADDED$PADDED" | cut -c $((i+1))-$((i+LEN)))
            printf "%s\n" "$VISIBLE"
            sleep 0.35
        done
    fi
done
