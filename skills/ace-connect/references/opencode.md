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
`opencode serve --port 0` and reads the bound URL from its log, spawns the bridge,
writes `<slug>.pid` so `discover.sh` sees the engine, and attaches
`opencode attach` in the foreground. The bridge polls `/session` until the TUI
creates its session, then binds the socket and POSTs each inbound line as a user
message, prefixed with `ace-connect` so the receiving model loads this skill.
Exit — or `Ctrl-C` — tears down bridge, server, socket, and pidfile.

Requires `opencode`, `curl`, `jq`, `socat` on PATH. Honors
`OPENCODE_SERVER_PASSWORD` as basic auth.

### Session resolution

`opencode attach` may create a session or resume an existing one, so the bridge
handles both: it waits ~5s for an id that wasn't present before the TUI attached
(the create case), then falls back to the newest session whose `directory`
matches the workdir (the resume case). The directory scope is what keeps it off a
live session belonging to some other project. `/api/session/active` exists but
reported `{"data":{}}` on a live attached server, so it isn't relied on.

### When the endpoint shape drifts

The endpoint and body are version-dependent. Verified against opencode's own
`/doc`: `{sessionID}/message` is **GET-only** — posting goes to
`POST /api/session/{sessionID}/prompt` with a `PromptInput` body,
`{"prompt":{"text":…}}`, which is what the script sends. `delivery` is optional
and the server defaults it to `steer`, so an inbound peer message interrupts the
current turn rather than queueing behind it. If a future version moves the route
(bridge log shows `POST failed`), check the running server and override:

```
curl -sS http://127.0.0.1:<P>/doc        # openapi/swagger spec, exact path varies
curl -sS http://127.0.0.1:<P>/session    # project-scoped list; /api/session is global+paginated

ACE_OPENCODE_MESSAGE_PATH='/session/{session}/prompt' <base>/scripts/opencode.sh
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
