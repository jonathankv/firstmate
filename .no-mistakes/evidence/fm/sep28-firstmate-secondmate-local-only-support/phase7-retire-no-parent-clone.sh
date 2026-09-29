#!/usr/bin/env bash
# Phase 7: retirement when the main home holds no clone of the local-only project.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
echo "notes v2" > "$SUB/projects/gamma/notes.txt"; git -C "$SUB/projects/gamma" add notes.txt; git -C "$SUB/projects/gamma" commit -qm "gamma: landed in the design secondmate home"
mv "$LAB/projects/gamma" "$WORK/gamma-parent-moved-aside"
step "S7b ordinary retirement of 'design' while the main home has no gamma clone at all"
run "$WT/bin/fm-teardown.sh" design 2> "$WORK/design-teardown.err"
grep -v 'fm-gate-refuse:\|WARNING: watcher' "$WORK/design-teardown.err"
printf 'after refusal: home present=%s meta present=%s window alive=%s\n' "$([ -d "$SUB" ] && echo yes || echo no)" "$([ -e "$LAB/state/design.meta" ] && echo yes || echo no)" "$(tmux list-windows -t firstmate -F '#W' | grep -qx fm-design && echo yes || echo no)"
step "S7b run the printed carry-back, which recreates the parent clone from a bundle"
sed -n 's/^Carry them back first: //p' "$WORK/design-teardown.err" | while IFS= read -r carry; do printf '$ %s\n' "$carry"; bash -c "$carry" 2>&1; printf '[exit %s]\n' "$?"; done
run git -C "$LAB/projects/gamma" log --oneline -2 main
step "S7b retirement no longer refuses for local-only work (the next guard, unrelated to this change, is the handoff's pending wake reply)"
run "$WT/bin/fm-teardown.sh" design 2> "$WORK/design-teardown2.err"
grep -v 'fm-gate-refuse:\|WARNING: watcher' "$WORK/design-teardown2.err"
