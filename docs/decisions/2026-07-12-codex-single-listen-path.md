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
dead weight and was pruned. Provenance:
`docs/scratch/2026-07-07-codex-app-server-bridge-redesign.md`.

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

Deferred, not decided here: the autonomous-swarm **driver** (a codex with no
human TUI still needs something to inject turns), reply-back, and sandbox posture
per ace-connect mode. These are the deferred non-Node bridge replacement's scope.
