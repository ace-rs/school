# ace-connect rules are model-interpreted, not coded against

- **Date:** 2026-07-12
- **PR:** manual
- **Status:** accepted

## Decision

ace-connect's rules — mode selection, autonomous-safety, dialect — are interpreted
by the frontier model at the receive surface, where a human is always present. A
backend's only job is **transport**: deliver each inbound message paired with a
pointer to the skill (`load ace-connect … act per mode`), and carry sends. Never
encode the rules into the backend, a script, or the sandbox. There is no headless,
no-human agent to design for.

## Rationale

The obvious default — the one a fresh agent reaches for and this project already
tripped over once — is to *implement* the rules: map control/autonomous mode to
`sandbox_mode`/`approval_policy` flags at launch, build a turn-driving loop for a
"headless swarm member," scrape agent output to synthesize replies. Every piece of
that is wrong, and the reasons are worth freezing:

- **The receive surface already carries the rules to the model.** `start.sh` for
  Claude is `socat` plus a Monitor line that re-surfaces `load ace-connect …
  act per mode` on *every* notification. The message arrives welded to the
  instruction to go read the skill. The model reads it and behaves — no rule logic
  in the transport. Each backend reproduces that pointer on its own receive surface
  (codex: a wrapper around the injected `turn/start`); it does not reimplement the
  skill.

- **There is always a human at the surface.** Claude's Monitor and codex's TUI are
  both human-attended. So "no one to approve" is fiction: the model applies the
  autonomous-safety carve-outs by *prompting the human at the screen*, exactly as it
  does outside ace-connect. This is why the launch-time sandbox does not need to
  encode per-action approval — approval is in-band, by a present human.

- **A frontier model needs no script for judgment.** Picking a mode, deciding a
  peer instruction is unsafe, choosing to reply — these are interpretation, the
  thing the model is for. Scripting them re-implements the model, badly, and buries
  the real design (the skill's prose is the program).

Consequence for the sandbox: launch the app-server at a permissive **ceiling**
(`workspace-write` — in-tree room, out-of-tree writes and network blocked as a free
floor) and stop. Do not map mode to flags. The sandbox is a backstop, not the policy
engine; the model plus the human are the policy engine.

Provenance: `docs/scratch/2026-07-07-codex-app-server-bridge-redesign.md` (Status
section). Sibling ruling on the single receive path:
`docs/decisions/2026-07-12-codex-single-listen-path.md`.
