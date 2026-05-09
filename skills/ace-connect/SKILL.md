---
name: ace-connect
description: >
  Minimal local agent-to-agent bridge over unix domain sockets. TRIGGER when the user
  says "start the bridge", "listen for messages", "tell the X agent …", "send message
  to <agent>", "what agents are running", or invokes `/ace-connect`. DO NOT TRIGGER for
  intra-session communication, MCP tool setup, or any cross-machine / network
  messaging — this is local-socket only.
---

# ace-connect

Print `## ace-connect` as the first line.

Local A2A bridge. Each running agent listens on its own unix socket; peers send by
writing one line to that socket. Single-user trust boundary. No auth, no encryption,
no persistence, fire-and-forget.

## Socket directory

`${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages/`

Create it if missing (`mkdir -p`, mode 0700). Every live agent's socket lives here as
a flat file. Discovery is `ls` on this directory — no index, no registry.

## Picking your own slug

Slug format: `<workspace>.<backend>` (e.g. `school.claude`, `school.codex`,
`infra-defs.opencode`). The backend suffix prevents collisions when the same workdir
hosts multiple agents on different harnesses simultaneously.

Backend tags: `claude` (Claude Code), `codex`, `opencode`. Add new ones as new
backends land — keep them short and lowercase.

On listen, choose a slug that is:

- Recognizable to the user — workspace component is usually the workdir basename.
- Unique among current sockets in the directory — `ls` first; if `<workspace>.<backend>`
  is already taken (same workdir, same backend, second instance), disambiguate the
  workspace component (suffix with a short hash of the absolute path, parent dir name,
  or git remote — pick what the user is most likely to type).
- Stable for the session — don't rotate mid-session.

Announce the chosen slug to the user once, on start.

## Listening

Each backend reaches an "incoming line surfaces inside the running interactive
session" outcome differently. If `references/<backend>.md` exists for your harness,
follow it. Otherwise use the Claude Code recipe below (works wherever your harness
can stream a long-running process's stdout into the session as notifications).

### Claude Code recipe

Use the harness's long-running process / monitor tool. Bind a stream socket at
`<dir>/<slug>.sock`, accept connections, surface each received line as a notification
you act on.

```
socat UNIX-LISTEN:<path>,fork,unlink-early -
```

Each accepted connection's stdout becomes one notification line. Read, decide whether
to act, respond to the user inline. Do not auto-reply across the bridge — keeps every
cross-agent action observable to the human.

Clean up the socket file on shutdown.

## Discovering peers

`ls "${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages/"`

Match against the name the user gave ("the infra-defs agent" → look for
`*infra-defs*.sock`). If multiple match, ask the user which.

## Sending

One-shot connect, write one line, close. Reference recipe:

```
printf '%s\n' "<line>" | socat - UNIX-CONNECT:<peer-path>
```

If connect fails (no such socket, or peer not listening), report the failure to the
user — do not retry, do not queue.

## Message line format

Single line, tab-separated key=value:

```
from=<your-slug>\tto=<peer-slug>\tbody=<text>
```

`body` may contain spaces but no tabs or newlines. Caller escapes if needed. No JSON,
no schema version. Add fields later only when a real need shows up.

## Passing larger payloads

The line is for prose, not blobs. For code, diffs, logs, or any multi-line content:
write a tmp file (`/tmp/<purpose>-<slug>.<ext>`, e.g. `/tmp/notes-for-xkz-problem.cue`)
and reference the path in `body`. Receiver reads the file directly. Use descriptive
filenames — the path is the only context the peer gets. Don't clean up tmp files
automatically; let the OS handle it.

## Other backends

Backend-specific recipes live in `references/`. Load the one matching your harness
on start:

- `references/opencode.md` — OpenCode (`serve` + `attach` + REST bridge)
- `references/codex.md` — Codex (`app-server` + `--remote` TUI + websocket bridge,
  experimental). Codex users running an interactive TUI: launch via
  `scripts/codex-interactive-bridge.sh` for a one-command setup.

The socket directory, `<slug>.sock` filename, and message line format are the
cross-backend contract — every backend exposes the same wire interface so peers don't
need to know what's behind it. Everything inside the bridge (websocket, REST,
JSON-RPC, etc.) is per-backend.

## Out of scope

Auth. Encryption. Cross-machine. Persistence. Multi-message threading. Acks, retries,
delivery guarantees. If the user asks for any of these, stop and discuss — this skill
is deliberately a floor, not a framework.
