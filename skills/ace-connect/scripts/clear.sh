#!/usr/bin/env bash
set -euo pipefail

# clear.sh
# Terminate all engines on this host and remove all socket/pid files.
# Affects every agent sharing the messages dir. Use sparingly.

socket_dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
mkdir -p "$socket_dir"

shopt -s nullglob
for pid_path in "$socket_dir"/*.pid; do
  pid=$(cat "$pid_path" 2>/dev/null || true)
  if [[ -n $pid ]]; then
    kill -TERM "$pid" 2>/dev/null || true
  fi
done

sleep 0.3
rm -f "$socket_dir"/*.sock "$socket_dir"/*.pid
