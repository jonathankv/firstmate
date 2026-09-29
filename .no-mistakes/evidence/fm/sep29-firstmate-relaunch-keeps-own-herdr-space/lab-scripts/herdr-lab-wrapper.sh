#!/usr/bin/env bash
# Route every production-adapter Herdr call through the guarded lab helper,
# which appends the one real trailing --session for the lab session.
set -u
printf '%s\n' "$*" >> "/private/var/folders/my/pvdfczzj0ng_bh1rdn867lf80000gn/T/fm-lab.8TwQaN/herdr-calls.log"
args=("$@")
n=${#args[@]}
if [ "$n" -ge 2 ] && [ "${args[$((n-2))]}" = --session ]; then
  [ "${args[$((n-1))]}" = "fm-lab-relaunch-ws-95232-22019" ] || { echo "lab wrapper: refusing foreign session ${args[$((n-1))]}" >&2; exit 1; }
  unset "args[$((n-1))]" "args[$((n-2))]"
fi
set -- "${args[@]}"
for a in "$@"; do case "$a" in --session|--session=*) echo "lab wrapper: unexpected session flag" >&2; exit 1 ;; esac; done
if [ "${1:-}" = --version ]; then
  exec env PATH="/Users/jonathanvu/.grok/bin:/Users/jonathanvu/Library/Python/3.9/bin:/Users/jonathanvu/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/pkg/env/global/bin:/Users/jonathanvu/.local/bin:/Users/jonathanvu/go/bin:/Users/jonathanvu/.cargo/bin:/Users/jonathanvu/bin:/usr/local/sbin" herdr "$@" --session "fm-lab-relaunch-ws-95232-22019"
fi
exec env PATH="/Users/jonathanvu/.grok/bin:/Users/jonathanvu/Library/Python/3.9/bin:/Users/jonathanvu/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/pkg/env/global/bin:/Users/jonathanvu/.local/bin:/Users/jonathanvu/go/bin:/Users/jonathanvu/.cargo/bin:/Users/jonathanvu/bin:/usr/local/sbin" "/Users/jonathanvu/.no-mistakes/worktrees/38c446864270/01M3PX7HE60Q0P4783KMF9MNZQ/bin/fm-herdr-lab.sh" run "fm-lab-relaunch-ws-95232-22019" "$@"
