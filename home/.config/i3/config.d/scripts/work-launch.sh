#!/usr/bin/env bash
set -euo pipefail

LOG="/tmp/ghostty-launch.$(date +%s).log"
log(){ printf '%s %s\n' "$(date +'%F %T')" "$*" >>"$LOG"; }

ghostty_ids(){ i3-msg -t get_tree | jq -r 'recurse(.nodes[]?, .floating_nodes[]?) | select(.window? != null) | select(.window_properties?.class? | ascii_downcase | test("ghostty")) | .id'; }
ghostty_info(){ i3-msg -t get_tree | jq -c 'recurse(.nodes[]?, .floating_nodes[]?) | select(.window? != null) | select(.window_properties?.class? | ascii_downcase | test("ghostty")) | {id, pid, title: .name, class: .window_properties.class, instance: .window_properties.instance}'; }

find_new(){
  local -a base=("$@"); local id=""
  for _ in {1..60}; do
    mapfile -t now < <(ghostty_ids)
    for n in "${now[@]}"; do
      local found=0
      for b in "${base[@]:-}"; do [[ "$n" == "$b" ]] && { found=1; break; }; done
      ((found==0)) && { id="$n"; break; }
    done
    [[ -n "$id" ]] && break
    sleep 0.25
  done
  printf '%s' "$id"
}

log "start"
log "pre-info: $(ghostty_info | tr -d '\n')"
mapfile -t before < <(ghostty_ids)
log "before: ${before[*]:-<none>}"

i3-msg 'workspace number 1; exec --no-startup-id ghostty' >/dev/null
log "launched ghostty #1"
first_id="$(find_new "${before[@]:-}")"
log "first_id: ${first_id:-<none>}"
[[ -n "${first_id}" ]] && i3-msg "[con_id=${first_id}] mark ghostty1" >/dev/null && i3-msg "[con_id=${first_id}] move container to workspace number 1" >/dev/null

mapfile -t base2 < <(ghostty_ids)
log "after first: ${base2[*]:-<none>}"

i3-msg 'workspace number 8; exec --no-startup-id ghostty -e bash -ic '\''runwatcher -d 8 -n 1'\''' >/dev/null
log "launched ghostty #2 with runwatcher"
second_id="$(find_new "${base2[@]:-}")"
log "second_id: ${second_id:-<none>}"
[[ -n "${second_id}" ]] && i3-msg "[con_id=${second_id}] mark ghostty2" >/dev/null && i3-msg "[con_id=${second_id}] move container to workspace number 8" >/dev/null

i3-msg 'workspace number 2; exec --no-startup-id brave-browser' >/dev/null
i3-msg 'workspace number 3; exec --no-startup-id gtk-launch obsidian.desktop' >/dev/null
i3-msg 'workspace number 4; exec --no-startup-id ticktick --no-sandbox --password-store=basic --user-data-dir=$HOME/.ticktick-profile' >/dev/null
i3-msg 'workspace number 5; exec --no-startup-id spotify' >/dev/null
i3-msg 'workspace number 6; exec --no-startup-id ~/.local/share/JetBrains/Toolbox/apps/intellij-idea-ultimate/bin/idea' >/dev/null
i3-msg 'workspace number 7; exec --no-startup-id gtk-launch pgadmin4.desktop' >/dev/null
i3-msg 'workspace number 10; exec --no-startup-id slack' >/dev/null

sleep 4

i3-msg '[class="(?i)obsidian"] move container to workspace number 3' >/dev/null
i3-msg '[class="(?i)ticktick"] move container to workspace number 4' >/dev/null
i3-msg '[class="(?i)spotify"] move container to workspace
