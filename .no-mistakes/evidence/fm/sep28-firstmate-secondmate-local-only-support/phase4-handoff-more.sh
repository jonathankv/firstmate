#!/usr/bin/env bash
# Phase 4: wake control, projects/ symlink acceptance, rerun idempotence.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
step "control: a direct-PR-only handoff to 'design' hits the same gate wake refusal (independent of local-only)"
run "$WT/bin/fm-backlog-handoff.sh" design beta-lint
run cat "$SUB/data/backlog.md"

step "S5d secondmate 'research' whose projects/ directory is a symlink to project-store/ inside its home"
git clone -q "$WT" "$WORK/research-home" 2>/dev/null
mkdir "$WORK/research-home/project-store"; ln -s project-store "$WORK/research-home/projects"
FM_SECONDMATE_CHARTER='Research on alpha icons' run "$WT/bin/fm-home-seed.sh" research "$WORK/research-home" alpha
run ls -l "$WORK/research-home/projects" "$WORK/research-home/project-store"
printf 'research alpha tip %s (main home main %s)\n' "$(git -C "$WORK/research-home/projects/alpha" rev-parse --short main)" "$(git -C "$LAB/projects/alpha" rev-parse --short main)"
step "S5d hand the local-only alpha-icons item to 'research': the guard accepts it and the item moves"
run "$WT/bin/fm-backlog-handoff.sh" research alpha-icons
run cat "$WORK/research-home/data/backlog.md"
run cat "$LAB/data/backlog.md"
