#!/usr/bin/env bash
set -euo pipefail

# send.sh FROM TO BODY
# Deliver one ace-connect line. Strips tabs/CR/LF from BODY. Single attempt;
# exit 1 on failure with a one-line stderr message.

if [[ $# -ne 3 ]]; then
  echo "usage: send.sh FROM TO BODY" >&2
  exit 2
fi

from=$1
to=$2
body=$3
body=${body//$'\t'/ }
body=${body//$'\n'/ }
body=${body//$'\r'/ }

dir=${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages
sock=$dir/$to.sock

# Backstop: if our own engine isn't running, any reply to us bounces. Warn,
# don't block — one-way sends (CTX/DONE/FILE) are still valid without an inbox.
frompid=$dir/$from.pid
if [[ ! -f $frompid ]] || ! kill -0 "$(cat "$frompid" 2>/dev/null || echo -1)" 2>/dev/null; then
  echo "warning: engine for from=$from not started; replies will bounce — start it with start.sh $from" >&2
fi

if printf 'from=%s\tto=%s\tbody=%s\n' "$from" "$to" "$body" \
     | socat - "UNIX-CONNECT:$sock" 2>/dev/null; then
  exit 0
fi

echo "send failed: $sock unreachable" >&2
exit 1
