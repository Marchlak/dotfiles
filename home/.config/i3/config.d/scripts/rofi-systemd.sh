#!/usr/bin/env bash
set -euo pipefail
THEME="$HOME/.config/i3/rofi/dark1.rasi"
SCOPE="${1:-user}"
if [ "$SCOPE" = "user" ]; then
  LIST=$(systemctl --user list-units --type=service --all --no-legend | awk '{print $1" "$3}')
else
  LIST=$(systemctl list-units --type=service --all --no-legend | awk '{print $1" "$3}')
fi
[ -z "$LIST" ] && exit 0
SEL=$(printf '%s\n' "$LIST" | awk '{printf "● %-50s %s\n",$1,$2}' | rofi -dmenu -i -p "systemd:$SCOPE" -theme "$THEME")
UNIT=$(printf '%s' "$SEL" | awk '{print $2}')
[ -z "$UNIT" ] && exit 0
STATE=$(printf '%s' "$SEL" | awk '{print $3}')
ACTIONS="start\nstop\nrestart\nenable\ndisable\nstatus\nlogs"
ACT=$(printf '%b' "$ACTIONS" | rofi -dmenu -i -p "$UNIT" -theme "$THEME")
[ -z "$ACT" ] && exit 0
if [ "$SCOPE" = "user" ]; then
  case "$ACT" in
    start) systemctl --user start "$UNIT" ;;
    stop) systemctl --user stop "$UNIT" ;;
    restart) systemctl --user restart "$UNIT" ;;
    enable) systemctl --user enable --now "$UNIT" ;;
    disable) systemctl --user disable --now "$UNIT" ;;
    status) systemctl --user status "$UNIT" | rofi -dmenu -p "status" -theme "$THEME" ;;
    logs) journalctl --user -u "$UNIT" -n 200 --no-pager | rofi -dmenu -p "logs" -theme "$THEME" ;;
  esac
else
  case "$ACT" in
    start) pkexec systemctl start "$UNIT" ;;
    stop) pkexec systemctl stop "$UNIT" ;;
    restart) pkexec systemctl restart "$UNIT" ;;
    enable) pkexec systemctl enable --now "$UNIT" ;;
    disable) pkexec systemctl disable --now "$UNIT" ;;
    status) systemctl status "$UNIT" | rofi -dmenu -p "status" -theme "$THEME" ;;
    logs) journalctl -u "$UNIT" -n 200 --no-pager | rofi -dmenu -p "logs" -theme "$THEME" ;;
  esac
fi
