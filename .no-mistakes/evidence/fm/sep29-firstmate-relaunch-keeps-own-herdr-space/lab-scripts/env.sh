ROOT=/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3PX7HE60Q0P4783KMF9MNZQ
LAB=/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN
SESSION=fm-lab-relaunch-ws-95232-22019
ORIG_PATH='/Users/jonathanvu/.grok/bin:/Users/jonathanvu/Library/Python/3.9/bin:/Users/jonathanvu/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/pkg/env/global/bin:/Users/jonathanvu/.local/bin:/Users/jonathanvu/go/bin:/Users/jonathanvu/.cargo/bin:/Users/jonathanvu/bin:/usr/local/sbin'
HELPER=$ROOT/bin/fm-herdr-lab.sh
lab() { PATH="$ORIG_PATH" "$HELPER" run "$SESSION" "$@"; }
# Restart the lab server exactly like a machine restart: guarded stop, then
# re-provision with the lab-only pane environment.
lab_restart() {
  PATH="$ORIG_PATH" "$HELPER" stop "$SESSION" >/dev/null || return 1
  sleep 1
  PATH="$LAB/agentbin:$ORIG_PATH" ZDOTDIR="$LAB/zdot" TREEHOUSE_ROOT="$LAB/treehouse-pool" \
    "$HELPER" provision "$SESSION"
}
layout() {  # ordered workspace rows: id, label, tab labels
  local ws
  lab workspace list | jq -r '.result.workspaces[] | [.workspace_id, .label] | @tsv' | while IFS=$'\t' read -r id label; do
    tabs=$(lab tab list --workspace "$id" | jq -r '[.result.tabs[] | .label] | join(", ")')
    printf '  %-5s %-40s tabs: %s\n' "$id" "$label" "$tabs"
  done
}
PRIMARY=$LAB/primary
MOMO=$LAB/momo
PROJECT=$LAB/project
run_fm() {  # <home> <launcher-pane-or-empty> <script> <args...>: run a firstmate script as that seat
  local home=$1 pane=$2 script=$3; shift 3
  env -u NO_MISTAKES_GATE -u FM_GATE_REFUSE_BYPASS -u FM_ROOT_OVERRIDE -u FM_STATE_OVERRIDE \
    -u FM_DATA_OVERRIDE -u FM_CONFIG_OVERRIDE -u FM_PROJECTS_OVERRIDE \
    PATH="$LAB/fakebin:$ORIG_PATH" FM_HOME="$home" HERDR_SESSION="$SESSION" \
    ${pane:+HERDR_PANE_ID=$pane} FM_SPAWN_NO_GUARD=1 FM_CONTROL_POLL=0.5 FM_CONTROL_LAUNCH_WAIT=30 \
    "$ROOT/bin/$script" "$@"
}
F_PANE=w1:p1
S_PANE=w2:p1
F_WS=w1
S_WS=w2
seat() {  # <pane> <tag> <home> <script> <args...>: type a firstmate command into a lab seat pane and wait
  local pane=$1 tag=$2 cmd i; shift 2
  rm -f "$LAB/out/$tag.rc"
  cmd=$(printf '%q ' "$LAB/seat-run.sh" "$tag" "$@")
  lab pane send-text "$pane" "$cmd" >/dev/null && lab pane send-keys "$pane" Enter >/dev/null || return 1
  for i in $(seq 1 400); do [ -f "$LAB/out/$tag.rc" ] && break; sleep 0.5; done
  [ -f "$LAB/out/$tag.rc" ] || { echo "seat command $tag timed out"; return 1; }
  echo "[$tag] rc=$(cat "$LAB/out/$tag.rc")"
}
S2_PANE=w2:p2
seat_base() {  # same as seat, but runs the base-commit scripts
  local pane=$1 tag=$2 cmd i; shift 2
  rm -f "$LAB/out/$tag.rc"
  cmd=$(printf '%q ' "$LAB/seat-run-base.sh" "$tag" "$@")
  lab pane send-text "$pane" "$cmd" >/dev/null && lab pane send-keys "$pane" Enter >/dev/null || return 1
  for i in $(seq 1 400); do [ -f "$LAB/out/$tag.rc" ] && break; sleep 0.5; done
  [ -f "$LAB/out/$tag.rc" ] || { echo "seat command $tag timed out"; return 1; }
  echo "[$tag] rc=$(cat "$LAB/out/$tag.rc")"
}
