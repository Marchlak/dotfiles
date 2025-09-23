#!/usr/bin/env bash
set -euo pipefail

step="${1:-}"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/redshift-step"
state="$cache/temp"
mkdir -p "$cache"

notify() {
  notify-send -h string:x-dunst-stack-tag:redshift "Redshift" "$2" -i "$1"
}

read_cur() {
  if [[ -f "$state" ]]; then
    cur=$(cat "$state")
  else
    cur=""
    if command -v timeout >/dev/null 2>&1 && command -v redshift >/dev/null 2>&1; then
      cur=$(timeout 0.3s redshift -p 2>/dev/null | grep -oE '[0-9]+K' | tr -d K || true)
    fi
  fi
  cur="${cur//[^0-9]/}"
  [[ -z "$cur" ]] && cur=6500
  echo "$cur"
}

set_temp() {
  local t="$1"
  if command -v sct >/dev/null 2>&1; then
    if sct "$t"; then
      echo "$t" > "$state"
      notify weather-clear "Temperatura ${t}K"
      exit 0
    else
      notify dialog-error "Błąd ustawiania (${t}K)"
      exit 1
    fi
  fi
  if command -v redshift >/dev/null 2>&1; then
    if redshift -m randr -P -O "${t}K"; then
      echo "$t" > "$state"
      notify weather-clear "Temperatura ${t}K"
      exit 0
    else
      notify dialog-error "Błąd ustawiania (${t}K)"
      exit 1
    fi
  fi
  notify dialog-error "Brak sct/redshift"
  exit 1
}

case "$step" in
  inc)
    cur=$(read_cur)
    new=$((cur+400))
    (( new > 10000 )) && new=10000
    set_temp "$new"
    ;;
  dec)
    cur=$(read_cur)
    new=$((cur-400))
    (( new < 1000 )) && new=1000
    set_temp "$new"
    ;;
  reset)
    if command -v redshift >/dev/null 2>&1; then
      if redshift -m randr -x; then
        rm -f "$state"
        notify view-refresh "Reset"
        exit 0
      else
        notify dialog-error "Błąd resetu"
        exit 1
      fi
    elif command -v sct >/dev/null 2>&1; then
      if sct 6500; then
        rm -f "$state"
        notify view-refresh "Reset"
        exit 0
      else
        notify dialog-error "Błąd resetu"
        exit 1
      fi
    else
      notify dialog-error "Brak sct/redshift"
      exit 1
    fi
    ;;
  *)
    notify dialog-error "Użycie: $0 inc|dec|reset"
    exit 1
    ;;
esac
