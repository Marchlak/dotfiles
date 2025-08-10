#!/usr/bin/env bash
set -euo pipefail

i3-msg 'workspace number 1; exec --no-startup-id ghostty' >/dev/null
i3-msg 'workspace number 2; exec --no-startup-id brave-browser' >/dev/null
i3-msg 'workspace number 4; exec --no-startup-id obsidian' >/dev/null
i3-msg 'workspace number 5; exec --no-startup-id spotify' >/dev/null

sleep 3

i3-msg '[class="(?i)ghostty"] move container to workspace number 1' >/dev/null
i3-msg '[class="(?i)brave-browser|brave"] move container to workspace number 2' >/dev/null
i3-msg '[class="(?i)obsidian"] move container to workspace number 4' >/dev/null
i3-msg '[class="(?i)spotify"] move container to workspace number 5' >/dev/null
