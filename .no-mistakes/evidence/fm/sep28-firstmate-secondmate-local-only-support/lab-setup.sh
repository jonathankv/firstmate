#!/usr/bin/env bash
# lab-setup.sh - mint a disposable firstmate lab home and fixture local-only projects
# for the live validation of "let a secondmate home hold a local-only project".
set -eu
WT=/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3KZKYF5WWKFHCVHCVB5KP74
LABROOT=$(mktemp -d "${TMPDIR:-/tmp}/fm-lab.XXXXXX")
LAB="$LABROOT/home"
"$WT/bin/fm-lab-home.sh" create "$LAB" >/dev/null
mkdir -p "$LAB/tmux"
export GIT_AUTHOR_NAME='Lab Captain' GIT_AUTHOR_EMAIL='lab@example.invalid'
export GIT_COMMITTER_NAME='Lab Captain' GIT_COMMITTER_EMAIL='lab@example.invalid'
commit() { local repo=$1 file=$2 msg=$3; printf '%s\n' "$file" > "$repo/$file"; git -C "$repo" add "$file"; git -C "$repo" commit -q -m "$msg"; }

# alpha: local-only WITH an origin. Local main holds a landed commit origin never
# received (fm-merge-local never pushes), and the clone is checked out on hotfix.
git init -q -b main "$LAB/projects/alpha"
commit "$LAB/projects/alpha" README.md 'initial'
git clone -q --bare "$LAB/projects/alpha" "$LABROOT/alpha-origin.git"
git -C "$LAB/projects/alpha" remote add origin "$LABROOT/alpha-origin.git"
git -C "$LAB/projects/alpha" fetch -q origin
git -C "$LAB/projects/alpha" remote set-head origin main
commit "$LAB/projects/alpha" landed.txt 'landed locally via fm-merge-local, never pushed'
git -C "$LAB/projects/alpha" checkout -q -b hotfix
commit "$LAB/projects/alpha" hotfix.txt 'work on the branch the main home happens to have checked out'

# beta: remoteless local-only, checked out on a feature branch.
git init -q -b main "$LAB/projects/beta"
commit "$LAB/projects/beta" README.md 'initial'
git -C "$LAB/projects/beta" checkout -q -b feature
commit "$LAB/projects/beta" feature.txt 'feature work'

# gamma: local-only with NO default branch (only trunk, no origin).
git init -q -b trunk "$LAB/projects/gamma"
commit "$LAB/projects/gamma" README.md 'initial'

# delta: a registry posture the parser refuses (unknown forge token).
git init -q -b main "$LAB/projects/delta"
commit "$LAB/projects/delta" README.md 'initial'

# epsilon: a mode token the registry parser does not know.
git init -q -b main "$LAB/projects/epsilon"
commit "$LAB/projects/epsilon" README.md 'initial'

cat > "$LAB/data/projects.md" <<EOF
# Projects

- alpha [local-only] - alpha, local-only with an origin (added 2026-09-29)
- beta [local-only] - beta, local-only with no remote (added 2026-09-29)
- gamma [local-only] - gamma, local-only with no default branch (added 2026-09-29)
- delta [local-only forge=bogus] - delta, unresolvable registry posture (added 2026-09-29)
- epsilon [bogus-mode] - epsilon, unknown delivery mode token (added 2026-09-29)
EOF

printf 'LABROOT=%s\n' "$LABROOT"
printf 'alpha main tip (source of truth): %s\n' "$(git -C "$LAB/projects/alpha" rev-parse main)"
printf 'alpha origin main tip (stale):    %s\n' "$(git -C "$LABROOT/alpha-origin.git" rev-parse main)"
printf 'alpha checked out on:             %s\n' "$(git -C "$LAB/projects/alpha" symbolic-ref --short HEAD)"
printf 'beta main tip: %s, checked out on %s, remotes: [%s]\n' "$(git -C "$LAB/projects/beta" rev-parse main)" "$(git -C "$LAB/projects/beta" symbolic-ref --short HEAD)" "$(git -C "$LAB/projects/beta" remote | tr '\n' ' ')"
printf 'gamma branches: %s\n' "$(git -C "$LAB/projects/gamma" branch --format='%(refname:short)' | tr '\n' ' ')"
