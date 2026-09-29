#!/usr/bin/env bash
# Phase 5: land local-only work inside a secondmate home, then retire it.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
OPS="$WORK/ops-home"
step "seed secondmate 'ops' with local-only alpha and remoteless local-only gamma"
FM_SECONDMATE_CHARTER='Operations on alpha and gamma' run "$WT/bin/fm-home-seed.sh" ops "$OPS" alpha gamma
OPS_ABS=$(cd "$OPS" && pwd -P)
tmux new-window -d -t firstmate -n fm-ops "$EVID/receiver-pane.sh $WORK/ops-received.log"
cat > "$LAB/state/ops.meta" <<META
window=firstmate:fm-ops
endpoint_task_id=ops
kind=secondmate
mode=secondmate
harness=claude
backend=tmux
yolo=off
home=$OPS_ABS
worktree=$OPS_ABS
project=$OPS_ABS
projects=alpha, gamma
META
printf 'lab tmux windows: %s\n' "$(tmux list-windows -t firstmate -F '#W' | tr '\n' ' ')"

step "S8 ops' registry loses gamma's entry: ordinary retirement refuses because gamma's posture no longer resolves"
cp "$OPS/data/projects.md" "$WORK/ops-projects.md"
grep -v '^- gamma ' "$WORK/ops-projects.md" > "$OPS/data/projects.md"
run "$WT/bin/fm-teardown.sh" ops
printf 'after refusal: home present=%s meta present=%s route present=%s window alive=%s\n' \
  "$([ -d "$OPS" ] && echo yes || echo no)" "$([ -e "$LAB/state/ops.meta" ] && echo yes || echo no)" \
  "$(grep -q '^- ops ' "$LAB/data/secondmates.md" && echo yes || echo no)" "$(tmux list-windows -t firstmate -F '#W' | grep -qx fm-ops && echo yes || echo no)"
step "S8 ops' registry misspells gamma's mode as locl-only: refused the same way"
sed 's/^- gamma \[local-only\]/- gamma [locl-only]/' "$WORK/ops-projects.md" > "$OPS/data/projects.md"
run grep '^- gamma' "$OPS/data/projects.md"
run "$WT/bin/fm-teardown.sh" ops
cp "$WORK/ops-projects.md" "$OPS/data/projects.md"

step "S6 a crewmate's ship branch for alpha lands inside the ops home through the secondmate's own bin/fm-merge-local.sh"
git -C "$OPS/projects/alpha" worktree add -q -b fm/ops-alpha-spacing "$WORK/ops-alpha-spacing-wt" main
echo "spacing: 4 8 12" > "$WORK/ops-alpha-spacing-wt/tokens.txt"
git -C "$WORK/ops-alpha-spacing-wt" add tokens.txt && git -C "$WORK/ops-alpha-spacing-wt" commit -qm "alpha: spacing tokens (landed in the ops secondmate home)"
echo "icons v2" > "$WORK/ops-alpha-spacing-wt/icons.txt"
git -C "$WORK/ops-alpha-spacing-wt" add icons.txt && git -C "$WORK/ops-alpha-spacing-wt" commit -qm "alpha: icon refresh (landed in the ops secondmate home)"
cat > "$OPS/state/ops-alpha-spacing.meta" <<META
window=firstmate:fm-ops-alpha-spacing
kind=ship
mode=local-only
yolo=off
harness=claude
project=$OPS_ABS/projects/alpha
worktree=$WORK/ops-alpha-spacing-wt
branch=fm/ops-alpha-spacing
META
printf 'ops alpha main before: %s\n' "$(git -C "$OPS/projects/alpha" rev-parse --short main)"
FM_HOME="$OPS_ABS" run "$OPS/bin/fm-merge-local.sh" ops-alpha-spacing
printf 'ops alpha main after:  %s ; main home alpha main: %s\n' "$(git -C "$OPS/projects/alpha" rev-parse --short main)" "$(git -C "$LAB/projects/alpha" rev-parse --short main)"
# The crew task finishes as its own teardown would: its worktree and record go away.
git -C "$OPS/projects/alpha" worktree remove "$WORK/ops-alpha-spacing-wt"; rm -f "$OPS/state/ops-alpha-spacing.meta"
# gamma (remoteless) also gets one landed commit directly on its default branch.
echo "note" > "$OPS/projects/gamma/note.txt"; git -C "$OPS/projects/gamma" add note.txt; git -C "$OPS/projects/gamma" commit -qm "gamma: landed in the ops secondmate home"

step "S7 ordinary retirement of 'ops' refuses: its local-only clones hold the only copy of landed work"
run "$WT/bin/fm-teardown.sh" ops 2> "$WORK/ops-teardown.err"
cat "$WORK/ops-teardown.err"
printf 'after refusal: home present=%s meta present=%s route present=%s window alive=%s\n' \
  "$([ -d "$OPS" ] && echo yes || echo no)" "$([ -e "$LAB/state/ops.meta" ] && echo yes || echo no)" \
  "$(grep -q '^- ops ' "$LAB/data/secondmates.md" && echo yes || echo no)" "$(tmux list-windows -t firstmate -F '#W' | grep -qx fm-ops && echo yes || echo no)"

step "S7 the captain runs each printed carry-back"
sed -n 's/^Carry them back first: //p' "$WORK/ops-teardown.err" | while IFS= read -r carry; do
  printf '$ %s\n' "$carry"; bash -c "$carry"; printf '[exit %s]\n' "$?"
done
run git -C "$LAB/projects/alpha" log --oneline -3 secondmate/ops/main
run git -C "$LAB/projects/gamma" log --oneline -3 secondmate/ops/main

step "S7 retirement now succeeds and removes the home, the route, the record, and the endpoint"
run "$WT/bin/fm-teardown.sh" ops
printf 'after retirement: home present=%s meta present=%s route present=%s window alive=%s\n' \
  "$([ -d "$OPS" ] && echo yes || echo no)" "$([ -e "$LAB/state/ops.meta" ] && echo yes || echo no)" \
  "$(grep -q '^- ops ' "$LAB/data/secondmates.md" && echo yes || echo no)" "$(tmux list-windows -t firstmate -F '#W' | grep -qx fm-ops && echo yes || echo no)"
run cat "$LAB/data/secondmates.md"
