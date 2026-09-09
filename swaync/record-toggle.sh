#!/bin/sh

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    swaync-client --reload-config
    exit 0
fi

mkdir -p "$HOME/Videos"
filename="$HOME/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4"

case "$1" in
    full)
        monitor="$(hyprctl -j monitors | jq -r '.[] | select(.focused == true) | .name')"
        [ -n "$monitor" ] || exit 1
        wf-recorder -o "$monitor" -f "$filename" &
        ;;
    area)
        geometry="$(slurp)" || exit 0
        wf-recorder -g "$geometry" -f "$filename" &
        ;;
esac

swaync-client --reload-config
