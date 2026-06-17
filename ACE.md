# ACE Skills

ACE (Accelerated Coding Environment) is a session orchestration harness; using it
normally means wiring up a *school* — a repo of shared skills and conventions a project
subscribes to. This is that school, shipped by default: a batteries-included first school
so ACE is useful out of the box instead of making you stand one up first.

What's bundled is the basic stuff any harness needs, nothing domain-specific — things
like workflow nudging, session management, model prompting (`ace-realign`), and
documentation. Each covers a moment a raw coding session handles badly: losing the thread
across a `/clear`, work that skipped review, a rule that won't stick. Reach for them by
the problem, not the mechanism; each section below leads with the situation it's for.

| Skill         | Reach for it when                           |
|---------------|---------------------------------------------|
| `ace-init`    | first-time onboarding of a repo into ACE    |
| `ace`         | moving the workflow forward a step          |
| `ace-save`    | before a `/clear`, exit, or switch          |
| `ace-audit`   | work landed unreviewed, or a quality pass   |
| `ace-realign` | a rule keeps getting broken                 |
| `ace-school`  | a fix should reach every project            |
| `ace-connect` | two local agents need to talk               |
| `ace-docs`    | durable artifacts are scattering            |

## `ace-init` — onboard a repo into ACE

A repo just adopted ACE, but nothing is tuned to it yet: the instructions file is generic,
every bundled skill is active, and each session rediscovers the codebase from scratch.
`ace-init` is the cold-start counterpart to `ace` — study the repo once, narrow the
skills, refresh the instructions file, and (on approval) seed durable docs or a spec run.
Run it when adopting ACE, then hand off to the workflow.

## `ace` — nudge the workflow forward

ACE runs a defined workflow — plan, write, test, audit, and the rest. `ace` advances it
one step: invoke it again and again and the agent walks the stages itself, so you don't
hand-direct each phase ("now plan", "now test", "now write"). At a session boundary it
also reads persisted state to resume mid-workflow instead of restarting. It's a nudge
along the process, not a task-discovery tool — and it stays quiet when "go"/"continue"
point at the in-flight step rather than the next one.

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

Research dumps, decisions, specs, usage docs, and references pile up with nowhere to live,
so they scatter or rot. `ace-docs` scaffolds a `docs/` tree that nudges clean organization
— usage docs (`guides/`, `reference/`) by type, a design record (`spec/`, `decisions/`,
`notes/`) by permanence — and wires `CLAUDE.md`/`AGENTS.md` to point at it so humans and
agents both find it.
