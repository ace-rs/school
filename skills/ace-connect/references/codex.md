# ace-connect — Codex backend (experimental)

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers Codex-specific start (receive) and send wiring.

**Status: experimental.** There are two distinct Codex cases:

- Codex tool-harness sessions, where the agent runs shell commands through
  `exec_command` / `write_stdin`.
- Codex CLI `app-server` + remote TUI sessions, where a sidecar speaks the
  app-server JSON-RPC protocol.

Detached background receivers do not notify a Codex tool-harness agent — output
from a long-running PTY receiver only surfaces after an explicit `write_stdin`
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
The server holds a per-thread subscriber set and fans every thread event out
to all connections, so a **non-owning client sees events from turns it did not
start** — the basis for a bridge that observes what the human does.

A from-scratch redesign of the bridge (drop the stale assumptions below, use
`turn/steer`, relay real replies) is recorded in
`docs/scratch/2026-07-07-codex-app-server-bridge-redesign.md`. The sections
below still describe what `codex-app-bridge.sh` does **today**, not that target.

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

## Protocol reference

Generate the schema before extending the bridge:

```sh
codex app-server generate-json-schema --experimental --out /tmp/codex-protocol
```

Combined schema lives at
`/tmp/codex-protocol/codex_app_server_protocol.v2.schemas.json` (~430 defs).
Wire dialect is JSON-RPC **without** a `jsonrpc` field; all v2 params are
`camelCase`. v1 survives as the handshake plus legacy approval/config types
(v1 `conversationId`; v2 `threadId`); everything thread/turn-shaped is v2.
Experimental methods/fields gate per-item behind `capabilities.experimentalApi
= true` in `initialize`.

Recommended stable surface for the bridge:

```
initialize → thread/loaded/list → thread/resume {threadId}
  → receive notifications → turn/start | turn/steer {expectedTurnId} | turn/interrupt
```

- `thread/loaded/list` — thread ids live in memory now; best "what is the TUI
  running" probe. There is no `thread/current`.
- `thread/resume {threadId}` — attaches **and subscribes**, streaming history
  then live events. **Requires an on-disk rollout**; a never-run thread (zero
  turns) has none and cannot be resumed.
- `turn/start {threadId, input}` — spins a fresh turn when idle; on a thread
  with an active turn it **merges into it** (unguarded mid-turn injection).
- `turn/steer {threadId, input, expectedTurnId}` — `expectedTurnId` is
  required and non-empty; the id comes only from a `turn/started` notification
  (so steer depends on `thread/resume` succeeding). Thread-scoped: a second
  client can steer the TUI's turn.
- `turn/interrupt {threadId, turnId}`, `thread/inject_items` (model-visible
  history append without a turn), `thread/unsubscribe`.

Full findings — file:line refs, transport internals, live-validation log — in
`docs/scratch/2026-07-07-codex-app-server-bridge-redesign.md`.

## Resolved questions

1. **Identify the TUI's thread among many loaded** — `thread/loaded/list`
   intersected with a metadata filter (`cwd` + `ThreadStatus`). "Active" is a
   per-thread status (`NotLoaded | Idle | SystemError | Active`), not a
   server-global selection.
2. **Concurrent input without corruption** — the server serializes per thread
   and rejects unsafe injection with a typed error rather than corrupting
   state: `ActiveTurnNotSteerable {turnKind: review|compact}` when the active
   turn is a `/review` or manual `/compact` (the only non-steerable kinds).
   No plugin-style broker needed — the shared `--listen` socket makes
   serialization the server's job.
3. **`turn/steer` vs `turn/start`** — steer is strictly safer: it fails loudly
   (`ExpectedTurnMismatch`) instead of racing blind, and needs no wait for
   idle. Cost: it is gated on `thread/resume` (rollout) plus a known active
   `turnId`. Use `turn/steer` when a turn is live, `turn/start` when idle.

## Open items

Carried forward from the redesign note (§6); each still a decision, not settled
here:

- **Reply-back contract** — relay codex's `item/agentMessage` + `turn/completed`
  to the original sender over the ace-connect bus, with completion inference
  (subagent turns make `turn/completed` unreliable).
- **Sandbox/approval derivation** — cwd + sandbox come from the *server's*
  launch, not the TUI's flags; every injected peer turn inherits the human's
  powers. Derive the posture from ace-connect control-vs-autonomous mode.
- **Live `turn/steer` validation** — not yet exercised against a thread
  mid-turn (the test thread had no active turn and no rollout). Validate before
  documenting steer as the primary path.
