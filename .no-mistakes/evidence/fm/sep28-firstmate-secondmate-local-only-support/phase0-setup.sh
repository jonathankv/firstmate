#!/usr/bin/env bash
# Phase 0: build the main lab home's projects and registry.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
step "main lab home: FM_HOME=$LAB, gate context NO_MISTAKES_GATE=${NO_MISTAKES_GATE:-unset}"
mkdir -p "$WORK/remotes"
# alpha: local-only project with a forge origin that falls behind local landings.
git init -q -b main "$LAB/projects/alpha"
echo "# alpha" > "$LAB/projects/alpha/README.md"
git -C "$LAB/projects/alpha" add README.md && git -C "$LAB/projects/alpha" commit -qm "alpha: initial"
git clone -q --bare "$LAB/projects/alpha" "$WORK/remotes/alpha.git"
git -C "$LAB/projects/alpha" remote add origin "$WORK/remotes/alpha.git"
git -C "$LAB/projects/alpha" fetch -q origin && git -C "$LAB/projects/alpha" remote set-head origin main
echo "landed locally" > "$LAB/projects/alpha/landed.txt"
git -C "$LAB/projects/alpha" add landed.txt && git -C "$LAB/projects/alpha" commit -qm "alpha: landed by fm-merge-local, never pushed"
git -C "$LAB/projects/alpha" checkout -q -b hotfix
echo wip > "$LAB/projects/alpha/wip.txt"; git -C "$LAB/projects/alpha" add wip.txt && git -C "$LAB/projects/alpha" commit -qm "alpha: hotfix branch checked out in the main home"
# gamma: local-only project with no remote at all.
git init -q -b main "$LAB/projects/gamma"
echo "# gamma" > "$LAB/projects/gamma/README.md"
git -C "$LAB/projects/gamma" add README.md && git -C "$LAB/projects/gamma" commit -qm "gamma: initial"
# beta: direct-PR project cloned from its origin.
git init -q -b main "$WORK/remotes/beta-src"
echo "# beta" > "$WORK/remotes/beta-src/README.md"
git -C "$WORK/remotes/beta-src" add README.md && git -C "$WORK/remotes/beta-src" commit -qm "beta: initial"
git clone -q --bare "$WORK/remotes/beta-src" "$WORK/remotes/beta.git"
git clone -q "$WORK/remotes/beta.git" "$LAB/projects/beta"
# epsilon: local-only project registered in the main home but never seeded into design.
git init -q -b main "$LAB/projects/epsilon"
echo "# epsilon" > "$LAB/projects/epsilon/README.md"
git -C "$LAB/projects/epsilon" add README.md && git -C "$LAB/projects/epsilon" commit -qm "epsilon: initial"
cat > "$LAB/data/projects.md" <<'REG'
- alpha [local-only] - alpha design system (added 2026-09-29)
- gamma [local-only] - remoteless notes (added 2026-09-29)
- beta [direct-PR] - forge-backed project (added 2026-09-29)
- epsilon [local-only] - local project no secondmate holds (added 2026-09-29)
REG
run cat "$LAB/data/projects.md"
for p in alpha gamma beta epsilon; do run "$WT/bin/fm-project-mode.sh" "$p"; done
printf 'alpha main tip (local, unpushed): %s\n' "$(git -C "$LAB/projects/alpha" rev-parse --short main)"
printf 'alpha origin/main tip (stale):     %s\n' "$(git -C "$WORK/remotes/alpha.git" rev-parse --short main)"
printf 'alpha checked-out branch in main:  %s\n' "$(git -C "$LAB/projects/alpha" symbolic-ref --short HEAD)"
