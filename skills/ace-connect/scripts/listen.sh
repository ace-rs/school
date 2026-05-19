#!/usr/bin/env bash
set -euo pipefail

# listen.sh SLUG
# Bind <dir>/<slug>.sock and emit one line per received message on stdout.
# Exits 1 if a live listener already owns the slug. Wrapper supervises
# socat so the trap can clean up <slug>.sock and <slug>.pid on exit.

if [[ $# -ne 1 ]]; then
  echo "usage: listen.sh SLUG" >&2
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
    echo "slug already in use by pid $existing: $sock" >&2
    exit 1
  fi
  rm -f "$pidfile" "$sock"
fi

# No ,fork — parent socat proxies to stdout directly, so a broken stdout
# pipe (harness reader gone) kills socat on the next message.
socat "UNIX-LISTEN:$sock,unlink-early" - &
socat_pid=$!
echo "$socat_pid" > "$pidfile"

cleanup() {
  kill -TERM "$socat_pid" 2>/dev/null || true
  rm -f "$sock" "$pidfile"
}
trap cleanup EXIT INT TERM

echo "ace-connect listening: slug=$slug socket=$sock pid=$socat_pid" >&2

wait "$socat_pid"
