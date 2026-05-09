#!/usr/bin/env bash
set -euo pipefail

# send.sh FROM TO BODY
# Deliver one ace-connect line. Strips tabs/CR/LF from BODY. Single attempt;
# on connect failure, exit non-zero with a message. No retries — duplicate
# semantics aren't settled yet.

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

if printf 'from=%s\tto=%s\tbody=%s\n' "$from" "$to" "$body" \
     | socat - "UNIX-CONNECT:$sock" 2>/dev/null; then
  exit 0
fi

if [[ -S $sock ]]; then
  echo "send failed: $sock not accepting" >&2
else
  echo "send failed: no such socket: $sock" >&2
fi
exit 1
