#!/usr/bin/env bash
# teardown-scenarios.sh - retire the design secondmate through bin/fm-teardown.sh on the lab tmux socket.
set -u
EV=/Users/jonathanvu/.no-mistakes/evidence/01M3KZKYF5WWKFHCVHCVB5KP74
WT=/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3KZKYF5WWKFHCVHCVB5KP74
LABROOT=/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.IutFBj
LAB="$LABROOT/home"
DESIGN="$LABROOT/design-home"
export FM_HOME="$LAB"
export TMUX_TMPDIR="$LAB/tmux"
TMUX=$(cat "$LABROOT/lab-tmux-env"); export TMUX
cd "$WT"
state() {
  echo "  design-home present: $([ -d "$DESIGN" ] && echo yes || echo no) | spawn record $LAB/state/design.meta: $([ -e "$LAB/state/design.meta" ] && echo present || echo gone) | registry route: $(grep -c -- '- design ' "$LAB/data/secondmates.md" 2>/dev/null || echo 0) | lab tmux windows: [$(tmux -L fm-lab list-windows -a -F '#{session_name}:#{window_name}' 2>/dev/null | tr '\n' ' ')]"
}
echo "tmux server addressed by the scripts: $(tmux display-message -p '#{socket_path}')"
echo "secondmate alpha main: $(git -C "$DESIGN/projects/alpha" rev-parse --short main)   parent alpha main: $(git -C "$LAB/projects/alpha" rev-parse --short main)"

echo
echo "### S9a: normal retirement must refuse while the secondmate's alpha clone holds landed work the parent lacks"
printf '$ bin/fm-teardown.sh design\n'
bin/fm-teardown.sh design >"$EV/teardown-refusal.out" 2>"$EV/teardown-refusal.err"; rc=$?
cat "$EV/teardown-refusal.out"; sed 's/^/stderr: /' "$EV/teardown-refusal.err"
printf '[exit %d]\n' "$rc"
state

echo
echo "### S9b: captain runs the printed carry-back"
CARRY=$(sed -n 's/^Carry them back first: //p' "$EV/teardown-refusal.err")
printf '$ %s\n' "$CARRY"
bash -c "$CARRY"; printf '[exit %d]\n' $?
echo "  parent now has refs/heads/secondmate/design/main = $(git -C "$LAB/projects/alpha" rev-parse --short refs/heads/secondmate/design/main 2>&1)"
echo "  secondmate main tip                        = $(git -C "$DESIGN/projects/alpha" rev-parse --short main)"
echo "  commits in secondmate main absent from parent now: $(git -C "$LAB/projects/alpha" rev-list --count "$(git -C "$DESIGN/projects/alpha" rev-parse main)" --not --all)"

echo
echo "### S9c: retire again; the parent clone now holds the work, so retirement proceeds"
printf '$ bin/fm-teardown.sh design\n'
bin/fm-teardown.sh design >"$EV/teardown-retire.out" 2>"$EV/teardown-retire.err"; rc=$?
cat "$EV/teardown-retire.out"; sed 's/^/stderr: /' "$EV/teardown-retire.err"
printf '[exit %d]\n' "$rc"
state
echo "  parent still holds the carried-back commit: $(git -C "$LAB/projects/alpha" log --oneline -1 refs/heads/secondmate/design/main)"
