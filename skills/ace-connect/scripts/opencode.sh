#!/usr/bin/env bash
set -euo pipefail

# opencode.sh — start the primary interactive OpenCode TUI session for
# ace-connect. Boots `opencode serve` in the background, attaches the TUI in the
# foreground, and runs a bridge that turns inbound socket lines into user
# messages in the TUI's session. All background processes are cleaned up on exit.

slug=""
cwd="$PWD"

usage() {
  cat <<'USAGE'
Usage: opencode.sh [--cwd DIR] [--slug NAME]

Options:
  --cwd DIR     working directory for the server and bridge (default: $PWD)
  --slug NAME   override the ace-connect slug (default: derived from --cwd as
                <parent>.<workdir>.opencode per the ace-connect convention)

Environment:
  OPENCODE_SERVER_PASSWORD    basic-auth password, if the server requires one
  ACE_OPENCODE_MESSAGE_PATH   prompt endpoint template; {session} is
                              substituted (default: /api/session/{session}/prompt)
  ACE_OPENCODE_STARTUP_TIMEOUT_MS   server/session wait budget (default: 30000)
  ACE_OPENCODE_LOG_DIR        log directory (default: $TMPDIR/ace-connect-opencode)
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

for tool in opencode curl jq socat; do
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
# it, so it isn't a free parameter. Derive <parent>.<workdir>.opencode from cwd.
if [[ -z "$slug" ]]; then
  slug="$(basename -- "$(dirname -- "$cwd")").$(basename -- "$cwd").opencode"
fi

startup_timeout_ms="${ACE_OPENCODE_STARTUP_TIMEOUT_MS:-30000}"
if ! [[ "$startup_timeout_ms" =~ ^[1-9][0-9]*$ ]]; then
  echo "ACE_OPENCODE_STARTUP_TIMEOUT_MS must be a positive integer" >&2
  exit 1
fi
polls=$(( (startup_timeout_ms + 99) / 100 ))
# Short window for "did attach create a brand-new session?" before falling back
# to the newest session in this workdir. Long enough for the TUI to register,
# short enough that a resume isn't stuck behind the full startup budget.
new_session_polls=50

# Verified against the server's own /doc: {sessionID}/message is GET-only and
# posting goes to /prompt with a PromptInput body.
message_path_tmpl="${ACE_OPENCODE_MESSAGE_PATH:-/api/session/{session}/prompt}"
log_dir="${ACE_OPENCODE_LOG_DIR:-${TMPDIR:-/tmp}/ace-connect-opencode}"
socket_dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
socket_path="$socket_dir/$slug.sock"
pid_path="$socket_dir/$slug.pid"

mkdir -p "$socket_dir"
chmod 700 "$socket_dir"

if [[ -f "$pid_path" ]]; then
  existing=$(cat "$pid_path" 2>/dev/null || true)
  if [[ -n "$existing" ]] && kill -0 "$existing" 2>/dev/null; then
    echo "engine already running for slug=$slug (pid $existing): $socket_path" >&2
    exit 1
  fi
  rm -f "$pid_path" "$socket_path"
fi

mkdir -p "$log_dir"
safe_slug=$(printf '%s' "$slug" | tr -c 'A-Za-z0-9_.-' '_')
server_log="$log_dir/$safe_slug.server.log"
bridge_log="$log_dir/$safe_slug.bridge.log"
: >"$server_log"
: >"$bridge_log"

server_pid=""
bridge_pid=""
watchdog_pid=""

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
  terminate_process "$watchdog_pid" "ace-connect watchdog"
  terminate_process "$bridge_pid" "ace-connect bridge"
  terminate_process "$server_pid" "opencode serve"
  rm -f "$socket_path" "$pid_path"
}
trap cleanup EXIT INT TERM

# Claim the slug before the multi-second server boot. Writing it after would
# leave a window where a second launch passes the staleness check above and both
# engines race for the same socket.
echo "$$" >"$pid_path"

cd "$cwd"
opencode serve --port 0 --print-logs --log-level INFO >"$server_log" 2>&1 &
server_pid=$!

# Match any loopback spelling the server logs — 127.0.0.1, localhost, 0.0.0.0 —
# rather than assuming one.
server_url=""
for ((attempt = 0; attempt < polls; attempt += 1)); do
  if [[ -s "$server_log" ]]; then
    url_re='http://(127\.0\.0\.1|0\.0\.0\.0|localhost):[0-9]+'
    if server_url=$(grep -E -m1 -o "$url_re" "$server_log"); then
      server_url=${server_url/0.0.0.0/127.0.0.1}
      [[ -n "$server_url" ]] && break
    fi
  fi
  if ! kill -0 "$server_pid" 2>/dev/null; then
    echo "opencode serve exited before printing its URL; log follows:" >&2
    cat "$server_log" >&2
    exit 1
  fi
  sleep 0.1
done

if [[ -z "$server_url" ]]; then
  echo "timed out waiting for the opencode server URL; log follows:" >&2
  cat "$server_log" >&2
  exit 1
fi

# bash 3.2 (macOS system bash) treats "${arr[@]}" on an empty array as an unbound
# variable under `set -u`. Guard every expansion with the +alternate form.
curl_auth=()
if [[ -n "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
  curl_auth=(--user "opencode:$OPENCODE_SERVER_PASSWORD")
fi

list_sessions() {
  curl -sS ${curl_auth[@]+"${curl_auth[@]}"} "$server_url/session" 2>/dev/null \
    | jq -c 'if type=="array" then . else (.sessions // []) end' 2>/dev/null || true
}

list_session_ids() {
  list_sessions | jq -r '.[].id // empty' 2>/dev/null || true
}

# Newest session belonging to this workdir. Scoping by directory is what keeps
# us off a live session in some other project; without it "newest" is a coin
# flip across every project the server holds.
newest_session_here() {
  list_sessions | jq -r --arg d "$cwd" \
    '[.[] | select(.directory == $d)] | max_by(.time.updated // 0) | .id // empty' \
    2>/dev/null || true
}

# The bridge runs as a child so the TUI can own the foreground. It waits for the
# TUI to create its session, binds the socket, then posts each inbound line.
bridge() {
  local sid="" i pre

  # `opencode attach` may either create a session or resume an existing one, so
  # neither rule works alone. Prefer an id that wasn't there before the TUI
  # attached — unambiguous when attach creates. Failing that, fall back to the
  # newest session in this workdir, which is the resumed one.
  pre=$(list_session_ids)

  for ((i = 0; i < new_session_polls; i += 1)); do
    # An empty snapshot prints one blank line; -x can only match it against a
    # blank id, so every real id still survives -v.
    sid=$(list_session_ids | grep -vxFf <(printf '%s\n' "$pre") | head -1 || true)
    [[ -n "$sid" ]] && break
    sleep 0.1
  done

  if [[ -z "$sid" ]]; then
    for ((i = 0; i < polls; i += 1)); do
      sid=$(newest_session_here)
      [[ -n "$sid" ]] && break
      sleep 0.1
    done
  fi

  if [[ -z "$sid" ]]; then
    echo "no opencode session found for $cwd after waiting for the TUI" >&2
    return 1
  fi

  local url="$server_url${message_path_tmpl//\{session\}/$sid}"
  echo "ace-connect opencode bridge: slug=$slug session=$sid endpoint=$url" >&2

  # One socat per message — same rebind-gap behavior as every other ace-connect
  # engine. Re-bind after each accepted message.
  local line body
  while :; do
    rm -f "$socket_path"
    if ! line=$(socat -u "UNIX-LISTEN:$socket_path,unlink-early" - 2>/dev/null); then
      break
    fi
    [[ -z "$line" ]] && continue

    # Carry the skill pointer with the message; the model reads the rules there.
    body=$(jq -nc --arg t "ace-connect
$line" '{prompt:{text:$t}}')

    if ! curl -sS -f -X POST "$url" ${curl_auth[@]+"${curl_auth[@]}"} \
      -H 'content-type: application/json' --data "$body" >/dev/null; then
      echo "POST failed for line: $line" >&2
    fi
  done
}

bridge >>"$bridge_log" 2>&1 &
bridge_pid=$!

# Brief settle before handing the terminal to the TUI, so a bridge that dies on
# startup reports here rather than silently swallowing every inbound message.
sleep 0.5

if ! kill -0 "$bridge_pid" 2>/dev/null; then
  echo "ace-connect bridge exited before TUI start; log follows:" >&2
  cat "$bridge_log" >&2
  exit 1
fi

# The TUI outlives the bridge, so a bridge that dies mid-session would leave the
# pidfile standing and discover.sh would keep advertising an engine nobody can
# reach. Retract the slug the moment the bridge is gone.
(
  while kill -0 "$bridge_pid" 2>/dev/null; do sleep 1; done
  rm -f "$pid_path" "$socket_path"
  echo "ace-connect bridge for $slug exited; slug retracted (see $bridge_log)" >&2
) &
watchdog_pid=$!

echo "opencode server=$server_url ace-connect slug=$slug bridge-log=$bridge_log" >&2
echo "ace-connect socket binds once the TUI session is resolved" >&2

tui_status=0
opencode attach "$server_url" || tui_status=$?

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
