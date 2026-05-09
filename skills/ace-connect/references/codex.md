# ace-connect — Codex backend (experimental)

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers Codex-specific listen/send wiring.

**Status: experimental.** There are two distinct Codex cases:

- Codex tool-harness sessions, where the agent runs shell commands through
  `exec_command` / `write_stdin`.
- Codex CLI `app-server` + remote TUI sessions, where a sidecar speaks the
  app-server JSON-RPC protocol.

Detached background listeners do not notify a Codex tool-harness agent — output
from a long-running PTY listener only surfaces after an explicit `write_stdin`
poll. The working tool-harness pattern is a blocking one-shot receive, process
the returned line, then re-arm.

## Tool-Harness Receive

Use this when you are inside an interactive Codex session with command tools
and need peer messages to act without the human relaying them.

1. Pick the slug from `../SKILL.md`, normally `<workspace>.codex`.
2. Ask the peer to send only after the socket is armed, or to retry until the
   socket exists.
3. Run one blocking receive command:

   ```sh
   dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
   slug="school.codex"
   sock="$dir/$slug.sock"

   mkdir -p "$dir"
   chmod 700 "$dir"
   rm -f "$sock"
   socat -u "UNIX-LISTEN:$sock,unlink-early" -
   ```

4. When the tool call returns, parse the line, act, optionally reply to the
   peer, and immediately re-arm if more work is expected.

This is intentionally one-shot. A persistent `socat UNIX-LISTEN:<path>,fork -`
proves the socket can receive data, but its output is pull-based and does not
surface to the agent until the session is polled. One-shot receive makes the
shell command exit on the message so the tool result returns to the active turn.

Trade-offs:

- Small gap between messages while the agent processes and re-arms.
- Concurrent senders can race; serialize tests.
- Active wait pattern for the current turn, not a daemon. Cannot wake an idle
  model after the assistant has emitted a final response.

## Tool-Harness Send

Use the shared `scripts/send.sh FROM TO BODY`.

## App-Server Architecture

Codex can split into server + TUI client similar to OpenCode:

- `codex app-server --listen <URL>` — long-running server speaking the
  app-server JSON-RPC protocol. `--listen` accepts `stdio://`, `unix://PATH`,
  or `ws://IP:PORT`.
- `codex --remote ws://IP:PORT` — TUI client; only `ws://` / `wss://`.

Multiple clients can speak to one app-server. TUI is one client, the
ace-connect bridge is another, both talking JSON-RPC about the same thread.

## Interactive TUI launcher

```sh
skills/ace-connect/scripts/codex.sh --slug school.codex
```

Boots `codex app-server`, runs `codex-app-bridge.sh` (bash + websocat + jq)
against the printed URL, then attaches `codex --remote --no-alt-screen` in
the foreground. The bridge waits for the TUI to register a loaded thread
before binding the ace-connect socket. All background processes are torn down
when the TUI exits or the shell is signalled.

Flags: `--slug`, `--cwd`. Run from the project root so relative paths resolve.
Logs are written under `${CODEX_BRIDGE_LOG_DIR:-${TMPDIR:-/tmp}/ace-connect-codex}`.

Requires `websocat`, `jq`, `socat` on PATH (and `codex`, of course).

## Manual three-terminal flow

To attach to an already-running app-server:

```sh
# Terminal 1
codex app-server --listen ws://127.0.0.1:0

# Terminal 2, using the printed URL
codex --remote ws://127.0.0.1:<P> --no-alt-screen

# Terminal 3, after the TUI has started and created one loaded thread
skills/ace-connect/scripts/codex-app-bridge.sh \
  --app-url ws://127.0.0.1:<P> \
  --slug school.codex \
  --wait-for-loaded-thread
```

Without `--wait-for-loaded-thread`, the bridge picks the first loaded thread
and falls back to `thread/start` when none exists. If the app-server already
has a stale loaded thread from a prior session, the bridge claims it without
prompting; pass `--thread-id` to be explicit or restart the app-server first.

## Protocol Discovery

Generate the schema before extending the bridge:

```sh
codex app-server generate-json-schema --experimental --out /tmp/codex-protocol
```

Combined schema lives at
`/tmp/codex-protocol/codex_app_server_protocol.v2.schemas.json` (~430 defs).
The bridge currently uses `initialize`, `initialized`, `thread/loaded/list`,
`thread/start`, `turn/start`. Notable methods we don't yet use:
`turn/steer` (mid-turn input injection), `thread/injectItems` (model-visible
history append), `turn/interrupt`, `ThreadStatusChangedNotification` (push
event when a thread becomes idle), `fs/watch`, the hook system
(`preToolUse`, `postToolUse`, `stop`, `sessionStart`, `userPromptSubmit`).

## Open Questions

1. How to identify the currently attached TUI thread when multiple are loaded.
2. Whether the same thread can accept input concurrently from TUI and bridge
   without state corruption.
3. Whether `turn/steer` is a better fit than `turn/start` for ace-connect
   injection (no need to wait for idle).
