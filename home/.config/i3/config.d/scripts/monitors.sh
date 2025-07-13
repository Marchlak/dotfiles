#!/usr/bin/env bash
lap=eDP-1-2
ext=$(xrandr --query | awk '$2=="connected" && $1!="'$lap'" {print $1; exit}')
[[ -z $ext ]] && exit 0
cfg=$HOME/.config/i3/config
cur=$(grep '^set \$disp2 ' "$cfg" | awk '{print $3}')
[[ $ext == $cur ]] && exit 0
sed -i "s|^set \$disp2 .*|set \$disp2 $ext|" "$cfg"
i3-msg restart
