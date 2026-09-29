#!/usr/bin/env bash
# Phase 1: seed a local secondmate home that holds local-only projects.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
step "S1 seed local secondmate 'design' with local-only alpha, remoteless local-only gamma, direct-PR beta"
FM_SECONDMATE_CHARTER='Design system work for alpha, gamma and beta' \
  run "$WT/bin/fm-home-seed.sh" design "$SUB" alpha gamma beta
step "registry route written in the main home"
run cat "$LAB/data/secondmates.md"
step "secondmate home layout"
run ls -a "$SUB" ; run cat "$SUB/.fm-secondmate-home"; run cat "$SUB/data/projects.md"
step "alpha clone in the secondmate home"
printf 'checked-out branch: %s\n' "$(git -C "$SUB/projects/alpha" symbolic-ref --short HEAD)"
printf 'main tip:           %s  (main home local main: %s, stale origin main: %s)\n' \
  "$(git -C "$SUB/projects/alpha" rev-parse --short main)" "$(git -C "$LAB/projects/alpha" rev-parse --short main)" "$(git -C "$WORK/remotes/alpha.git" rev-parse --short main)"
printf 'origin url:         %s\n' "$(git -C "$SUB/projects/alpha" remote get-url origin)"
printf 'origin/HEAD:        %s\n' "$(git -C "$SUB/projects/alpha" symbolic-ref refs/remotes/origin/HEAD)"
printf 'hotfix-only file present? %s\n' "$([ -e "$SUB/projects/alpha/wip.txt" ] && echo yes || echo no)"
run git -C "$SUB/projects/alpha" log --oneline main
step "gamma (remoteless local-only) clone"
printf 'checked-out branch: %s, tip %s (source %s)\n' "$(git -C "$SUB/projects/gamma" symbolic-ref --short HEAD)" "$(git -C "$SUB/projects/gamma" rev-parse --short main)" "$(git -C "$LAB/projects/gamma" rev-parse --short main)"
printf 'remotes: [%s]\n' "$(git -C "$SUB/projects/gamma" remote | tr '\n' ' ')"
step "beta (direct-PR) clone"
printf 'origin url: %s\n' "$(git -C "$SUB/projects/beta" remote get-url origin)"
step "validate the registry"
run "$WT/bin/fm-home-seed.sh" validate
step "reseeding an up-to-date home is idempotent"
run "$WT/bin/fm-home-seed.sh" design "$SUB" alpha gamma beta
