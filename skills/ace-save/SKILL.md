---
name: ace-save
description: >
  Persist session state to durable storage so the next `/ace` resumes cleanly.
  TRIGGER when the user says "save session", "save state", "checkpoint", "before
  I clear", "wrap up", "end of session", or otherwise signals they're about to
  `/clear`, exit, or context-switch. Also trigger when joining a session not
  started with `/ace`. DO NOT TRIGGER for committing code or saving files — this
  skill writes session notes only.
argument-hint: "[notes or context to preserve]"
---

# ace-save

Print `## ace-save` as the first line.

Save session state so the next `/ace` resumes cleanly.

This is a deliberate, deterministic save point — beyond the implicit session
memory and compaction you'd otherwise rely on (lossy, and gone once the session
ends). ace-save explicitly persists to durable storage that survives `/clear`,
exit, and context switches.

Persist to the **storage cascade** (`ace/workflow.md`, the `## Storage cascade`
section). Keep the survey cheap: check `git status` plus the one or two stores
actually in use — don't sweep every tier, and don't hit a task-tracker API
unless tasks clearly live there.

Do not touch code. Only at a target you're already writing this run, prune stale
entries you notice while there (completed tasks, superseded prefs, resolved
questions, contradicted learnings) — don't open stores just to sweep.

## Ledger

The two numbered steps below run as a stamp chain. Read `ace/ledger.md` — in the `ace`
skill's directory, sibling to this one — and follow its contract: close every step with
its one-line stamp, open the next by reprinting it, no skips. The closing report opens
by reprinting step 2's stamp.

## 1. Resume breadcrumb

Survey the conversation and `git status`, then persist to the storage cascade:
- **Tasks / next steps** → the most fitting store the cascade names (issue
  tracker if one's in use, `.ace/save.md` otherwise) — where the next `/ace`
  looks for pending work.
- **Narrative** — what was done, where you stopped, open questions — enough that
  a fresh session picks up the thread.
Include `$ARGUMENTS` if provided.

## Trail format — state, not story

The trail is `.ace/save.md` (current truth) and `.ace/save.ledger.md` (items
with a status and a provenance), both gitignored. Read `ace-save/trail.md` —
next to this file — before writing either one, and follow it. It holds the
layout, the status and provenance enums, how a line may leave a file, and how
a settled item graduates into `docs/`.

## 2. Route durable knowledge

A learning that outlived the task goes to exactly one place, by **who it
serves** — checked top-down, stop at the first fit:
- **Every project that loads a skill** (generic tooling/language fact the skill
  covers) → record it in the breadcrumb as a pending school change (which skill,
  what to add) for `ace-school` to propose later. Don't run the branch/push/PR
  flow inline during a save. Never memory — there it dies with your machine
  instead of reaching the skill's subscribers.
- **This repo's team** (settled rules, specs, shared patterns) → `docs/` or the
  issue tracker. Never memory — it doesn't reach teammates or other agents.
- **You, everywhere** (how the agent should behave for you, your preferences) →
  your harness's user-level memory or instructions file — whatever persists
  across every project on this machine (Claude Code: `~/.claude/…/MEMORY.md`).
- **This repo only** (a fact specific to this codebase) → project `CLAUDE.md`.

Also sweep for school-bound artifacts that aren't learnings: skill edits already
in the working tree (→ note in the breadcrumb for `ace-school` to propose later;
don't branch/push/PR during a save) and non-trivial design calls (→ the school's
`docs/spec/`).

Skip anything that doesn't apply; don't invent learnings.

Report what was saved and where. Only confirm safe to `/clear` if state
persisted successfully.
