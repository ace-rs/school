#!/usr/bin/env bash
set -euo pipefail

# codex-app-bridge.sh — bridge ace-connect lines into a running codex
# app-server's current thread via JSON-RPC over WebSocket.
#
# Usage:
#   codex-app-bridge.sh --app-url WS_URL --slug NAME [--cwd DIR] \
#     [--thread-id ID] [--wait-for-loaded-thread]
#
# Replaces the older codex-app-bridge.mjs. Requires websocat, jq, socat.

app_url=""
slug=""
cwd="$PWD"
thread_id=""
wait_loaded=false

usage() {
  cat <<'USAGE'
Usage: codex-app-bridge.sh --app-url WS --slug NAME [--cwd DIR]
                           [--thread-id ID] [--wait-for-loaded-thread]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-url)   app_url="${2:?--app-url requires a value}"; shift 2 ;;
    --slug)      slug="${2:?--slug requires a value}"; shift 2 ;;
    --cwd)       cwd="${2:?--cwd requires a value}"; shift 2 ;;
    --thread-id) thread_id="${2:?--thread-id requires a value}"; shift 2 ;;
    --wait-for-loaded-thread) wait_loaded=true; shift ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ -z "$app_url" || -z "$slug" ]]; then
  echo "both --app-url and --slug are required" >&2
  usage >&2
  exit 2
fi

for tool in websocat jq socat; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool not found in PATH" >&2
    exit 1
  fi
done

cwd=$(cd -- "$cwd" && pwd)

dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
mkdir -p "$dir"
chmod 700 "$dir"
sock="$dir/$slug.sock"

# Set up FIFOs for the websocat coprocess. Opening order matters:
# websocat starts first with stdin <- ws_in_fifo and stdout -> ws_out_fifo;
# we then open ws_in_fifo for write and ws_out_fifo for read.
fifo_dir=$(mktemp -d -t "ace-bridge.XXXXXX")
ws_in_fifo="$fifo_dir/in"
ws_out_fifo="$fifo_dir/out"
mkfifo "$ws_in_fifo" "$ws_out_fifo"

ws_pid=""
cleanup() {
  trap - EXIT INT TERM
  rm -f "$sock"
  if [[ -n "$ws_pid" ]] && kill -0 "$ws_pid" 2>/dev/null; then
    kill "$ws_pid" 2>/dev/null || true
    wait "$ws_pid" 2>/dev/null || true
  fi
  rm -rf "$fifo_dir"
}
trap cleanup EXIT INT TERM

websocat -t --no-close "$app_url" <"$ws_in_fifo" >"$ws_out_fifo" &
ws_pid=$!

# Open our ends of the FIFOs. Order must match the redirections above so we
# don't deadlock against websocat.
exec 3>"$ws_in_fifo"
exec 4<"$ws_out_fifo"

next_id=1

# Send a JSON-RPC request and wait for a response with the matching id.
# Notifications and unrelated frames in between are discarded — this bridge
# does not track turn lifecycle, only delivery.
rpc() {
  local method="$1" params="$2"
  local id=$next_id
  next_id=$((next_id + 1))

  jq -nc --arg m "$method" --argjson id "$id" --argjson p "$params" \
    '{jsonrpc:"2.0", id:$id, method:$m, params:$p}' >&3

  local line
  while IFS= read -r line <&4; do
    if [[ "$(jq -r '.id // empty' <<<"$line")" == "$id" ]]; then
      printf '%s\n' "$line"
      return 0
    fi
  done
  return 1
}

notify() {
  local method="$1"
  local params="${2:-}"
  if [[ -z "$params" ]]; then
    params='{}'
  fi
  jq -nc --arg m "$method" --argjson p "$params" \
    '{jsonrpc:"2.0", method:$m, params:$p}' >&3
}

# Initialize the JSON-RPC session.
rpc initialize \
  '{"clientInfo":{"name":"ace-connect-codex-bash","version":"0"},"capabilities":{"experimentalApi":true}}' \
  >/dev/null
notify initialized

# Resolve thread id.
if [[ -z "$thread_id" ]]; then
  if $wait_loaded; then
    deadline=$(( $(date +%s) + 60 ))
    while :; do
      resp=$(rpc thread/loaded/list '{}')
      thread_id=$(jq -r '.result.data[0] // empty' <<<"$resp")
      [[ -n "$thread_id" ]] && break
      if [[ $(date +%s) -ge $deadline ]]; then
        echo "timed out waiting for a loaded thread" >&2
        exit 1
      fi
      sleep 0.25
    done
  else
    resp=$(rpc thread/loaded/list '{}')
    thread_id=$(jq -r '.result.data[0] // empty' <<<"$resp")
    if [[ -z "$thread_id" ]]; then
      params=$(jq -nc --arg cwd "$cwd" \
        '{cwd:$cwd, approvalPolicy:"never", sandbox:"workspace-write"}')
      resp=$(rpc thread/start "$params")
      thread_id=$(jq -r '.result.thread.id' <<<"$resp")
    fi
  fi
fi

rm -f "$sock"
echo "ace-connect codex bridge: slug=$slug thread=$thread_id" >&2

self_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
send_script="$self_dir/send.sh"

# One-shot accept loop — same rebind-gap behavior as every other ace-connect
# listener. Re-bind after each accepted message.
while :; do
  rm -f "$sock"
  if ! line=$(socat -u "UNIX-LISTEN:$sock,unlink-early" - 2>/dev/null); then
    break
  fi
  [[ -z "$line" ]] && continue

  from=$(printf '%s' "$line" | tr '\t' '\n' | sed -n 's/^from=//p' | head -1)

  prompt="You received an ace-connect message from another local agent. Act on the body as the user request for this turn. Keep the final response concise.

Raw line: $line"

  params=$(jq -nc --arg t "$thread_id" --arg text "$prompt" \
    '{threadId:$t, input:[{type:"text", text:$text}]}')

  if rpc turn/start "$params" >/dev/null; then
    if [[ -n "$from" ]] && [[ -x "$send_script" ]]; then
      "$send_script" "$slug" "$from" "delivered to thread $thread_id" || true
    fi
  else
    echo "turn/start failed for line: $line" >&2
  fi
done
