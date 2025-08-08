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
while :; do
  txt="$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)"
  [ -z "$txt" ] && txt="paused"
  base="$txt$pad"
  if [ ${#txt} -le $w ]; then
    echo "$txt"
    sleep 1
    continue
  fi
  msg="$base$base"
  i=0
  while :; do
    new="$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)"
    if [ "$new" != "$txt" ] || [ -z "$new" ]; then
      break
    fi
    len=${#msg}
    [ $((i + w)) -le $len ] || msg="$msg$base"
    echo "${msg:i:w}"
    i=$((i+1))
    sleep "$d"
  done
done
