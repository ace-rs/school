#!/usr/bin/env bash
set -euo pipefail

# discover.sh
# List live engines in the messages dir as tab-separated:
#   <slug>\t<pid>\t<socket-path>
# Sweeps stale .sock/.pid pairs as a side effect.

socket_dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
mkdir -p "$socket_dir"

shopt -s nullglob
for pid_path in "$socket_dir"/*.pid; do
  pid=$(cat "$pid_path" 2>/dev/null || true)
  socket_path=${pid_path%.pid}.sock
  slug=$(basename "${pid_path%.pid}")
  if [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null; then
    printf '%s\t%s\t%s\n' "$slug" "$pid" "$socket_path"
  else
    rm -f "$pid_path" "$socket_path"
  fi
done
