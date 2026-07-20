#!/usr/bin/env bash
set -euo pipefail

# codex.sh — start the primary interactive Codex TUI session for ace-connect.
# Boots `codex app-server` in the background, runs the ace-connect bridge
# against it, and attaches the TUI in the foreground. All background
# processes are cleaned up on exit.

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
bridge_script="$script_dir/codex-app-bridge.sh"

slug=""
cwd="$PWD"

usage() {
  cat <<'USAGE'
Usage: codex.sh [--cwd DIR] [--slug NAME]

Options:
  --cwd DIR     working directory for app-server and bridge (default: $PWD)
  --slug NAME   override the ace-connect slug (default: derived from --cwd as
                <parent>.<workdir>.codex per the ace-connect convention)

Environment:
  ACE_CODEX_STARTUP_TIMEOUT_MS  app-server wait budget (default: 30000)
  ACE_CODEX_LOG_DIR             log directory (default: $TMPDIR/ace-connect-codex)
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

# Slug is deterministic per the ace-connect convention (SKILL.md): peers predict
# it, so it isn't a free parameter. Derive <parent>.<workdir>.codex from cwd.
if [[ -z "$slug" ]]; then
  slug="$(basename -- "$(dirname -- "$cwd")").$(basename -- "$cwd").codex"
fi

startup_timeout_ms="${ACE_CODEX_STARTUP_TIMEOUT_MS:-30000}"
if ! [[ "$startup_timeout_ms" =~ ^[1-9][0-9]*$ ]]; then
  echo "ACE_CODEX_STARTUP_TIMEOUT_MS must be a positive integer" >&2
  exit 1
fi

log_dir="${ACE_CODEX_LOG_DIR:-${TMPDIR:-/tmp}/ace-connect-codex}"
socket_dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
socket_path="$socket_dir/$slug.sock"
# Per-slug rendezvous file: the app-server binds an ephemeral port (ws://…:0),
# so a separate bridge/TUI can't predict the URL. Publish it here, keyed by the
# deterministic slug, so N codex sessions coexist without a port convention.
rendezvous_path="$socket_dir/$slug.codex-app.url"
if [[ -e "$socket_path" ]]; then
  echo "ace-connect socket already exists for slug=$slug: $socket_path" >&2
  echo "choose another --slug or remove the stale socket" >&2
  exit 1
fi

mkdir -p "$log_dir"
safe_slug=$(printf '%s' "$slug" | tr -c 'A-Za-z0-9_.-' '_')
server_log="$log_dir/$safe_slug.server.log"
bridge_log="$log_dir/$safe_slug.bridge.log"
: >"$server_log"
: >"$bridge_log"

server_pid=""
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
  terminate_process "$server_pid" "codex app-server"
  rm -f "$rendezvous_path"
}
trap cleanup EXIT INT TERM

cd "$cwd"
codex app-server --listen "ws://127.0.0.1:0" >"$server_log" 2>&1 &
server_pid=$!

server_url=""
polls=$(( (startup_timeout_ms + 99) / 100 ))
for ((attempt = 0; attempt < polls; attempt += 1)); do
  if [[ -s "$server_log" ]]; then
    if server_url=$(grep -E -m1 -o 'ws://127\.0\.0\.1:[0-9]+' "$server_log"); then
      [[ -n "$server_url" ]] && break
    fi
  fi
  if ! kill -0 "$server_pid" 2>/dev/null; then
    echo "codex app-server exited before printing URL; log follows:" >&2
    cat "$server_log" >&2
    exit 1
  fi
  sleep 0.1
done

if [[ -z "$server_url" ]]; then
  echo "timed out waiting for codex app-server URL; log follows:" >&2
  cat "$server_log" >&2
  exit 1
fi

mkdir -p "$socket_dir"
printf '%s\n' "$server_url" >"$rendezvous_path"

"$bridge_script" \
  --app-url "$server_url" \
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

echo "codex app-server=$server_url ace-connect slug=$slug bridge-log=$bridge_log" >&2
echo "app-server url published at $rendezvous_path" >&2
echo "ace-connect socket binds after the TUI creates a loaded thread" >&2

tui_status=0
codex --remote "$server_url" --no-alt-screen || tui_status=$?

if [[ -n "$bridge_pid" ]] && ! kill -0 "$bridge_pid" 2>/dev/null; then
  bridge_status=0
  wait "$bridge_pid" 2>/dev/null || bridge_status=$?
  bridge_pid=""
  if [[ "$bridge_status" -ne 0 ]]; then
    echo "ace-connect bridge exited with status $bridge_status; log follows:" >&2
    cat "$bridge_log" >&2
  fi
fi

exit "$tui_status"
