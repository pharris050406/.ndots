#!/usr/bin/env bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
GREY='\033[0;90m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

# Local device database
BTCTL_DB="$HOME/.btctl_devices"

# Associative arrays to track devices and their RSSI
declare -A seen_devices
declare -A device_rssi

trap 'tput clear; prompt_after_scan; exit 0' INT

# ── Device database ───────────────────────────────────────────────────────────

db_save() {
    local mac=$1
    local name=$2
    touch "$BTCTL_DB"
    if ! grep -q "^$mac " "$BTCTL_DB" 2>/dev/null; then
        echo "$mac $name" >> "$BTCTL_DB"
    fi
}

db_remove() {
    local mac=$1
    sed -i "/^$mac /d" "$BTCTL_DB"
}

db_get_name() {
    local mac=$1
    grep "^$mac " "$BTCTL_DB" 2>/dev/null | sed "s/^$mac //"
}

db_find() {
    local search=$1
    grep -i "$search" "$BTCTL_DB" 2>/dev/null
}

# ── Helpers ──────────────────────────────────────────────────────────────────

prompt_after_scan() {
    echo "" > /dev/tty

    local macs=()
    local names=()
    for mac in "${!seen_devices[@]}"; do
        local name="${seen_devices[$mac]}"
        if ! [[ "$name" =~ ^[0-9A-Fa-f]{2}[-:] ]]; then
            macs+=("$mac")
            names+=("$name")
        fi
    done

    if [ ${#macs[@]} -eq 0 ]; then
        printf "${YELLOW}No named devices found.${RESET}\n" > /dev/tty
        return
    fi

    printf "${CYAN}Devices found:${RESET}\n" > /dev/tty
    for i in "${!macs[@]}"; do
        printf "${CYAN}  %d) ${GREEN}%-30s${GREY}%s${RESET}\n" "$((i+1))" "${names[$i]}" "${macs[$i]}" > /dev/tty
    done

    printf "\n${CYAN}Connect to a device? [1-%d, or Enter to skip]:${RESET} " "${#macs[@]}" > /dev/tty
    read -r choice < /dev/tty

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#macs[@]}" ]; then
        local mac="${macs[$((choice-1))]}"
        local name="${names[$((choice-1))]}"

        while true; do
            printf "\n${CYAN}Connect to ${GREEN}%s${CYAN} (%s)? [y/n]:${RESET} " "$name" "$mac" > /dev/tty
            read -r confirm < /dev/tty
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                break
            elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
                prompt_after_scan
                return
            fi
        done

        local paired=$(bluetoothctl info "$mac" | grep "Paired:" | awk '{print $2}')
        if [[ "$paired" != "yes" ]]; then
            printf "${CYAN}Pairing...${RESET}\n" > /dev/tty
            bluetoothctl pair "$mac" > /dev/tty
            bluetoothctl trust "$mac" > /dev/tty
        fi
        printf "${CYAN}Connecting...${RESET}\n" > /dev/tty
        bluetoothctl connect "$mac" > /dev/tty
        db_save "$mac" "$name"
    fi
}

clear_cache() {
    bluetoothctl devices | while read -r _ mac name; do
        local paired=$(bluetoothctl info "$mac" | grep "Paired:" | awk '{print $2}')
        if [[ "$paired" != "yes" ]]; then
            bluetoothctl remove "$mac" > /dev/null
        fi
    done
}

usage() {
    printf "${CYAN}btctl${RESET} - bluetooth control\n\n"
    printf "Usage:\n"
    printf "  btctl -s [duration] [name]   scan for devices\n"
    printf "  btctl -c <name>              connect to a device\n"
    printf "  btctl -d <name>              disconnect from a device\n"
    printf "  btctl -r <name>              remove/unpair a device\n"
    printf "  btctl -l                     list paired devices\n\n"
    printf "Examples:\n"
    printf "  btctl -s\n"
    printf "  btctl -s 10\n"
    printf "  btctl -s earbuds\n"
    printf "  btctl -s 10 earbuds\n"
    printf "  btctl -c earbuds\n"
    printf "  btctl -d earbuds\n"
    printf "  btctl -r earbuds\n"
}

# Find MAC by name — checks local db first, then bluetoothctl
find_mac() {
    local search=$1

    local db_matches=$(db_find "$search")
    local bt_matches=$(bluetoothctl devices Paired | grep -i "$search")

    declare -A merged
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local mac=$(echo "$line" | awk '{print $1}')
        local name=$(echo "$line" | cut -d' ' -f2-)
        merged["$mac"]="$name"
    done <<< "$db_matches"
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local mac=$(echo "$line" | awk '{print $2}')
        local name=$(echo "$line" | cut -d' ' -f3-)
        merged["$mac"]="$name"
    done <<< "$bt_matches"

    local count=${#merged[@]}

    if [ "$count" -eq 0 ]; then
        echo ""
        return
    elif [ "$count" -eq 1 ]; then
        echo "${!merged[@]}"
        return
    fi

    printf "${CYAN}Multiple devices found:${RESET}\n" > /dev/tty
    local i=1
    local mac_list=()
    for mac in "${!merged[@]}"; do
        local name="${merged[$mac]}"
        printf "${CYAN}  %d) ${GREEN}%-30s${GREY}%s${RESET}\n" "$i" "$name" "$mac" > /dev/tty
        mac_list+=("$mac")
        i=$((i+1))
    done

    printf "${CYAN}Select device [1-%d]:${RESET} " "$count" > /dev/tty
    read -r choice < /dev/tty
    echo "${mac_list[$((choice-1))]}"
}

# ── Scan mode ─────────────────────────────────────────────────────────────────

print_countdown() {
    local seconds=$1
    local cols=$(tput cols)
    local rows=$(tput lines)
    local msg
    if [ -z "$DURATION" ]; then
        msg="Scanning... (Ctrl+C to stop)"
    else
        msg=$(printf "Scanning... %2ds left" "$seconds")
    fi
    tput sc > /dev/tty
    tput cup $((rows-1)) $((cols-${#msg})) > /dev/tty
    printf "%s" "$msg" > /dev/tty
    tput rc > /dev/tty
}

scan_with_countdown() {
    echo "scan on"
    if [ -z "$DURATION" ]; then
        while true; do
            print_countdown
            sleep 1
        done
    else
        for ((i=DURATION; i>0; i--)); do
            print_countdown $i
            sleep 1
        done
        echo "devices"
        echo "quit"
    fi
}

parse_devices() {
    while IFS= read -r line; do
        clean=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        if [[ "$clean" =~ \[NEW\]\ Device\ ([0-9A-Fa-f:]+)\ (.+) ]]; then
            local mac="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            if [ -z "$DEVICE" ] || echo "$name" | grep -qi "$DEVICE"; then
                if [[ -z "${seen_devices[$mac]}" ]]; then
                    seen_devices[$mac]="$name"
                    if [[ "$name" =~ ^[0-9A-Fa-f]{2}[-:] ]]; then
                        printf "${GREY}%s  %s${RESET}\n" "$mac" "$name" > /dev/tty
                    else
                        printf "${GREEN}%s  %s${RESET}\n" "$mac" "$name" > /dev/tty
                    fi
                fi
            fi
        fi
        if [[ "$clean" =~ \[CHG\]\ Device\ ([0-9A-Fa-f:]+)\ RSSI:\ 0x[0-9a-f]+\ \((-?[0-9]+)\) ]]; then
            local mac="${BASH_REMATCH[1]}"
            local rssi="${BASH_REMATCH[2]}"
            device_rssi[$mac]="$rssi"
        fi
    done
}

do_scan() {
    clear_cache
    tput clear
    if [ -n "$DEVICE" ]; then
        printf "${CYAN}Looking for: ${GREEN}${DEVICE}${RESET}\n\n" > /dev/tty
    fi
    parse_devices < <(scan_with_countdown | bluetoothctl)
    tput cup $(tput lines) 0
    echo ""
}

# ── Connect ───────────────────────────────────────────────────────────────────

do_connect() {
    local search=$1
    local mac=$(find_mac "$search")
    if [ -z "$mac" ]; then
        printf "${RED}No device found matching: %s${RESET}\n" "$search"
        exit 1
    fi
    local name=$(db_get_name "$mac")
    [ -z "$name" ] && name=$(bluetoothctl devices Paired | grep -i "$mac" | sed 's/Device [^ ]* //')
    printf "${CYAN}Connecting to ${GREEN}%s${CYAN} (%s)...${RESET}\n" "$name" "$mac"
    local paired=$(bluetoothctl info "$mac" | grep "Paired:" | awk '{print $2}')
    if [[ "$paired" != "yes" ]]; then
        printf "${CYAN}Pairing...${RESET}\n"
        bluetoothctl pair "$mac"
        bluetoothctl trust "$mac"
    fi
    bluetoothctl connect "$mac"
}

# ── Disconnect ────────────────────────────────────────────────────────────────

do_disconnect() {
    local search=$1
    local mac=$(find_mac "$search")
    if [ -z "$mac" ]; then
        printf "${RED}No device found matching: %s${RESET}\n" "$search"
        exit 1
    fi
    local name=$(db_get_name "$mac")
    [ -z "$name" ] && name=$(bluetoothctl devices Paired | grep -i "$mac" | sed 's/Device [^ ]* //')
    printf "${CYAN}Disconnecting from ${GREEN}%s${CYAN} (%s)...${RESET}\n" "$name" "$mac"
    db_save "$mac" "$name"
    echo -e "disconnect $mac\nquit" | bluetoothctl
}

# ── Remove ────────────────────────────────────────────────────────────────────

do_remove() {
    local search=$1
    local mac=$(find_mac "$search")
    if [ -z "$mac" ]; then
        printf "${RED}No device found matching: %s${RESET}\n" "$search"
        exit 1
    fi
    local name=$(db_get_name "$mac")
    [ -z "$name" ] && name=$(bluetoothctl devices Paired | grep -i "$mac" | sed 's/Device [^ ]* //')
    printf "${CYAN}Removing ${GREEN}%s${CYAN} (%s)...${RESET}\n" "$name" "$mac"
    bluetoothctl remove "$mac"
    db_remove "$mac"
}

# ── List ──────────────────────────────────────────────────────────────────────

do_list() {
    printf "${CYAN}Paired devices:${RESET}\n"

    declare -A all

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local mac=$(echo "$line" | awk '{print $1}')
        local name=$(echo "$line" | cut -d' ' -f2-)
        all["$mac"]="$name"
    done < <(cat "$BTCTL_DB" 2>/dev/null)

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local mac=$(echo "$line" | awk '{print $2}')
        local name=$(echo "$line" | cut -d' ' -f3-)
        all["$mac"]="$name"
    done < <(bluetoothctl devices Paired)

for mac in "${!all[@]}"; do
        local name="${all[$mac]}"
        local info=$(bluetoothctl info "$mac")
        local connected=$(echo "$info" | grep "Connected:" | awk '{print $2}')
        local battery=$(echo "$info" | grep "Battery Percentage:" | grep -oP '\(\K[0-9]+(?=\))')
        
        local battery_str=""
        [[ -n "$battery" ]] && battery_str="  ${YELLOW}Battery: ${battery}%${RESET}"
        
        if [[ "$connected" == "yes" ]]; then
            printf "${GREEN}%s  %s  (connected)%b${RESET}\n" "$mac" "$name" "$battery_str"
        else
            printf "${GREY}%s  %s%b${RESET}\n" "$mac" "$name" "$battery_str"
        fi
    done
}
# ── Argument parsing ──────────────────────────────────────────────────────────

MODE=$1
shift

case "$MODE" in
    -s|--scan)
        DURATION=""
        DEVICE=""
        for arg in "$@"; do
            if [[ "$arg" =~ ^[0-9]+$ ]]; then
                DURATION=$arg
            else
                DEVICE=$arg
            fi
        done
        do_scan
        ;;
    -c|--connect)
        do_connect "$1"
        ;;
    -d|--disconnect)
        do_disconnect "$1"
        ;;
    -r|--remove)
        do_remove "$1"
        ;;
    -l|--list)
        do_list
        ;;
    *)
        usage
        ;;
esac
