#!/usr/bin/env bash
# Stand-in for a secondmate agent's input box in the lab tmux server: shows an
# empty composer prompt and records every submitted line.
log=$1
while true; do
  printf '❯ '
  IFS= read -r line || exit 0
  printf '%s\n' "$line" >> "$log"
  printf '[received %d chars]\n' "${#line}"
done
