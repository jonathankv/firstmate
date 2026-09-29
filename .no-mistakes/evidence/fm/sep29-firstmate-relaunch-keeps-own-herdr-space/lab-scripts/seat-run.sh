#!/bin/bash
# Runs inside a lab seat pane, so the firstmate script inherits that pane's
# real Herdr identity (HERDR_PANE_ID, HERDR_SOCKET_PATH, HERDR_SESSION, ...).
# usage: seat-run.sh <tag> <home> <script> <args...>
tag=$1 home=$2 script=$3; shift 3
env -u NO_MISTAKES_GATE -u FM_GATE_REFUSE_BYPASS -u FM_ROOT_OVERRIDE -u FM_STATE_OVERRIDE \
  -u FM_DATA_OVERRIDE -u FM_CONFIG_OVERRIDE -u FM_PROJECTS_OVERRIDE \
  PATH="/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/fakebin:/Users/jonathanvu/.grok/bin:/Users/jonathanvu/Library/Python/3.9/bin:/Users/jonathanvu/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/pkg/env/global/bin:/Users/jonathanvu/.local/bin:/Users/jonathanvu/go/bin:/Users/jonathanvu/.cargo/bin:/Users/jonathanvu/bin:/usr/local/sbin" FM_HOME="$home" FM_SPAWN_NO_GUARD=1 \
  FM_CONTROL_POLL=0.5 FM_CONTROL_LAUNCH_WAIT=30 \
  "/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3PX7HE60Q0P4783KMF9MNZQ/bin/$script" "$@" > "/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/out/$tag.out" 2> "/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/out/$tag.err"
echo $? > "/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/out/$tag.rc"
