# ace-connect — Codex backend (experimental)

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers Codex-specific listen/send wiring.

**Status: experimental.** There are two distinct Codex cases:

- Codex tool-harness sessions, where the agent can run shell commands through
  `exec_command` / `write_stdin`.
- Codex CLI `app-server` + remote TUI sessions, where a sidecar can speak the
  app-server JSON-RPC protocol.

Do not assume a detached background listener will notify a Codex tool-harness agent.
As of the 2026-05-09 test session, output from a long-running PTY listener only
surfaced after an explicit `write_stdin` poll. The working tool-harness pattern is a
blocking one-shot receive, process the returned line, then re-arm.

## Tool-Harness Receive

Use this path when you are already inside an interactive Codex session with command
tools and need peer messages to make the agent act without the human relaying them.

1. Pick the slug from `../SKILL.md`, normally `<workspace>.codex`.
2. Ask the peer to send only after the socket is armed, or ask it to retry until the
   socket exists.
3. Run one blocking receive command with a generous timeout:

   ```sh
   dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
   slug="school.codex"
   sock="$dir/$slug.sock"

   mkdir -p "$dir"
   chmod 700 "$dir"
   rm -f "$sock"
   socat -u "UNIX-LISTEN:$sock,unlink-early" -
   ```

4. When the tool call returns, parse the single line, act on it, optionally reply to
   the peer, and immediately re-arm with the same command if more work is expected.

This is intentionally one-shot. A persistent command such as
`socat UNIX-LISTEN:<path>,fork -` proves the socket can receive data, but in the
current Codex tool harness its output is pull-based and does not surface to the agent
until the session is polled. One-shot receive makes the shell command exit on the
message, so the tool result returns to the agent's active turn.

Known trade-offs:

- There is a small gap between messages while the agent processes and re-arms.
- Concurrent senders can race; keep test messages serialized.
- If no message arrives before the tool timeout, re-run the one-shot receive.
- This is an active wait pattern for the current turn, not a daemon that can wake an
  idle model after the assistant has already sent a final response.

## Tool-Harness Send

Use the shared contract. This path worked from Codex to a Claude peer over
`school.claude.sock`:

```sh
dir="${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages"
printf 'from=%s\tto=%s\tbody=%s\n' "$ME" "$PEER" "$MSG" \
  | socat - "UNIX-CONNECT:$dir/$PEER.sock"
```

`socat` exiting with code 0 confirms the write/connect side. It does not prove the
peer acted on the line; ask the peer to reply if you need an end-to-end ack.

## App-Server Architecture

Codex can also be split into server + TUI client similar to OpenCode:

- `codex app-server --listen <URL>` — long-running server speaking the Codex
  app-server JSON-RPC protocol. `--listen` accepts `stdio://`, `unix://PATH`, or
  `ws://IP:PORT`.
- `codex --remote ws://IP:PORT` — TUI client connecting to the app-server. The TUI's
  `--remote` option accepts `ws://` / `wss://` per `codex --help`.

Multiple clients can speak to one app-server. This is the app-server bridge seam: TUI
is one client, the ace-connect inbound bridge is another, both talking JSON-RPC about
the same thread.

## Protocol Discovery

Generate the schema before wiring app-server injection:

```sh
codex app-server generate-json-schema --experimental --out /tmp/codex-protocol
ls /tmp/codex-protocol
```

Look at:

- `ClientRequest.json` — RPCs the client, TUI, or bridge can issue.
- `ClientNotification.json` — fire-and-forget client-to-server messages.
- `codex_app_server_protocol.v2.schemas.json` — combined schema, easiest single
  reference.
- `v2/TurnStartParams.json` — params for starting a user turn.

The 2026-05-09 schema shows the user-turn request as:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "turn/start",
  "params": {
    "threadId": "<thread-id>",
    "input": [
      { "type": "text", "text": "<incoming ace-connect line>" }
    ]
  }
}
```

Use `thread/loaded/list`, `thread/list`, `thread/read`, and `thread/turns/list` to
discover candidate threads. Confirm against the generated schema in the installed
Codex version; the app-server API is still experimental.

## App-Server Receive

Goal: incoming lines on `<dir>/<slug>.sock` become user messages in the running TUI's
current thread.

For an idle local Codex model that peers can wake without an attached TUI, prefer the
bundled proof-of-concept bridge:

```sh
node skills/ace-connect/scripts/codex-app-bridge.mjs \
  --slug school.codex-app \
  --model gpt-5.4-mini \
  --effort low \
  --sandbox workspace-write
```

The script starts `codex app-server`, creates one thread, binds
`<dir>/<slug>.sock`, injects each incoming ace-connect line as `turn/start`, and
replies to the sender's `<from>.sock` with the final assistant message. This was
verified on 2026-05-09 with a Claude peer sending to `school.codex-app-test.sock` and
receiving `CLAUDE_BRIDGE_READY`.

Steps on session start:

1. Start the app-server on a free localhost port:

   ```sh
   codex app-server --listen ws://127.0.0.1:0
   ```

   Capture the bound URL from startup output.

2. Start the TUI:

   ```sh
   codex --remote ws://127.0.0.1:<P>
   ```

3. Identify the current TUI thread id. Start with `thread/loaded/list` and
   `thread/list` filtered to the current cwd. If more than one thread is loaded, ask
   the user which one to target.

4. Spawn a sidecar bridge process that listens on `<dir>/<slug>.sock`, opens or
   reuses a websocket connection to the app-server, and sends `turn/start` with the
   captured `threadId` for each incoming line.

Reference sidecar shape, with method and params verified from the generated schema:

```python
import asyncio
import json
import socket

import websockets

WS = "ws://127.0.0.1:<P>"
THREAD = "<thread-id>"
SOCK = "<dir>/<slug>.sock"


async def forward(line, ws):
    await ws.send(json.dumps({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "turn/start",
        "params": {
            "threadId": THREAD,
            "input": [{"type": "text", "text": line}],
        },
    }))
    print(await ws.recv())


async def main():
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.bind(SOCK)
    s.listen()
    async with websockets.connect(WS) as ws:
        loop = asyncio.get_event_loop()
        while True:
            conn, _ = await loop.sock_accept(s)
            data = (await loop.sock_recv(conn, 65536)).decode().strip()
            if data:
                await forward(data, ws)
            conn.close()


asyncio.run(main())
```

Prefer a tiny script for app-server bridging. Pure shell is awkward because JSON-RPC
framing over websockets is the hard part, not the Unix socket receive.

## Open Questions

Refine this file as answers land:

1. Exact reliable way to identify the currently attached TUI thread when multiple
   threads are loaded for one app-server.
2. Whether the same thread can accept input concurrently from TUI and bridge without
   state corruption, or whether a serializing lock is required.
3. Whether `unix://PATH` listen mode can replace the websocket app-server path for
   bridge clients. The TUI still needs `ws://` / `wss://` for `--remote`.
