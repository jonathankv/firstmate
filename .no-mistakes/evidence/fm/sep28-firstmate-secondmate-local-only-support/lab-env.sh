# Shared environment for the live lab run (sourced by each phase).
EVID=/Users/jonathanvu/.no-mistakes/evidence/01M3NZK4215DGQCD59H7N5EKYZ
. "$EVID/.labpaths"
WT=/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3NZK4215DGQCD59H7N5EKYZ
LAB="$WORK/main"
SUB="$WORK/design-home"
unset FM_ROOT_OVERRIDE FM_STATE_OVERRIDE FM_DATA_OVERRIDE FM_CONFIG_OVERRIDE FM_PROJECTS_OVERRIDE FM_GATE_REFUSE_BYPASS TMUX
export FM_HOME="$LAB" TMUX_TMPDIR="$LAB_TMUX" FM_BACKEND=tmux
export GIT_AUTHOR_NAME='Lab Captain' GIT_AUTHOR_EMAIL=lab@example.invalid GIT_COMMITTER_NAME='Lab Captain' GIT_COMMITTER_EMAIL=lab@example.invalid
step() { printf '\n===== %s =====\n' "$*"; }
run() { printf '$ %s\n' "$*"; "$@"; rc=$?; printf '[exit %s]\n' "$rc"; return 0; }
