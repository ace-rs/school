#!/usr/bin/env bash
set -euo pipefail

# codex.sh — start the primary interactive Codex TUI session for ace-connect.
# Boots `codex app-server` in the background, runs the ace-connect bridge
# against it, and attaches the TUI in the foreground. All background
# processes are cleaned up on exit.

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
bridge_script="$script_dir/codex-app-bridge.sh"

slug="school.codex"
cwd="$PWD"

usage() {
  cat <<'USAGE'
Usage: codex.sh [--slug NAME] [--cwd DIR]

Options:
  --slug NAME   ace-connect slug for incoming peer messages (default: school.codex)
  --cwd DIR     working directory for app-server and bridge (default: $PWD)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) slug="${2:?--slug requires a value}"; shift 2 ;;
    --cwd)  cwd="${2:?--cwd requires a value}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -x "$bridge_script" ]]; then
  echo "bridge script not found or not executable: $bridge_script" >&2
  exit 1
fi
for tool in codex websocat jq socat; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool not found in PATH" >&2
    exit 1
  fi
done

if ! cwd=$(cd -- "$cwd" && pwd); then
  echo "working directory does not exist: $cwd" >&2
  exit 1
fi

startup_timeout_ms="${CODEX_BRIDGE_STARTUP_TIMEOUT_MS:-30000}"
if ! [[ "$startup_timeout_ms" =~ ^[1-9][0-9]*$ ]]; then
  echo "CODEX_BRIDGE_STARTUP_TIMEOUT_MS must be a positive integer" >&2
  exit 1
fi

log_dir="${CODEX_BRIDGE_LOG_DIR:-${TMPDIR:-/tmp}/ace-connect-codex}"
socket_dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
socket_path="$socket_dir/$slug.sock"
if [[ -e "$socket_path" ]]; then
  echo "ace-connect socket already exists for slug=$slug: $socket_path" >&2
  echo "choose another --slug or remove the stale socket" >&2
  exit 1
fi

mkdir -p "$log_dir"
safe_slug=$(printf '%s' "$slug" | tr -c 'A-Za-z0-9_.-' '_')
app_log="$log_dir/$safe_slug.app-server.log"
bridge_log="$log_dir/$safe_slug.bridge.log"
: >"$app_log"
: >"$bridge_log"

app_pid=""
bridge_pid=""

# shellcheck disable=SC2329
terminate_process() {
  local pid="${1:-}"
  local name="$2"

  if [[ -z "$pid" ]] || ! kill -0 "$pid" 2>/dev/null; then
    return
  fi

  kill -TERM "$pid" 2>/dev/null || true
  for _ in {1..20}; do
    if ! kill -0 "$pid" 2>/dev/null; then
      wait "$pid" 2>/dev/null || true
      return
    fi
    sleep 0.1
  done

  echo "$name did not exit after SIGTERM; sending SIGKILL" >&2
  kill -KILL "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

# shellcheck disable=SC2329
cleanup() {
  trap - EXIT INT TERM
  terminate_process "$bridge_pid" "ace-connect bridge"
  terminate_process "$app_pid" "codex app-server"
}
trap cleanup EXIT INT TERM

cd "$cwd"
codex app-server --listen "ws://127.0.0.1:0" >"$app_log" 2>&1 &
app_pid=$!

url=""
polls=$(( (startup_timeout_ms + 99) / 100 ))
for ((attempt = 0; attempt < polls; attempt += 1)); do
  if [[ -s "$app_log" ]]; then
    if url=$(grep -E -m1 -o 'ws://127\.0\.0\.1:[0-9]+' "$app_log"); then
      [[ -n "$url" ]] && break
    fi
  fi
  if ! kill -0 "$app_pid" 2>/dev/null; then
    echo "codex app-server exited before printing URL; log follows:" >&2
    cat "$app_log" >&2
    exit 1
  fi
  sleep 0.1
done

if [[ -z "$url" ]]; then
  echo "timed out waiting for codex app-server URL; log follows:" >&2
  cat "$app_log" >&2
  exit 1
fi

"$bridge_script" \
  --app-url "$url" \
  --slug "$slug" \
  --cwd "$cwd" \
  --wait-for-loaded-thread \
  >"$bridge_log" 2>&1 &
bridge_pid=$!

# Brief settle before handing the terminal to the TUI. In --app-url mode the
# bridge waits until the TUI creates a loaded thread, then binds its socket.
sleep 0.5

if ! kill -0 "$bridge_pid" 2>/dev/null; then
  echo "ace-connect bridge exited before TUI start; log follows:" >&2
  cat "$bridge_log" >&2
  exit 1
fi

echo "codex app-server=$url ace-connect slug=$slug bridge-log=$bridge_log" >&2
echo "ace-connect socket binds after the TUI creates a loaded thread" >&2

codex_status=0
codex --remote "$url" --no-alt-screen || codex_status=$?

if [[ -n "$bridge_pid" ]] && ! kill -0 "$bridge_pid" 2>/dev/null; then
  bridge_status=0
  wait "$bridge_pid" 2>/dev/null || bridge_status=$?
  bridge_pid=""
  if [[ "$bridge_status" -ne 0 ]]; then
    echo "ace-connect bridge exited with status $bridge_status; log follows:" >&2
    cat "$bridge_log" >&2
  fi
fi

exit "$codex_status"
