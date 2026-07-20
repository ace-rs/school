# Codex bridge: one `--listen` path, per-slug rendezvous, no fixed port

- **Date:** 2026-07-12
- **PR:** manual
- **Status:** accepted

## Decision

The ace-connect codex backend supports **one** receive topology: `codex
app-server --listen` (server) + a bridge client + the TUI client, all fronted by
the single `codex.sh` command. The old tool-harness one-shot `socat` receive is
dropped. The app-server binds an **ephemeral** port; its URL is published to a
per-slug rendezvous file `<messages-dir>/<slug>.codex-app.url`. No fixed listen
port.

## Rationale

The reference doc previously presented two co-equal receive methods (tool-harness
`socat` vs app-server), forcing every future reader to guess which was live. Live
validation settled that the app-server transport is the real path — multi-client,
the server fans thread events to non-owning clients — so the tool-harness track is
dead weight and was pruned. The protocol research and live validation behind this
are absorbed into `skills/ace-connect/references/codex.md`.

Why **not** a fixed listen port (the obvious "just pick 8888" default): the
server owns cwd + sandbox, so one host runs one app-server *per workspace*. A
codex swarm of N workspaces therefore needs N distinct addresses on one host — a
single fixed port cannot host it. An ephemeral port + per-slug rendezvous file
scales to N with zero per-session configuration, stays `ws://` (so `codex
--remote` still attaches), and mirrors the existing per-slug unix-socket
convention. The convention is the file path, not a port.

Why **not** keep the manual multi-terminal flow as the primary instruction:
foreground processes don't scale (no tmux assumption, and a 10-codex swarm can't
be hand-driven). The daemons background themselves under `codex.sh`; the only
foreground is the user's own TUI. The manual flow survives as a debug appendix,
not the on-ramp.

Settled shortly after this ruling: **reactive-only**.
A codex on the bus answers peer messages and does not drive its own agenda, so
there is no autonomous-swarm driver to build. Receive is one-shot per message
(`turn/start`, confirm `turn/started`, done — the app-server runs the agent loop
itself); reply-back is codex's own `send.sh` call, symmetric with Claude, not a
bridge relay. Sandbox posture is **not** a scripted mode→flag mapping: `codex.sh`
launches at a permissive ceiling (`workspace-write`) and the model — with a human
always at the TUI — applies ace-connect's mode/safety rules by reading the skill,
not the sandbox. See
`docs/decisions/2026-07-12-ace-connect-rules-are-model-interpreted.md`.
