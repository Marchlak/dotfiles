#!/usr/bin/env bash
THEME="$HOME/.config/i3/rofi/dark1.rasi"

device=$(nmcli device status | awk '/wifi/ {print $1; exit}')
current_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print $2; exit}')
mapfile -t WIFI_LIST < <(nmcli -t -f SSID,SIGNAL dev wifi list ifname "$device" | sed '/^:/d;/^$/d' | awk -F: '!seen[$1]++')

get_icon() {
    local signal=$1
    if   [ "$signal" -ge 75 ]; then echo "󰤨"
    elif [ "$signal" -ge 50 ]; then echo "󰤥"
    elif [ "$signal" -ge 25 ]; then echo "󰤢"
    elif [ "$signal" -ge 1  ]; then echo "󰤟"
    else echo "󰤯"
    fi
}

menu_list=""
for entry in "${WIFI_LIST[@]}"; do
    ssid=$(echo "$entry" | cut -d: -f1)
    signal=$(echo "$entry" | cut -d: -f2)
    [ -z "$ssid" ] && continue
    icon=$(get_icon "$signal")
    if [ "$ssid" = "$current_ssid" ]; then
        menu_list+="$icon  $ssid (connected)\n"
    else
        menu_list+="$icon  $ssid\n"
    fi
done

chosen=$(printf "%b" "$menu_list" | rofi -dmenu -i -p "WiFi" -theme "$THEME" | sed 's/^[^ ]\+[ ]\+//' | sed 's/ (connected)$//')

if [ -n "$chosen" ]; then
  sec=$(nmcli -t -f SSID,SECURITY dev wifi list ifname "$device" | grep "^$chosen:" | cut -d: -f2)
  if [[ "$sec" == *"802-1x"* || "$sec" == *"EAP"* ]]; then
    identity=$(printf "" | rofi -dmenu -p "Username for $chosen" -theme "$THEME")
    pass=$(printf "" | rofi -dmenu -password -p "Password for $chosen" -theme "$THEME")
    nmcli connection add type wifi con-name "$chosen" ifname "$device" ssid "$chosen" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity "$identity" 802-1x.password "$pass" 802-1x.system-ca-certs yes
    nmcli connection up "$chosen"
  elif [ "$sec" != "--" ]; then
    pass=$(printf "" | rofi -dmenu -password -p "Password for $chosen" -theme "$THEME")
    nmcli dev wifi connect "$chosen" password "$pass" ifname "$device"
  else
    nmcli dev wifi connect "$chosen" ifname "$device"
  fi
fi
