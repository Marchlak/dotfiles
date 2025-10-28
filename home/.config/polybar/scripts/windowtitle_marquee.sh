#!/usr/bin/env bash
w=30
d=0.2
while getopts "w:d:" o; do
  case "$o" in
    w) w="$OPTARG" ;;
    d) d="$OPTARG" ;;
  esac
done
pad="   "
get_title() {
  t="$(xdotool getactivewindow getwindowname 2>/dev/null)"
  if [ -z "$t" ]; then
    wid=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk -F'# ' '{print $2}')
    [ -n "$wid" ] && t=$(xprop -id "$wid" _NET_WM_NAME 2>/dev/null | sed -n 's/_NET_WM_NAME(UTF8_STRING) = "\(.*\)"/\1/p')
  fi
  echo "$t"
}
prev=""
base=""
msg=""
i=0
while :; do
  txt="$(get_title)"
  [ -z "$txt" ] && txt=""
  if [ "$txt" != "$prev" ]; then
    base="$txt$pad"
    msg="$base$base"
    i=0
    prev="$txt"
  fi
  if [ -z "$txt" ] || [ ${#txt} -le $w ]; then
    echo "$txt"
    sleep 1
    continue
  fi
  new="$(get_title)"
  if [ "$new" != "$txt" ]; then
    prev=""
    continue
  fi
  len=${#msg}
  [ $((i + w)) -le $len ] || msg="$msg$base"
  echo "${msg:i:w}"
  i=$((i+1))
  sleep "$d"
done
