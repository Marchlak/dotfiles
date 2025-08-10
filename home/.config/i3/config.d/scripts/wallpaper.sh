#!/usr/bin/env bash
set -euo pipefail

W1="$HOME/Pictures/wallpapers/Tower-Night.png"
W2="$HOME/Pictures/wallpapers/Tower-Night.png"

for _ in {1..20}; do
  ready=$(xrandr --query | awk '/ connected/{c++} END{print c+0}')
  [[ ${ready:-0} -ge 1 ]] && break
  sleep 0.3
done

for _ in {1..20}; do
  layout=$(xrandr --listmonitors 2>/dev/null | awk 'NR>1{print $0}' | wc -l)
  [[ ${layout:-0} -ge 1 ]] && break
  sleep 0.3
done

mons=$(xrandr --listmonitors 2>/dev/null | awk 'NR>1{print $0}' | wc -l)
if [[ ${mons:-1} -ge 2 ]]; then
  feh --no-fehbg --bg-fill "$W1" "$W2"
else
  feh --no-fehbg --bg-fill "$W1"
fi
