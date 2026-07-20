#!/usr/bin/env bash
set -euo pipefail

# start.sh SLUG
# Ignition: bind <dir>/<slug>.sock (your inbox) and emit one line per received
# message on stdout. Exits 1 if a live engine already owns the slug. Wrapper is
# the long-lived process; socat runs one-shot per accepted connection so
# broken-pipe on stdout (monitor surface closed) terminates the loop cleanly.

if [[ $# -ne 1 ]]; then
  echo "usage: start.sh SLUG" >&2
  exit 2
fi

slug=$1
socket_dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
socket_path=$socket_dir/$slug.sock
pid_path=$socket_dir/$slug.pid

mkdir -p "$socket_dir"
chmod 700 "$socket_dir"

if [[ -f $pid_path ]]; then
  existing=$(cat "$pid_path" 2>/dev/null || true)
  if [[ -n $existing ]] && kill -0 "$existing" 2>/dev/null; then
    echo "engine already running for slug (pid $existing): $socket_path" >&2
    exit 1
  fi
  rm -f "$pid_path" "$socket_path"
fi

echo "$$" > "$pid_path"
trap 'pkill -P $$ 2>/dev/null; rm -f "$socket_path" "$pid_path"' EXIT

echo "ace-connect engine started: slug=$slug socket=$socket_path pid=$$" >&2

# One socat per message. Re-bind race between iterations is in-spec:
# send.sh exits 1 on unreachable peer, matching the documented retry path.
while socat -u "UNIX-LISTEN:$socket_path,unlink-early" -; do :; done
