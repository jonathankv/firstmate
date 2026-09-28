#!/usr/bin/env bash
# landing-scenarios.sh - reseed, stale-clone refusal, and a live landing inside the seeded home.
set -u
WT=/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3KZKYF5WWKFHCVHCVB5KP74
LABROOT=/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.IutFBj
LAB="$LABROOT/home"
DESIGN="$LABROOT/design-home"
OPS="$LABROOT/ops-home"
export GIT_AUTHOR_NAME='Lab Captain' GIT_AUTHOR_EMAIL='lab@example.invalid'
export GIT_COMMITTER_NAME='Lab Captain' GIT_COMMITTER_EMAIL='lab@example.invalid'
run() { printf '\n$ %s\n' "$*"; "$@"; local rc=$?; printf '[exit %d]\n' "$rc"; return $rc; }
cd "$WT"

echo "### S6: reseed alpha into design-home (existing up-to-date local-only clone must be accepted)"
run env FM_HOME="$LAB" bin/fm-home-seed.sh design "$DESIGN" alpha
echo "design routes in registry: $(grep -c -- '- design ' "$LAB/data/secondmates.md")"

echo
echo "### S7: parent lands a new commit on beta main after ops-home was seeded; reseed must refuse until the clone catches up"
git -C "$LAB/projects/beta" checkout -q main
printf 'later\n' > "$LAB/projects/beta/later.txt"; git -C "$LAB/projects/beta" add later.txt; git -C "$LAB/projects/beta" commit -q -m 'landed in the main home after the secondmate clone was made'
git -C "$LAB/projects/beta" checkout -q feature
echo "parent beta main tip: $(git -C "$LAB/projects/beta" rev-parse main)   ops-home beta main tip: $(git -C "$OPS/projects/beta" rev-parse main)"
run env FM_HOME="$LAB" bin/fm-home-seed.sh ops "$OPS" beta
echo "ops-home clone still present? $([ -d "$OPS/projects/beta/.git" ] && echo yes || echo no)   ops route still registered: $(grep -c -- '- ops ' "$LAB/data/secondmates.md")"
echo "--- captain brings the clone up to date from the main home's clone path, then reseeds"
run git -C "$OPS/projects/beta" pull -q --ff-only "$LAB/projects/beta" main
echo "ops-home beta main tip now: $(git -C "$OPS/projects/beta" rev-parse main)"
run env FM_HOME="$LAB" bin/fm-home-seed.sh ops "$OPS" beta

echo
echo "### S8: land a local-only ship task INSIDE design-home with its own bin/fm-merge-local.sh"
echo "--- crewmate work: ship branch fm/task1 in a worktree of the secondmate home's alpha clone"
git -C "$DESIGN/projects/alpha" worktree add -q "$LABROOT/design-task1-wt" -b fm/task1
printf 'shipped\n' > "$LABROOT/design-task1-wt/shipped.txt"
git -C "$LABROOT/design-task1-wt" add shipped.txt
git -C "$LABROOT/design-task1-wt" commit -q -m 'task1: shipped inside the design secondmate home'
cat > "$DESIGN/state/task1.meta" <<EOF
window=firstmate:fm-task1
worktree=$LABROOT/design-task1-wt
project=$DESIGN/projects/alpha
harness=claude
kind=ship
mode=local-only
yolo=off
branch=fm/task1
EOF
echo "--- design-home alpha before: main=$(git -C "$DESIGN/projects/alpha" rev-parse --short main) fm/task1=$(git -C "$DESIGN/projects/alpha" rev-parse --short fm/task1)"
cd "$DESIGN"
run env FM_HOME="$DESIGN" "$DESIGN/bin/fm-merge-local.sh" task1
echo "--- design-home alpha after:  main=$(git -C "$DESIGN/projects/alpha" rev-parse --short main)"
git -C "$DESIGN/projects/alpha" log --oneline --decorate -4 | sed 's/^/  /'
echo "parent main home alpha main: $(git -C "$LAB/projects/alpha" rev-parse --short main)  (commits in secondmate main not in parent: $(git -C "$DESIGN/projects/alpha" rev-list --count "$(git -C "$LAB/projects/alpha" rev-parse main)"..main))"
cd "$WT"
git -C "$DESIGN/projects/alpha" worktree remove --force "$LABROOT/design-task1-wt"
rm -f "$DESIGN/state/task1.meta"

echo
echo "### S9 prep: lab tmux server with the design secondmate endpoint window, and the parent's spawn record"
export TMUX_TMPDIR="$LAB/tmux"
tmux -L fm-lab new-session -d -s firstmate -n fm-design -c "$DESIGN"
SOCK=$(tmux -L fm-lab display-message -p '#{socket_path}'); SPID=$(tmux -L fm-lab display-message -p '#{pid}')
echo "lab socket: $SOCK (server pid $SPID)"
echo "windows: $(tmux -L fm-lab list-windows -a -F '#{session_name}:#{window_name}' | tr '\n' ' ')"
echo "plain tmux under TMUX=\$SOCK resolves to: $(TMUX="$SOCK,$SPID,0" tmux display-message -p '#{socket_path}')"
cat > "$LAB/state/design.meta" <<EOF
window=firstmate:fm-design
endpoint_task_id=design
worktree=$DESIGN
project=$DESIGN
harness=claude
kind=secondmate
mode=secondmate
yolo=off
home=$DESIGN
projects=alpha
EOF
printf '%s\n' "$SOCK,$SPID,0" > "$LABROOT/lab-tmux-env"
echo "spawn record written: $LAB/state/design.meta"
