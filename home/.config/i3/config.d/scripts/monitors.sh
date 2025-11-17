#!/usr/bin/env bash
set -euo pipefail

lap=eDP-1-2
cfg="$HOME/.config/i3/config"

mapfile -t mons < <(xrandr --query | awk '$2=="connected"{print $1}')
((${#mons[@]}==0)) && exit 0

have_lap=0
exts=()
for m in "${mons[@]}"; do
  if [[ "$m" == "$lap" ]]; then
    have_lap=1
  else
    exts+=("$m")
  fi
done

if ((${#exts[@]}>=2)); then
  dp_idx=-1
  for i in "${!exts[@]}"; do
    if [[ "${exts[$i]}" == DP-* ]]; then
      dp_idx=$i
      break
    fi
  done
  if ((dp_idx>0)); then
    tmp="${exts[0]}"
    exts[0]="${exts[$dp_idx]}"
    exts[$dp_idx]="$tmp"
  fi
fi

if ((have_lap==1)); then
  new1="$lap"
else
  new1="${mons[0]}"
fi

if ((${#exts[@]}>=1)); then
  new2="${exts[0]}"
else
  new2="$new1"
fi

if ((${#exts[@]}>=2)); then
  new3="${exts[1]}"
else
  new3="$new2"
fi

case ${#mons[@]} in
  1)
    xrandr --output "${mons[0]}" --primary --auto
    ;;
  2)
    if ((have_lap==1)); then
      other="${exts[0]}"
      xrandr --output "$new1" --primary --auto --output "$other" --auto --right-of "$new1"
    else
      xrandr --output "${mons[0]}" --primary --auto --output "${mons[1]}" --auto --right-of "${mons[0]}"
    fi
    ;;
  *)
    if ((have_lap==1)) && ((${#exts[@]}>=2)); then
      xrandr --output "$new2" --auto --left-of "$new1" --output "$new1" --primary --auto --output "$new3" --auto --right-of "$new1"
    else
      xrandr --output "${mons[0]}" --primary --auto --output "${mons[1]}" --auto --right-of "${mons[0]}" --output "${mons[2]}" --auto --right-of "${mons[1]}"
    fi
    ;;
esac

cur1=$(grep '^set \$disp1 ' "$cfg" | awk '{print $3}' || echo "")
cur2=$(grep '^set \$disp2 ' "$cfg" | awk '{print $3}' || echo "")
cur3=$(grep '^set \$disp3 ' "$cfg" | awk '{print $3}' || echo "")

need=0

if [[ "$cur1" != "$new1" ]]; then
  if grep -q '^set \$disp1 ' "$cfg"; then
    sed -i "s|^set \$disp1 .*|set \$disp1 $new1|" "$cfg"
  else
    printf '\nset $disp1 %s\n' "$new1" >>"$cfg"
  fi
  need=1
fi

if [[ "$cur2" != "$new2" ]]; then
  if grep -q '^set \$disp2 ' "$cfg"; then
    sed -i "s|^set \$disp2 .*|set \$disp2 $new2|" "$cfg"
  else
    printf '\nset $disp2 %s\n' "$new2" >>"$cfg"
  fi
  need=1
fi

if [[ "$cur3" != "$new3" ]]; then
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
