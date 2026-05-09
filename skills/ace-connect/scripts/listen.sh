#!/usr/bin/env bash
set -euo pipefail

# listen.sh SLUG
# Bind <dir>/<slug>.sock and emit one line per received message on stdout.
# Drop into a long-running process / monitor tool. Exits on signal.

if [[ $# -ne 1 ]]; then
  echo "usage: listen.sh SLUG" >&2
  exit 2
fi

slug=$1
dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
sock=$dir/$slug.sock

mkdir -p "$dir"
chmod 700 "$dir"
rm -f "$sock"

cleanup() {
  rm -f "$sock"
}
trap cleanup EXIT INT TERM

echo "ace-connect listening: slug=$slug socket=$sock" >&2

exec socat "UNIX-LISTEN:$sock,fork,unlink-early" -
