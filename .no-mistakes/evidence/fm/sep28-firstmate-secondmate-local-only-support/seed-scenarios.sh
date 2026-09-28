#!/usr/bin/env bash
# seed-scenarios.sh - drive bin/fm-home-seed.sh live against the disposable lab home.
set -u
WT=/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3KZKYF5WWKFHCVHCVB5KP74
LABROOT=/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.IutFBj
LAB="$LABROOT/home"
export FM_HOME="$LAB"
cd "$WT"
run() { printf '\n$ %s\n' "$*"; "$@"; local rc=$?; printf '[exit %d]\n' "$rc"; return $rc; }
show_clone() {
  local c=$1
  echo "--- $c"
  echo "HEAD branch:        $(git -C "$c" symbolic-ref --short HEAD 2>&1)"
  echo "refs/heads/main:    $(git -C "$c" rev-parse --verify --quiet refs/heads/main 2>&1 || echo '(none)')"
  echo "origin/HEAD:        $(git -C "$c" symbolic-ref refs/remotes/origin/HEAD 2>&1 || echo '(none)')"
  echo "origin url:         $(git -C "$c" remote get-url origin 2>&1 || echo '(no origin remote)')"
  echo "branches:           $(git -C "$c" branch -a --format='%(refname:short)' | tr '\n' ' ')"
  echo "log:"; git -C "$c" log --oneline --decorate -5 | sed 's/^/  /'
}

echo "### S1: seed alpha (local-only, origin present, source checked out on hotfix) into design-home"
run env FM_SECONDMATE_CHARTER='design domain' bin/fm-home-seed.sh design "$LABROOT/design-home" alpha
show_clone "$LABROOT/design-home/projects/alpha"
echo "source main tip:    $(git -C "$LAB/projects/alpha" rev-parse main)"
echo "stale origin tip:   $(git -C "$LABROOT/alpha-origin.git" rev-parse main)"
echo "--- parent $LAB/data/secondmates.md:"; cat "$LAB/data/secondmates.md"
echo "--- design-home markers: .fm-secondmate-home=$(cat "$LABROOT/design-home/.fm-secondmate-home")  .fm-secondmate-parent=$(cat "$LABROOT/design-home/.fm-secondmate-parent" 2>/dev/null)"
echo "--- design-home/data/projects.md:"; cat "$LABROOT/design-home/data/projects.md"

echo
echo "### S2: seed beta (remoteless local-only, source checked out on feature) into ops-home"
run env FM_SECONDMATE_CHARTER='ops domain' bin/fm-home-seed.sh ops "$LABROOT/ops-home" beta
show_clone "$LABROOT/ops-home/projects/beta"
echo "source main tip:    $(git -C "$LAB/projects/beta" rev-parse main)"

echo
echo "### S3: refuse gamma (local-only source with no default branch: only trunk, no origin)"
run env FM_SECONDMATE_CHARTER='gamma domain' bin/fm-home-seed.sh gammadom "$LABROOT/gamma-home" gamma
echo "gamma-home exists? $([ -e "$LABROOT/gamma-home" ] && echo yes || echo no)"
echo "gammadom route registered? $(grep -c -- '- gammadom ' "$LAB/data/secondmates.md")"

echo
echo "### S4: refuse delta (registry posture the parser cannot resolve: forge=bogus)"
run env FM_SECONDMATE_CHARTER='delta domain' bin/fm-home-seed.sh deltadom "$LABROOT/delta-home" delta
echo "delta-home exists? $([ -e "$LABROOT/delta-home" ] && echo yes || echo no)"

echo
echo "### S5: epsilon registered with an unknown mode token [bogus-mode]"
run env FM_SECONDMATE_CHARTER='epsilon domain' bin/fm-home-seed.sh epsdom "$LABROOT/epsilon-home" epsilon
echo "epsilon-home exists? $([ -e "$LABROOT/epsilon-home" ] && echo yes || echo no)"
echo "fm-project-mode.sh epsilon -> $(bin/fm-project-mode.sh epsilon 2>&1)"
