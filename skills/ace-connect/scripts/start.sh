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
dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
sock=$dir/$slug.sock
pidfile=$dir/$slug.pid

mkdir -p "$dir"
chmod 700 "$dir"

if [[ -f $pidfile ]]; then
  existing=$(cat "$pidfile" 2>/dev/null || true)
  if [[ -n $existing ]] && kill -0 "$existing" 2>/dev/null; then
    echo "engine already running for slug (pid $existing): $sock" >&2
    exit 1
  fi
  rm -f "$pidfile" "$sock"
fi

echo "$$" > "$pidfile"
trap 'pkill -P $$ 2>/dev/null; rm -f "$sock" "$pidfile"' EXIT

echo "ace-connect engine started: slug=$slug socket=$sock pid=$$" >&2

# One socat per message. Re-bind race between iterations is in-spec:
# send.sh exits 1 on unreachable peer, matching the documented retry path.
while socat -u "UNIX-LISTEN:$sock,unlink-early" -; do :; done
