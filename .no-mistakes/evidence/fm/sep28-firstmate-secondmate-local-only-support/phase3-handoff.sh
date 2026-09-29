#!/usr/bin/env bash
# Phase 3: backlog handoff of local-only work to secondmates.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
SUB_ABS=$(cd "$SUB" && pwd -P)
# Live receiver endpoints in the lab's private tmux server.
tmux new-session -d -s firstmate -n fm-design -x 200 -y 50 "$EVID/receiver-pane.sh $WORK/design-received.log"
cat > "$LAB/state/design.meta" <<META
window=firstmate:fm-design
endpoint_task_id=design
kind=secondmate
mode=secondmate
harness=claude
backend=tmux
yolo=off
home=$SUB_ABS
worktree=$SUB_ABS
project=$SUB_ABS
projects=alpha, gamma, beta
META
# A remote route registered alongside the local one.
printf -- '- ios - iOS work (host: lab-unreachable-host; root: /opt/fm-root; home: /opt/fm-home; scope: iOS work; projects: alpha; added 2026-09-29)\n' >> "$LAB/data/secondmates.md"
cat > "$LAB/data/backlog.md" <<'BL'
## In flight

## Queued
- [ ] alpha-tokens - add spacing tokens to the design system (repo: alpha, priority: high)
- [ ] beta-docs - document the beta API (repo: beta)
- [ ] epsilon-fix - fix epsilon startup (repo: epsilon)
- [ ] beta-lint - tidy beta lint (repo: beta)
- [ ] alpha-icons - icon refresh (repo: alpha)

## Done
BL
run cat "$LAB/data/secondmates.md"
run cat "$LAB/data/backlog.md"

step "S5a local-only epsilon item bound for 'design', whose home holds no epsilon clone, batched with a direct-PR item: refused, nothing moves"
cp "$LAB/data/backlog.md" "$WORK/backlog.before"
run "$WT/bin/fm-backlog-handoff.sh" design beta-lint epsilon-fix
cmp -s "$WORK/backlog.before" "$LAB/data/backlog.md" && echo "main backlog unchanged"
printf 'secondmate backlog exists? %s\n' "$([ -e "$SUB/data/backlog.md" ] && echo yes || echo no)"

step "S5b local-only alpha item bound for the remote route 'ios': refused before staging"
run "$WT/bin/fm-backlog-handoff.sh" ios beta-lint alpha-icons
cmp -s "$WORK/backlog.before" "$LAB/data/backlog.md" && echo "main backlog unchanged"
printf 'outbox for ios exists? %s\n' "$([ -e "$LAB/data/handoff/ios.outbox.md" ] && echo yes || echo no)"

step "S5c 'design' holds epsilon only through a symlinked projects/epsilon entry (clone elsewhere inside the home): refused"
git clone -q "$LAB/projects/epsilon" "$SUB/project-store/epsilon"
ln -s "$SUB_ABS/project-store/epsilon" "$SUB/projects/epsilon"
run ls -l "$SUB/projects/"
run "$WT/bin/fm-backlog-handoff.sh" design epsilon-fix
step "S5c same, with projects/epsilon symlinked to a clone outside the home: refused"
rm "$SUB/projects/epsilon"; ln -s "$LAB/projects/epsilon" "$SUB/projects/epsilon"
run "$WT/bin/fm-backlog-handoff.sh" design epsilon-fix
cmp -s "$WORK/backlog.before" "$LAB/data/backlog.md" && echo "main backlog unchanged after both symlink refusals"
rm "$SUB/projects/epsilon"; rm -rf "$SUB/project-store"

step "S4 local-only alpha item and direct-PR beta item handed off to 'design', whose home holds alpha's clone: moved and the secondmate woken"
run "$WT/bin/fm-backlog-handoff.sh" design alpha-tokens beta-docs
step "main backlog after the move"
run cat "$LAB/data/backlog.md"
step "secondmate 'design' backlog after the move"
run cat "$SUB/data/backlog.md"
step "wake text the secondmate pane received"
run cat "$WORK/design-received.log"
step "live pane capture (lab tmux server)"
tmux capture-pane -p -t firstmate:fm-design | sed '/^$/d'
