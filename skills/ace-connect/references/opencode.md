# ace-connect — OpenCode backend

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers OpenCode-specific start (receive) and send wiring.

## Architecture

OpenCode separates server and TUI:

- `opencode serve --port <P>` — headless server holding sessions, persistence, model
  routing.
- `opencode attach http://127.0.0.1:<P>` — TUI client; connects to the server and
  drives one session interactively.

External processes can post to the same server's REST API. A message posted to the
session the TUI is attached to surfaces inside that TUI — both agent and human see
it. That is the injection point ace-connect rides on.

## Starting the engine (inbound bridge)

Goal: incoming lines on `<dir>/<slug>.sock` become user messages in the TUI's current
session.

Run `../scripts/opencode.sh` from the workspace root. One command, one terminal:

```
<base>/scripts/opencode.sh
```

It derives the slug from `$PWD` (`--slug` / `--cwd` override), boots
`opencode serve --port 0` and reads the bound URL from its log, **creates one
session and owns it**, spawns the bridge, writes `<slug>.pid` so `discover.sh`
sees the engine, and runs `opencode attach <url> -s <session>` in the foreground
so the TUI lands on that exact session. Each inbound line is POSTed into the
owned session, prefixed with `ace-connect` so the receiving model loads this
skill. Exit — or `Ctrl-C` — tears down bridge, server, socket, pidfile, and the
owned session.

Requires `opencode`, `curl`, `jq`, `socat` on PATH. Honors
`OPENCODE_SERVER_PASSWORD` as basic auth.

### One owned session, not discovery

`opencode serve` persists sessions across runs, so a server carries a pile of old
sessions (`/session` for this project, `/api/session` globally). The bridge does
**not** scan that pile and guess which one the TUI is on — that guess bound the
bridge to a stale session and ran peer traffic through a headless agent invisible
to the user. Instead: `POST /session` to create one, `opencode attach -s <id>` to
put the TUI on it, `prompt_async` into it. Bridge and TUI are aligned by
construction; there is only ever one live session. It is `DELETE`d on exit so
boots don't accumulate.

Signals that looked usable but aren't: `/api/session/active` returned
`{"data":{}}` even mid-turn; `/global/event` carries a `sessionID` on every event
but activity is not focus — a headless `prompt_async` emits the same `busy`
events as user typing. Driving the TUI prompt box (`/tui/append-prompt` +
`/tui/submit-prompt`) was rejected outright: `append` concatenates onto whatever
the user is typing and `submit` fires the mash as one turn.

### The message route, and why prompt_async

Verified against opencode's own `/doc`, three POST routes exist and only one
fits:

- `POST /session/{id}/prompt_async` — *"start the session if needed, return
  immediately."* This is the one. Body is `{parts:[{type:"text",text:…}]}`.
- `POST /api/session/{id}/prompt` — admits the input (200) but schedules **no**
  agent loop; messages pile up as unread user turns and nothing runs.
- `POST /session/{id}/message` — runs the turn but **streams the whole
  response**, blocking the serial accept loop for its entire duration.

`{id}/message` is GET-only on the `/api` prefix, so don't confuse the two. If a
future version moves the route (bridge log shows `POST failed`), inspect `/doc`
and override:

```
curl -sS http://127.0.0.1:<P>/doc     # openapi spec; find the run-and-return route
ACE_OPENCODE_MESSAGE_PATH='/session/{session}/prompt_async' <base>/scripts/opencode.sh
```

Bridge and server logs land in `$TMPDIR/ace-connect-opencode/` — the script prints
the bridge log path on start.

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
- A server can outlive any single TUI attach, but `opencode.sh` owns the one it
  starts and kills it on exit — engine lifetime is TUI-bound, matching every other
  ace-connect backend. To keep a server up across attaches, run it yourself and
  don't use the script.
