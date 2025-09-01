#!/usr/bin/env bash
set -euo pipefail

BLUR=12
TMPBG=/tmp/i3lock-bg.png

maim "$TMPBG"
convert "$TMPBG" -blur 0x$BLUR "$TMPBG"

i3lock \
  --image="$TMPBG" \
  --indicator \
  --clock \
  --radius=110 \
  --ring-width=10 \
  --inside-color=00000000 \
  --ring-color=cba6f7cc \
  --keyhl-color=94e2d5cc \
  --bshl-color=f38ba8cc \
  --separator-color=00000000 \
  --insidever-color=00000000 \
  --insidewrong-color=00000000 \
  --ringver-color=74c7eccc \
  --ringwrong-color=f38ba8cc \
  --line-uses-inside \
  --time-font="MesloLGS Nerd Font Mono Bold" \
  --date-font="MesloLGS Nerd Font Mono Bold" \
  --verif-font="MesloLGS Nerd Font Mono Bold" \
  --wrong-font="MesloLGS Nerd Font Mono Bold" \
  --time-size=28 \
  --date-size=18
