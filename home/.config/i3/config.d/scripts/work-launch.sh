#!/usr/bin/env bash
set -euo pipefail

i3-msg 'workspace number 1; exec --no-startup-id ghostty' >/dev/null
i3-msg 'workspace number 2; exec --no-startup-id brave-browser' >/dev/null
i3-msg 'workspace number 3; exec --no-startup-id gtk-launch obsidian.desktop' >/dev/null
i3-msg 'workspace number 4; exec --no-startup-id ticktick --no-sandbox --password-store=basic --user-data-dir=$HOME/.ticktick-profile' >/dev/null
i3-msg 'workspace number 5; exec --no-startup-id spotify' >/dev/null
i3-msg 'workspace number 6; exec --no-startup-id ~/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin/idea.sh' >/dev/null
i3-msg 'workspace number 7; exec --no-startup-id gtk-launch pgadmin4.desktop' >/dev/null
i3-msg 'workspace number 10; exec --no-startup-id slack' >/dev/null

sleep 3

i3-msg '[class="(?i)ghostty"] move container to workspace number 1' >/dev/null
i3-msg '[class="(?i)brave-browser|brave"] move container to workspace number 2' >/dev/null
i3-msg '[class="(?i)obsidian"] move container to workspace number 3' >/dev/null
i3-msg '[class="(?i)ticktick"] move container to workspace number 4' >/dev/null
i3-msg '[class="(?i)spotify"] move container to workspace number 5' >/dev/null
i3-msg '[class="(?i)jetbrains-idea|intellij idea"] move container to workspace number 6' >/dev/null
i3-msg '[class="(?i)slack"] move container to workspace number 10' >/dev/null
