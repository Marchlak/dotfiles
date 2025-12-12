#!/usr/bin/env bash
set -euo pipefail

cfg="$HOME/.config/i3/config"

mapfile -t mons < <(xrandr --query | awk '$2=="connected"{print $1}')
((${#mons[@]}==0)) && exit 0

lap=""
hdmi=""
dp=""

for m in "${mons[@]}"; do
  if [[ -z "$lap" && "$m" =~ ^(eDP|LVDS) ]]; then
    lap="$m"
  elif [[ -z "$hdmi" && "$m" =~ ^HDMI ]]; then
    hdmi="$m"
  elif [[ -z "$dp" && "$m" =~ ^DP ]]; then
    dp="$m"
  fi
done

primary="${lap:-${mons[0]}}"
new1="$primary"
new2="${hdmi:-$primary}"
new3="${dp:-$primary}"

if [[ -n "$lap" ]]; then
  if [[ -n "$dp" && -n "$hdmi" ]]; then
    xrandr --output "$lap" --primary --auto --output "$dp" --auto --left-of "$lap" --output "$hdmi" --auto --right-of "$lap"
  elif [[ -n "$hdmi" ]]; then
    xrandr --output "$lap" --primary --auto --output "$hdmi" --auto --right-of "$lap"
  elif [[ -n "$dp" ]]; then
    xrandr --output "$lap" --primary --auto --output "$dp" --auto --left-of "$lap"
  else
    xrandr --output "$lap" --primary --auto
  fi
else
  xrandr --output "$primary" --primary --auto
  if [[ -n "$dp" && "$dp" != "$primary" ]]; then
    xrandr --output "$dp" --auto --right-of "$primary"
  fi
  if [[ -n "$hdmi" && "$hdmi" != "$primary" ]]; then
    xrandr --output "$hdmi" --auto --right-of "$primary"
  fi
fi

cur1=$(grep '^set \$disp1 ' "$cfg" | awk '{print $3}' || true)
cur2=$(grep '^set \$disp2 ' "$cfg" | awk '{print $3}' || true)
cur3=$(grep '^set \$disp3 ' "$cfg" | awk '{print $3}' || true)

need=0

if [[ "${cur1:-}" != "$new1" ]]; then
  if grep -q '^set \$disp1 ' "$cfg"; then
    sed -i "s|^set \$disp1 .*|set \$disp1 $new1|" "$cfg"
  else
    printf '\nset $disp1 %s\n' "$new1" >>"$cfg"
  fi
  need=1
fi

if [[ "${cur2:-}" != "$new2" ]]; then
  if grep -q '^set \$disp2 ' "$cfg"; then
    sed -i "s|^set \$disp2 .*|set \$disp2 $new2|" "$cfg"
  else
    printf '\nset $disp2 %s\n' "$new2" >>"$cfg"
  fi
  need=1
fi

if [[ "${cur3:-}" != "$new3" ]]; then
  if grep -q '^set \$disp3 ' "$cfg"; then
    sed -i "s|^set \$disp3 .*|set \$disp3 $new3|" "$cfg"
  else
    printf '\nset $disp3 %s\n' "$new3" >>"$cfg"
  fi
  need=1
fi

if ((need==1)); then
  i3-msg restart
fi
