#!/usr/bin/env bash
set -euo pipefail

# discover.sh
# List live listeners in the messages dir as tab-separated:
#   <slug>\t<pid>\t<socket-path>
# Sweeps stale .sock/.pid pairs as a side effect.

dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
mkdir -p "$dir"

shopt -s nullglob
for pidfile in "$dir"/*.pid; do
  pid=$(cat "$pidfile" 2>/dev/null || true)
  sock=${pidfile%.pid}.sock
  slug=$(basename "${pidfile%.pid}")
  if [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null; then
    printf '%s\t%s\t%s\n' "$slug" "$pid" "$sock"
  else
    rm -f "$pidfile" "$sock"
  fi
done
