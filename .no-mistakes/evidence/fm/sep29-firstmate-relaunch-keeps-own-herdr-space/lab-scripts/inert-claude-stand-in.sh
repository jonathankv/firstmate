#!/bin/bash
# Inert stand-in for the claude harness inside the lab: record the launch,
# register the pane's agent with the lab Herdr session, then become a
# claude-named foreground process so the control plane reads it alive.
printf '%s pane=%s cwd=%s\n' "$(date -u +%H:%M:%S)" "${HERDR_PANE_ID:-}" "$PWD" >> "/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/claude-launches.log"
PATH="/Users/jonathanvu/.grok/bin:/Users/jonathanvu/Library/Python/3.9/bin:/Users/jonathanvu/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/pkg/env/global/bin:/Users/jonathanvu/.local/bin:/Users/jonathanvu/go/bin:/Users/jonathanvu/.cargo/bin:/Users/jonathanvu/bin:/usr/local/sbin" "/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3PX7HE60Q0P4783KMF9MNZQ/bin/fm-herdr-lab.sh" run "fm-lab-relaunch-ws-95232-22019" pane report-agent "${HERDR_PANE_ID:-}" --source fm-lab-relaunch --agent claude --state idle >/dev/null 2>&1
exec "/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/procbin/claude" 900
