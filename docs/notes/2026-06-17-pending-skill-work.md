# Pending skill work — 2026-06-17

Two follow-ups surfaced during the `ace-*` consistency audit (the audit's six findings
landed the same day; these were deliberately split out as their own sessions).

## 1. Draft `ace-afk` — unattended/overnight handoff skill

A skill to hand work off to the agent when no human is watching (overnight being the prime
case — "nightshift"). Core behavior:

- Make maximum forward progress **without** human intervention, strictly within safety
  rules (no global-state mutation, no irreversible/outward-facing actions, no working-tree
  destruction — the usual `CLAUDE.md` safety boundary).
- When something genuinely needs a human, **don't block** — record the question/blocker
  into a file the human reads on return, then continue with whatever else is unblocked.
- Goal: best use of idle/night token budget.

Naming decided: primary name **`ace-afk`** (scope is *unattended*, not just nighttime);
work the "nightshift" framing into the description as the evocative trigger.

Open question carried from the audit: whether a `/ace-afk` slash **alias** can coexist with
a nightshift-flavored name natively (SKILL.md alias field?) or needs a thin stub skill.
Resolve alongside follow-up #2.

## 2. Expand `ace-school` against the live `ace-rs/ace` implementation

`ace-school/SKILL.md` describes school structure, `school.toml` fields, the `ace` CLI, and
cache/symlink mechanics. Likely drift vs the current `ace-rs/ace` source on this machine —
re-check against the actual implementation and add anything missing (new `ace` subcommands,
config fields, import/wildcard behavior, alias support per #1).
