#!/usr/bin/env bash

sync_led() {
    # 1. Check the state of the active audio device (works for Bluetooth, USB, etc.)
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q '\[MUTED\]'; then
        # The active device is MUTED. Turn the hardware LED ON.
        # We bypass PipeWire and tell the kernel directly to mute the hardware cards.
        amixer -c 0 set Master mute >/dev/null 2>&1
        amixer -c 1 set Master mute >/dev/null 2>&1
    else
        # The active device is UNMUTED. Turn the hardware LED OFF.
        amixer -c 0 set Master unmute >/dev/null 2>&1
        amixer -c 1 set Master unmute >/dev/null 2>&1
    fi
}

# Run once on startup to sync the initial state
sync_led

# Listen for background audio events (like connecting BT or pressing the mute key)
pactl subscribe | grep --line-buffered -E "Event 'change' on server|Event 'change' on sink" | while read -r line; do
    sync_led
done
