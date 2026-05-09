#!/usr/bin/env bash
set -euo pipefail

# codex-interactive-bridge.sh — start one Codex TUI session that can also
# receive ace-connect messages from peers. Boots `codex app-server` in the
# background, runs the ace-connect bridge against it, and attaches the TUI
# in the foreground. All background processes are cleaned up on exit.

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
bridge_script="$script_dir/codex-app-bridge.mjs"

slug="school.codex"
effort="low"
model=""
cwd="$PWD"

usage() {
  cat <<'USAGE'
Usage: codex-interactive-bridge.sh [--slug NAME] [--effort LEVEL] [--model MODEL] [--cwd DIR]

Options:
  --slug NAME      ace-connect slug for incoming peer messages (default: school.codex)
  --effort LEVEL   reasoning effort passed to bridge (default: low)
  --model MODEL    model name forwarded to bridge when starting a fresh thread
  --cwd DIR        working directory for app-server and bridge (default: $PWD)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug)   slug="${2:?--slug requires a value}"; shift 2 ;;
    --effort) effort="${2:?--effort requires a value}"; shift 2 ;;
    --model)  model="${2:?--model requires a value}"; shift 2 ;;
    --cwd)    cwd="${2:?--cwd requires a value}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ ! -f "$bridge_script" ]]; then
  echo "bridge script not found at: $bridge_script" >&2
  exit 1
fi
if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found in PATH" >&2
  exit 1
fi
if ! command -v node >/dev/null 2>&1; then
  echo "node not found in PATH" >&2
  exit 1
fi

cwd=$(cd -- "$cwd" && pwd)

tmpdir=$(mktemp -d -t codex-bridge.XXXXXX)
app_log="$tmpdir/app-server.log"

app_pid=""
bridge_pid=""

cleanup() {
  trap - EXIT INT TERM
  if [[ -n "$bridge_pid" ]] && kill -0 "$bridge_pid" 2>/dev/null; then
    kill "$bridge_pid" 2>/dev/null || true
    wait "$bridge_pid" 2>/dev/null || true
  fi
  if [[ -n "$app_pid" ]] && kill -0 "$app_pid" 2>/dev/null; then
    kill "$app_pid" 2>/dev/null || true
    wait "$app_pid" 2>/dev/null || true
  fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

(cd "$cwd" && codex app-server --listen "ws://127.0.0.1:0") >"$app_log" 2>&1 &
app_pid=$!

url=""
for _ in $(seq 1 100); do
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

bridge_args=(--app-url "$url" --slug "$slug" --effort "$effort" --cwd "$cwd")
if [[ -n "$model" ]]; then
  bridge_args+=(--model "$model")
fi

node "$bridge_script" "${bridge_args[@]}" >"$tmpdir/bridge.log" 2>&1 &
bridge_pid=$!

# Brief settle before handing the terminal to the TUI so the bridge has time
# to bind its socket. Adjust if you see "no such socket" right after launch.
sleep 0.5

if ! kill -0 "$bridge_pid" 2>/dev/null; then
  echo "ace-connect bridge exited before TUI start; log follows:" >&2
  cat "$tmpdir/bridge.log" >&2
  exit 1
fi

cd "$cwd"
codex --remote "$url" --no-alt-screen
