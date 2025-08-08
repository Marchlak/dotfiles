#!/usr/bin/env bash
THEME="$HOME/.config/i3/rofi/dark1.rasi"
device=$(nmcli device status | awk '/wifi/ {print $1; exit}')
mapfile -t SSIDS < <(nmcli -t -f SSID dev wifi list ifname "$device" | sed '/^$/d' | sort -u)
ssid=$(printf '%s\n' "${SSIDS[@]}" | rofi -dmenu -i -p "WiFi" -theme "$THEME")
if [ -n "$ssid" ]; then
  sec=$(nmcli -t -f SSID,SECURITY dev wifi list ifname "$device" | grep "^$ssid:" | cut -d: -f2)
  if [[ "$sec" == *"802-1x"* || "$sec" == *"EAP"* ]]; then
    identity=$(printf "" | rofi -dmenu -p "Username for $ssid" -theme "$THEME")
    pass=$(printf "" | rofi -dmenu -password -p "Password for $ssid" -theme "$THEME")
    nmcli connection add type wifi con-name "$ssid" ifname "$device" ssid "$ssid" wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity "$identity" 802-1x.password "$pass" 802-1x.system-ca-certs yes
    nmcli connection up "$ssid"
  elif [ "$sec" != "--" ]; then
    pass=$(printf "" | rofi -dmenu -password -p "Password for $ssid" -theme "$THEME")
    nmcli dev wifi connect "$ssid" password "$pass" ifname "$device"
  else
    nmcli dev wifi connect "$ssid" ifname "$device"
  fi
fi
