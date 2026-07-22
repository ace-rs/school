#!/usr/bin/env bash
set -euo pipefail

# discover.sh
# List live engines in the messages dir as tab-separated:
#   <slug>\t<pid>\t<socket-path>
# Sweeps stale artifacts as a side effect: dead .pid entries and any
# .sock/.codex-app.url left with no live owning engine.

socket_dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
mkdir -p "$socket_dir"

# A slug is live iff its .pid names a running process (bash 3.2: no assoc
# arrays, so re-derive liveness per file instead of caching a live set).
alive() { # slug -> 0 if a running engine owns it
  local pid
  pid=$(cat "$socket_dir/$1.pid" 2>/dev/null || true)
  [[ -n $pid ]] && kill -0 "$pid" 2>/dev/null
}

shopt -s nullglob
for pid_path in "$socket_dir"/*.pid; do
  slug=$(basename "${pid_path%.pid}")
  if alive "$slug"; then
    printf '%s\t%s\t%s\n' "$slug" "$(cat "$pid_path")" "${pid_path%.pid}.sock"
  else
    rm -f "$pid_path"
  fi
done

# Sweep sidecars — .sock and the codex rendezvous file — whose slug isn't live.
# Catches a .sock with no .pid at all, which the pid pass above can't see.
for sidecar in "$socket_dir"/*.sock "$socket_dir"/*.codex-app.url; do
  slug=$(basename "$sidecar")
  slug=${slug%.sock}
  slug=${slug%.codex-app.url}
  alive "$slug" || rm -f "$sidecar"
done
