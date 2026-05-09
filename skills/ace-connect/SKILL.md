---
name: ace-connect
description: >
  Minimal local agent-to-agent bridge over unix domain sockets. TRIGGER when the user
  says "start the bridge", "listen for messages", "tell the X agent …", "send message
  to <agent>", "what agents are running", asks to make Codex receive Claude messages,
  or invokes `/ace-connect`. For interactive Codex TUI sessions, `scripts/codex.sh`
  is the primary launcher. DO NOT TRIGGER for intra-session communication, MCP tool
  setup, or any cross-machine / network messaging — this is local-socket only.
---

# ace-connect

Print `## ace-connect` as the first line.

Local A2A bridge. Each running agent listens on its own unix socket; peers send
one line to that socket. Single-user trust boundary. No auth, no encryption, no
persistence, fire-and-forget.

## Socket directory

`${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages/` — `mkdir -p`, mode 0700. Every
live agent's socket lives here as a flat file. Discovery is `ls`.

## Picking your own slug

Format: `<workspace>.<backend>` (e.g. `school.claude`, `bluepages-infra.codex`).
Backend tags: `claude`, `codex`, `opencode` — short, lowercase.

Workspace component starts from the workdir basename, but include parent segments
when the basename alone is ambiguous (`infra`, `app`, `web`, `api`, `server`,
`cli`, `docs` rarely are unique). `bluepages/infra` and `sso/infra` checked out
side by side need `bluepages-infra.codex` and `sso-infra.codex`.

Before binding, `ls` the directory; if your candidate is taken, add another
parent segment or a short hash of the absolute path. Stable for the session.
Announce it once on start.

## Listening (Claude Code recipe)

Run `scripts/listen.sh <slug>` inside the harness's long-running process /
monitor tool. It binds `<dir>/<slug>.sock`, emits one line per accepted
connection on stdout, and removes the socket on exit.

Underneath: `socat UNIX-LISTEN:<path>,fork,unlink-early -`.

Other backends: load `references/<backend>.md` if present; for Codex with a TUI
use `scripts/codex.sh`.

Don't auto-reply across the bridge — keep every cross-agent action observable
to the human.

## Sending

```
scripts/send.sh FROM TO BODY
```

Strips tabs/CR/LF from `BODY` (reserved by the wire format). Single attempt; on
connect failure, exits non-zero. Don't retry — duplicate semantics aren't
settled.

Underneath: `printf 'from=%s\tto=%s\tbody=%s\n' … | socat - UNIX-CONNECT:<path>`.

## Discovering peers

`ls "${XDG_RUNTIME_DIR:-$HOME/.ace/run}/messages/"`. Match against the name the
user gave ("the infra-defs agent" → `*infra-defs*.sock`). If multiple match, ask.

## Wire format

One line, tab-separated:

```
from=<your-slug>\tto=<peer-slug>\tbody=<text>
```

Keep the whole line under ~500 characters; some receivers (notably Claude Code's
notification surface) silently truncate beyond that. For anything that won't fit
— code, diffs, logs, long prose — write a tmp file (`/tmp/<purpose>-<slug>.<ext>`)
and reference the path in `body`. Don't clean up tmp files; let the OS handle it.

## Backend references

- `references/opencode.md` — OpenCode (`serve` + `attach` + REST bridge)
- `references/codex.md` — Codex (`app-server` + `--remote` TUI + websocket
  bridge, experimental). For interactive Codex TUI use `scripts/codex.sh`.

## Out of scope

Auth. Encryption. Cross-machine. Persistence. Multi-message threading. Acks,
retries, delivery guarantees. If the user asks for any of these, stop and
discuss.
