#!/usr/bin/env bash
# Phase 2: adversarial seeding - the reseed guards and the remote refusal.
set -u
. /Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ/lab-env.sh
snap() { (cd "$SUB/projects/alpha" && git for-each-ref --format='%(refname) %(objectname:short)' && git symbolic-ref refs/remotes/origin/HEAD); cat "$SUB/.fm-secondmate-home"; cat "$LAB/data/secondmates.md"; }

step "S2a main home lands a new alpha commit; reseeding the now-behind secondmate clone must refuse"
git -C "$LAB/projects/alpha" checkout -q main
echo more > "$LAB/projects/alpha/more.txt"; git -C "$LAB/projects/alpha" add more.txt; git -C "$LAB/projects/alpha" commit -qm "alpha: second local landing in the main home"
git -C "$LAB/projects/alpha" checkout -q hotfix
snap > "$WORK/snap.before"
run "$WT/bin/fm-home-seed.sh" design "$SUB" alpha gamma beta
snap > "$WORK/snap.after"
if cmp -s "$WORK/snap.before" "$WORK/snap.after"; then echo "state check: secondmate clone refs, marker and registry unchanged by the refusal"; else echo "state check: CHANGED"; diff "$WORK/snap.before" "$WORK/snap.after"; fi
step "S2a after the secondmate clone catches up with the main home, reseeding succeeds"
run git -C "$SUB/projects/alpha" pull -q --ff-only "$LAB/projects/alpha" main
run "$WT/bin/fm-home-seed.sh" design "$SUB" alpha gamma beta

step "S2b the secondmate clone's origin/HEAD names another branch (hotfix); reseeding must refuse"
git -C "$SUB/projects/alpha" update-ref refs/remotes/origin/hotfix "$(git -C "$SUB/projects/alpha" rev-parse main)"
run git -C "$SUB/projects/alpha" remote set-head origin hotfix
run "$WT/bin/fm-home-seed.sh" design "$SUB" alpha gamma beta
step "S2b pointing origin/HEAD back at main lets the reseed through"
run git -C "$SUB/projects/alpha" remote set-head origin main
run "$WT/bin/fm-home-seed.sh" design "$SUB" alpha gamma beta

step "S2c a local-only source with no origin/HEAD, main, or master is refused, and no home is created"
git init -q -b trunk "$LAB/projects/zeta"; echo z > "$LAB/projects/zeta/z"; git -C "$LAB/projects/zeta" add z; git -C "$LAB/projects/zeta" commit -qm "zeta: trunk only"
echo '- zeta [local-only] - trunk-only local project (added 2026-09-29)' >> "$LAB/data/projects.md"
cp "$LAB/data/secondmates.md" "$WORK/reg.before"
FM_SECONDMATE_CHARTER='Zeta work' run "$WT/bin/fm-home-seed.sh" zeta-mate "$WORK/zeta-home" zeta
printf 'zeta-home exists after refusal? %s\n' "$([ -e "$WORK/zeta-home" ] && echo yes || echo no)"
cmp -s "$WORK/reg.before" "$LAB/data/secondmates.md" && echo "registry unchanged by the refusal"

step "S2d an unknown delivery mode in the registry does not seed as local-only"
echo '- eta [local-only forge=githb] - typo in forge token (added 2026-09-29)' >> "$LAB/data/projects.md"
git init -q -b main "$LAB/projects/eta"; echo e > "$LAB/projects/eta/e"; git -C "$LAB/projects/eta" add e; git -C "$LAB/projects/eta" commit -qm "eta"
FM_SECONDMATE_CHARTER='Eta work' run "$WT/bin/fm-home-seed.sh" eta-mate "$WORK/eta-home" eta
printf 'eta-home exists after refusal? %s\n' "$([ -e "$WORK/eta-home" ] && echo yes || echo no)"

step "S3 a remote secondmate route still refuses a local-only project before touching any host"
FM_SECONDMATE_CHARTER='iOS work' run "$WT/bin/fm-remote-home-seed.sh" ios-remote lab-unreachable-host /opt/fm-root /opt/fm-home alpha
cmp -s "$WORK/reg.before" "$LAB/data/secondmates.md" && echo "registry unchanged by the remote refusal"
