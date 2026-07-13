bb() {
    ~/.config/bash/scripts/bluetooth_ctl.sh "$@"
}

_bb_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "-s -c -d -r -l --scan --connect --disconnect --remove --list" -- "$cur"))
        return
    fi

    if [[ "$prev" == "-c" || "$prev" == "-d" || "$prev" == "-r" || \
          "$prev" == "--connect" || "$prev" == "--disconnect" || "$prev" == "--remove" ]]; then
        local IFS=$'\n'
        while IFS= read -r name; do
            COMPREPLY+=("$name")
        done < <(cat "$HOME/.btctl_devices" 2>/dev/null | cut -d' ' -f2- | sort -u | grep -i "^$cur")
        return
    fi
}

complete -o filenames -F _btctl_complete btctl

