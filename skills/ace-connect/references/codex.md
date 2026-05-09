# ace-connect — Codex backend (experimental)

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers Codex-specific listen/send wiring.

**Status: experimental.** Codex's `app-server` and TUI `--remote` are marked
experimental upstream. Treat the recipe below as a starting hypothesis to refine —
not a verified working pattern. Codex agents reading this file: improve it.

## Architecture

Codex can be split into server + TUI client similar to OpenCode:

- `codex app-server --listen <URL>` — long-running server speaking the Codex
  app-server JSON-RPC protocol. `--listen` accepts `stdio://`, `unix://PATH`, or
  `ws://IP:PORT`.
- `codex --remote ws://IP:PORT` — TUI client connecting to the app-server (TUI's
  `--remote` only accepts `ws://` / `wss://` per `codex --help`).

Multiple clients can speak to one app-server (otherwise `--ws-auth` would not exist).
This is the seam: TUI is one client, the ace-connect inbound bridge is another, both
talking JSON-RPC about the same conversation.

## Protocol discovery

Generate the schema before wiring anything:

```
codex app-server generate-json-schema --out /tmp/codex-protocol
ls /tmp/codex-protocol
```

Look at:

- `ClientRequest.json` — RPCs the client (TUI / bridge) can issue.
- `ClientNotification.json` — fire-and-forget client → server messages.
- `codex_app_server_protocol.v2.schemas.json` — combined schema, easiest single
  reference.

Identify the request that submits a user turn into an existing conversation. Likely
candidates by name pattern: something like `sendUserMessage`, `addUserInput`,
`conversation.submit`, or similar — confirm against the schema, do not guess.

Also identify how to enumerate or create conversations so the bridge knows which
conversationId to attach the incoming line to.

## Listening (inbound bridge)

Goal: incoming lines on `<dir>/<slug>.sock` become user messages in the running TUI's
current conversation.

Steps on session start:

1. Start the app-server on a free localhost port:
   ```
   codex app-server --listen ws://127.0.0.1:0 &
   ```
   Capture the bound URL (printed on stderr at startup — verify).
2. Start the TUI: `codex --remote ws://127.0.0.1:<P>`. Capture the conversation id
   the TUI creates (mechanism: query the app-server, or derive from server-side
   notifications — refine after schema review).
3. Spawn a sidecar bridge process that:
   - Listens on `<dir>/<slug>.sock` via `socat UNIX-LISTEN:<path>,fork`.
   - For each incoming line, opens (or reuses) a websocket connection to the
     app-server.
   - Sends a JSON-RPC request submitting that line as a user message into the
     captured conversationId.
4. On shutdown, kill bridge, kill app-server, remove `<slug>.sock`.

Reference sidecar skeleton (Python, `websockets` package — adapt):

```python
import asyncio, json, socket, websockets

WS = "ws://127.0.0.1:<P>"
CONV = "<conversation-id>"
SOCK = "<dir>/<slug>.sock"

async def forward(line, ws):
    # Replace method + params shape after reading the schema.
    await ws.send(json.dumps({
        "jsonrpc": "2.0", "id": 1,
        "method": "<verified-method>",
        "params": {"conversationId": CONV, "input": line},
    }))
    print(await ws.recv())

async def main():
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.bind(SOCK); s.listen()
    async with websockets.connect(WS) as ws:
        loop = asyncio.get_event_loop()
        while True:
            conn, _ = await loop.sock_accept(s)
            data = (await loop.sock_recv(conn, 65536)).decode().strip()
            if data: await forward(data, ws)
            conn.close()

asyncio.run(main())
```

`socat`-only equivalent is possible but messier — JSON-RPC framing over ws is awkward
to do in shell. Prefer a tiny script.

## Sending (outbound)

Use the shared contract — write one line to the peer's `<dir>/<slug>.sock`:

```
printf 'from=%s\tto=%s\tbody=%s\n' "$ME" "$PEER" "$MSG" \
  | socat - UNIX-CONNECT:<dir>/<peer>.sock
```

The peer's bridge translates into whatever its native injection looks like.

## Open questions for Codex agents reading this

Refine this file as answers land:

1. Exact JSON-RPC method name and params for "submit user message into existing
   conversation". Source: the generated schema.
2. How to obtain the conversation id after TUI startup — does the TUI announce it
   via a server-side notification we can subscribe to from the bridge?
3. Whether the same conversation can accept input concurrently from TUI and bridge
   without state corruption, or whether a serializing lock is required.
4. Whether `unix://PATH` listen mode could replace the `ws://` + bridge combo (TUI
   does not currently accept `unix://` for `--remote`, so this only helps if that
   changes).

Update this file with verified findings and remove the corresponding question.
