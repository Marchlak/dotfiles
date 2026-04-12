#!/usr/bin/env bash
set -euo pipefail

i3-msg 'workspace number 1; exec --no-startup-id ghostty' >/dev/null
i3-msg 'workspace number 2; exec --no-startup-id brave-browser' >/dev/null
i3-msg 'workspace number 11; exec --no-startup-id bash -lc '\''vlc'\''' >/dev/null
i3-msg 'workspace number 12; exec --no-startup-id ticktick --no-sandbox --password-store=basic --user-data-dir=$HOME/.ticktick-profile' >/dev/null
i3-msg 'workspace number 13; exec --no-startup-id obsidian' >/dev/null
i3-msg 'workspace number 5; exec --no-startup-id spotify' >/dev/null

sleep 3

i3-msg '[class="(?i)ghostty"] move container to workspace number 1' >/dev/null
i3-msg '[class="(?i)brave-browser|brave"] move container to workspace number 2' >/dev/null
i3-msg '[class="(?i)vlc"] move container to workspace number 11' >/dev/null
i3-msg '[class="(?i)ticktick"] move container to workspace number 12' >/dev/null
i3-msg '[class="(?i)obsidian"] move container to workspace number 13' >/dev/null
i3-msg '[class="(?i)spotify"] move container to workspace number 5' >/dev/null
