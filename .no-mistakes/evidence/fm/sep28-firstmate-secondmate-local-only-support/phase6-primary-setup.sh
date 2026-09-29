#!/usr/bin/env bash
# Phase 6 setup: a scope-fitting local secondmate that lacks a local-only clone.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
FM_SECONDMATE_CHARTER='Platform reliability work for the beta and epsilon services' \
  run "$WT/bin/fm-home-seed.sh" platform "$WORK/platform-home" beta
run ls "$WORK/platform-home/projects"
cat >> "$LAB/data/backlog.md" <<'BL'
BL
# Queue one new item for epsilon (local-only; no secondmate holds its clone).
awk '{print} /^## Queued/{print "- [ ] epsilon-crash - fix the epsilon crash on startup, reliability work (repo: epsilon)"}' "$LAB/data/backlog.md" > "$LAB/data/backlog.md.tmp" && mv "$LAB/data/backlog.md.tmp" "$LAB/data/backlog.md"
run cat "$LAB/data/backlog.md"
run cat "$LAB/data/secondmates.md"
