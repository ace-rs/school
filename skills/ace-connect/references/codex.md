# ace-connect — Codex backend (experimental)

Read `../SKILL.md` first for the shared contract (socket dir, slug, wire format,
out-of-scope). This file covers the Codex-specific receive side: how a codex
session gets on the bus. Send and discover are backend-independent.

Codex speaks the **app-server JSON-RPC protocol**. The supported topology is
server + client: a long-running `codex app-server` that many clients attach to,
with the ace-connect bridge as one client and the interactive TUI as another.
Both talk JSON-RPC about the same thread; the server holds a per-thread
subscriber set and fans every thread event out to all connections, so a
**non-owning client sees events from turns it did not start** — the basis for a
bridge that observes what the human does.

Two facts settled by live validation, load-bearing for everything below:

- **The server owns cwd and sandbox**, not the TUI. Every turn — including one a
  peer injects — runs with the powers the *app-server* was launched with. The
  TUI's flags do not scope it.
- **A Homebrew install has no daemon.** `app-server-daemon` is a lifecycle
  wrapper, not the wire; the plain binary is the whole surface.

## Getting a codex session on the bus

Run one command from the workspace root:

```sh
<base>/scripts/codex.sh
```

`<base>` is this skill's base directory (injected when the skill loads); resolve
the concrete path with `ace paths`. The script:

1. **Derives the slug** from cwd per the ace-connect convention
   (`<parent>.<workdir>.codex`, SKILL.md "Picking your own slug") — nothing to
   pass. `--cwd DIR` points it at another workspace; `--slug` overrides only if
   you must.
2. Boots `codex app-server --listen ws://127.0.0.1:0` in the **background**
   (ephemeral port — see rendezvous below).
3. Runs `codex-app-bridge.sh` against it in the **background**; the bridge waits
   for the TUI to register a loaded thread, then binds the ace-connect socket.
4. Attaches `codex --remote --no-alt-screen` in the **foreground** — your actual
   session, the one terminal you'd have opened anyway.

All background processes are torn down when the TUI exits or the shell is
signalled. So ace-connect ignition folds into the one command you run to start
codex — no extra terminals, no tmux.

Requires `codex`, `websocat`, `jq`, `socat` on PATH. Logs land under
`${CODEX_BRIDGE_LOG_DIR:-${TMPDIR:-/tmp}/ace-connect-codex}`.

### Optional: make it your default codex

To have a bare `codex` come up on the bus, add a **new** command — do not shadow
`codex` itself (that breaks `codex app-server`, `codex exec`,
`codex generate-json-schema`, and every other subcommand). Resolve the script
path with `ace paths`, then add to `~/.bashrc` / `~/.zshrc`:

```sh
alias codex-connect="/resolved/path/to/scripts/codex.sh"
```

Or a pass-through function that wraps only the no-arg interactive case:

```sh
codex() { [ $# -eq 0 ] && command /resolved/path/to/scripts/codex.sh || command codex "$@"; }
```

Shorten the name yourself if you like.

## Per-slug rendezvous convention

The app-server binds an **ephemeral** port (`ws://127.0.0.1:0`), so its URL isn't
predictable — and a **fixed** port can't work, because one host runs one
app-server per workspace (the server owns cwd/sandbox), so a codex swarm of N
workspaces needs N distinct addresses. `codex.sh` resolves this by publishing the
live URL to a per-slug file:

```
${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages/<slug>.codex-app.url
```

Deterministic from the slug, removed on exit. The bridge (and a manual TUI) read
the URL from there — the convention is the **file path**, not a port. This is
what lets N codex sessions coexist on one host with zero per-session
configuration. The ace-connect message bus (per-slug unix sockets) already scales
to N slugs; this closes the one gap that didn't — the codex app-server address.

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

## Receiving, reply-back, and reactive scope

**The injected turn carries the skill pointer.** The bridge's `turn/start` wraps the
peer body with the same pointer Claude's Monitor line uses — *arrived via ace-connect;
load the skill, read `references/dialect.md`, act per mode.* The human's codex reads
it, interprets the rules, and acts. This is the codex analogue of `start.sh`'s Monitor
description: transport + pointer, no scripted rule logic.

- **Reply-back is codex's own `send.sh` call**, symmetric with Claude: `turn/start`
  delivers the peer message, codex does the work, codex shells out to `send.sh` to
  reply, and the reply lands async on the sender's socket. The bridge does **not**
  subscribe-and-relay codex's output. Precondition: `send.sh` on PATH inside the
  app-server's sandbox, and codex instructed via the dialect to reply that way.
- **Reactive-only.** A codex on the bus answers peer messages; it does not drive its
  own agenda. So the live path is just get-thread + `turn/start` when idle — no
  `thread/resume`/subscription, no `turn/steer`. Those stay in the protocol reference
  above as available primitives, but the reactive bridge doesn't use them.
- **Sandbox posture is not scripted.** cwd + sandbox come from the server's launch and
  every peer turn inherits them, so launch the app-server at a sensible permissive
  ceiling (`workspace-write` — in-tree room, out-of-tree writes and network blocked as
  a free backstop). Do **not** map ace-connect mode to sandbox flags: a human is always
  at the TUI, and codex applies the control-vs-autonomous and autonomous-safety rules by
  reading this skill and prompting that human. The sandbox is a floor, not the policy
  engine.

## Debug: manual attach

To poke the pieces by hand — attach to an already-running app-server, or run
each stage in its own terminal:

```sh
# Terminal 1 — app-server (ephemeral port; note the printed URL)
codex app-server --listen ws://127.0.0.1:0

# Terminal 2 — TUI client, using the printed URL
codex --remote ws://127.0.0.1:<P> --no-alt-screen

# Terminal 3 — bridge, after the TUI has created one loaded thread
<base>/scripts/codex-app-bridge.sh \
  --app-url ws://127.0.0.1:<P> \
  --slug <slug> \
  --wait-for-loaded-thread
```

Without `--wait-for-loaded-thread`, the bridge picks the first loaded thread and
falls back to `thread/start` when none exists. If the app-server already has a
stale loaded thread from a prior session, the bridge claims it without prompting;
pass `--thread-id` to be explicit or restart the app-server first. This is the
debug path only — the normal path is the single `codex.sh` command above.
