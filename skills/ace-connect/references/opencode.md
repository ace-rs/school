# ace-connect — OpenCode backend

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers OpenCode-specific listen/send wiring.

## Architecture

OpenCode separates server and TUI:

- `opencode serve --port <P>` — headless server holding sessions, persistence, model
  routing.
- `opencode attach http://127.0.0.1:<P>` — TUI client; connects to the server and
  drives one session interactively.

External processes can post to the same server's REST API. A message posted to the
session the TUI is attached to surfaces inside that TUI — both agent and human see
it. That is the injection point ace-connect rides on.

## Listening (inbound bridge)

Goal: incoming lines on `<dir>/<slug>.sock` become user messages in the TUI's current
session.

Steps on session start:

1. Start a server on a free port:
   ```
   opencode serve --port 0 --print-logs --log-level INFO &
   ```
   Capture the actual port from the log line (server logs the bound URL).
2. Start the TUI in another terminal: `opencode attach http://127.0.0.1:<P>`.
   Capture the session id (visible in TUI; also queryable via the server's
   `/session` endpoint).
3. Spawn a sidecar bridge that reads the unix socket and POSTs each line as a user
   message to the captured session. Reference shape:
   ```
   socat UNIX-LISTEN:<dir>/<slug>.sock,fork - | while IFS= read -r line; do
     curl -sS -X POST "http://127.0.0.1:<P>/session/<sid>/message" \
       -H 'content-type: application/json' \
       --data "$(jq -nc --arg t "$line" '{parts:[{type:"text",text:$t}]}')"
   done
   ```
4. On shutdown, kill the bridge, kill the server, remove `<slug>.sock`.

The exact endpoint path and request body shape are version-dependent. Verify against
the running server's OpenAPI spec before relying on the snippet above:

```
curl -sS http://127.0.0.1:<P>/doc        # openapi/swagger spec, exact path varies
curl -sS http://127.0.0.1:<P>/session    # list current sessions, find session id
```

If `OPENCODE_SERVER_PASSWORD` is set, the bridge must send basic auth too.

## Sending (outbound)

Use the shared contract — write one line to the peer's `<dir>/<slug>.sock`:

```
printf 'from=%s\tto=%s\tbody=%s\n' "$ME" "$PEER" "$MSG" \
  | socat - UNIX-CONNECT:<dir>/<peer>.sock
```

No OpenCode-specific path needed for sending. The peer's bridge handles translation.

## Notes

- mDNS discovery (`opencode serve --mdns`) is OpenCode's native cross-host story.
  ace-connect ignores it; we are local-only and use the shared dir for discovery.
- Plugins are an alternative injection path (an OpenCode plugin could bind the socket
  and call into the server in-process). Skip unless the sidecar+REST approach proves
  inadequate — extra dependency, separate install/upgrade lifecycle.
- The server outlives any single TUI attach. If the user `Ctrl-C`s the TUI but leaves
  the server up, incoming messages still land in the session and are visible on next
  attach. Decide per-session whether you want this behaviour or strict TUI-bound
  lifetime.
