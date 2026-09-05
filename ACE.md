# ACE Skills

The `ace-*` skills ACE Home ships, and the moment each one is for. Nothing here is
domain-specific — they cover what a raw coding session handles badly: losing the thread
across a `/clear`, work that skipped review, a rule that won't stick. Reach for them by
the problem, not the mechanism; each section below leads with the situation it's for.

Invoke one by name — `/ace`, `/ace-save`, `/ace-docs` — or just describe the situation
and let the agent pick; every skill declares triggers for that. `ace-realign` also
self-engages without being asked, on a repeated violation of the same rule.

The attended and AFK workflows verify and audit each completed, coherent slice before
committing it locally. On resume, coherent dirty work with reconstructable evidence
resumes at the first unverified phase; unresolved dirty state is surfaced for disposition
or logged as a blocker that stops the AFK run. A local commit is a checkpoint, not a push
or permission for any other outward action.

| Skill         | Reach for it when                           |
|---------------|---------------------------------------------|
| `ace-init`    | first-time onboarding of a repo into ACE    |
| `ace`         | moving the workflow forward a step          |
| `ace-afk`     | running unattended, no one watching         |
| `ace-save`    | before a `/clear`, exit, or switch          |
| `ace-audit`   | work landed unreviewed, or a quality pass   |
| `ace-realign` | a rule keeps getting broken                 |
| `ace-school`  | a fix should reach every project            |
| `ace-connect` | two local agents need to talk               |
| `ace-docs`    | durable artifacts are scattering            |
| `ace-skill`   | a skill needs writing or revising           |

## `ace-init` — onboard a repo into ACE

A repo just adopted ACE, but nothing is tuned to it yet: the instructions file is generic,
every bundled skill is active, and each session rediscovers the codebase from scratch.
`ace-init` is the cold-start counterpart to `ace` — study the repo once, narrow the
skills, refresh the instructions file, and (on approval) seed durable docs or a spec run.
Run it when adopting ACE, then hand off to the workflow.

## `ace` — nudge the workflow forward

ACE follows six phases: Orient, Plan, Implement, Verify, Audit, and Close. `ace` resumes
from the available evidence and continues until an approval gate, blocker, or completed
task. Plans include validation; results cite checks and audit findings. Chat updates
report outcomes, blockers, and decisions without per-step stamps.

## `ace-afk` — run unattended, overnight

You're stepping away and want work to keep moving with no one watching. The hazard isn't
idle time — it's an agent taking an irreversible action off a bad assumption while you're
gone. `ace-afk` is the nightshift: it drives the workflow forward inside a strict safety
envelope, logging blockers to resume later instead of waiting on them, and stopping short
of anything destructive or outward-facing. Hand it a bounded task and a clear stopping
condition, not open-ended latitude.

## `ace-save` — lock in state before you lose it

You're about to `/clear`, exit, or context-switch. The implicit fallback — session
memory and compaction — is lossy and dies with the session, so anything that mattered can
quietly vanish. `ace-save` is the deliberate alternative: a deterministic checkpoint to
durable storage so the next session resumes from known-good state. Writes notes only; not
a substitute for `git commit`.

## `ace-audit` — re-audit for quality

Either a diff landed without going through `/ace`'s audit (ad-hoc edits, late skill loads,
drift), or a large body of work just landed and you want a deliberate quality pass over
it. `ace-audit` re-runs the audit against the relevant coding skills — catching structural
problems while a rewrite is still cheap.

## `ace-realign` — make a broken rule stick

The agent keeps violating a rule and restating it isn't working. `ace-realign` forces
re-attention now — it repeats the broken rule at the start or end of every message until
you tell it to stop, keeping the rule in working context every turn.

## `ace-school` — make a fix outlive this repo

You learned or fixed something that shouldn't die locally — a tooling fact, a better
pattern, a skill gap every subscriber would hit. `ace-school` proposes the change back to
the shared school via PR so it reaches every project that imports it, instead of rotting
in one repo or one machine's memory.

## `ace-connect` — let two local agents talk

You've got two agents on the same machine (say Claude Code and Codex) and you're relaying
messages between terminals by hand. `ace-connect` gives them a unix-socket bridge to
message each other directly — fire-and-forget, single-user trust boundary, no auth or
persistence. Not for intra-session, MCP, or cross-machine messaging.

## `ace-docs` — give durable artifacts a home

Research dumps, settled rules, specs, usage docs, and references pile up with nowhere to
live, so they scatter or rot. `ace-docs` scaffolds a `docs/` tree routed by a single
gate — `vendor/` (third-party reference), `guides/` (how-to), `spec/` (our design and
surface), `scratch/` (residual exploration) — and wires `CLAUDE.md`/`AGENTS.md` to point
at it so humans and agents both find it. Everything settled amends `spec/`, which is
authoritative; there is no decisions log.

## `ace-skill` — write skills agents actually follow

`ace-skill` authors skills with a menu before operational detail, clear steps, explicit
approval gates, and evidence for results. It also clarifies existing procedures and tunes
descriptions for triggering.
