#!/usr/bin/env bash
set -u

state="${XDG_CACHE_HOME:-$HOME/.cache}/bluefilter.enabled"

get_temp() {
  LC_ALL=C LANG=C redshift -p 2>/dev/null | awk -F'[: ]+' '/Color temperature/ {gsub(/K/,"",$NF); print $NF}'
}

temp="$(get_temp || true)"

if [ -n "${temp:-}" ] && [ "$temp" -lt 6500 ]; then
  redshift -x && rm -f "$state" && notify-send "Night filter" "Wyłączono"
elif [ -z "${temp:-}" ] && [ -f "$state" ]; then
  redshift -x && rm -f "$state" && notify-send "Night filter" "Wyłączono"
else
  redshift -O 3800 && mkdir -p "$(dirname "$state")" && echo on > "$state" && notify-send "Night filter" "Włączono 3800K"
fi
