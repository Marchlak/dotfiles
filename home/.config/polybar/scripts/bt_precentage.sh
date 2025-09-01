#!/usr/bin/env bash

powered=$(bluetoothctl show | awk '/Powered:/ {print $2}')
if [ "$powered" != "yes" ]; then
  echo "BT off"
  exit 0
fi

adapter=$(busctl --system tree org.bluez | awk -F'/' '/\/hci[0-9]+$/ {print $NF; exit}')
[ -z "$adapter" ] && adapter="hci0"

list=$(bluetoothctl devices Connected | sed 's/^Device //')
[ -z "$list" ] && { echo "BT --"; exit 0; }

out=()
while read -r mac name_rest; do
  [ -z "$mac" ] && continue
  name=$(echo "$name_rest")
  path="/org/bluez/${adapter}/dev_${mac//:/_}"
  pct=$(busctl --system get-property org.bluez "$path" org.bluez.Battery1 Percentage 2>/dev/null | awk '{print $2}')
  if [ -n "$pct" ]; then
    out+=("$name (${pct}%)")
  else
    out+=("$name")
  fi
done <<< "$list"

printf "%s\n" "$(IFS=", "; echo "${out[*]}")"
