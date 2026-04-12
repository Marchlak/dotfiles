#!/usr/bin/env bash
set -euo pipefail

for cmd in xclip xdotool; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        notify-send "Type clipboard" "Brakuje polecenia: $cmd"
        exit 1
    fi
done

sleep 0.15
text="$(xclip -selection clipboard -o 2>/dev/null || true)"
[ -n "$text" ] || exit 0

xdotool type --clearmodifiers --delay 8 -- "$text"
