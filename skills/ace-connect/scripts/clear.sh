#!/usr/bin/env bash
set -euo pipefail

# clear.sh
# Terminate all listeners on this host and remove all socket/pid files.
# Affects every agent sharing the messages dir. Use sparingly.

dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
mkdir -p "$dir"

shopt -s nullglob
for pidfile in "$dir"/*.pid; do
  pid=$(cat "$pidfile" 2>/dev/null || true)
  if [[ -n $pid ]]; then
    kill -TERM "$pid" 2>/dev/null || true
  fi
done

sleep 0.3
rm -f "$dir"/*.sock "$dir"/*.pid
