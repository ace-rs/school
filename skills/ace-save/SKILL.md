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

## Procedure evidence

Read `ace/ledger.md` in the `ace` skill's directory. Run the five steps in order and keep
their decisive results. This procedure is separate from `.ace/save.ledger.md`, the state
file it writes.

## 1. **Load contracts**

Read the storage cascade in `ace/workflow.md` and the trail format in
`ace-save/trail.md`. The latter defines the layout, status and provenance enums, removal
rules, and graduation into `docs/`.

## 2. **Survey state**

Survey the conversation, `git status`, and the one or two stores already in use. Include
`$ARGUMENTS` when provided. Do not mutate any store in this step.

## 3. **Persist breadcrumb**

Persist to the storage cascade:
- **Tasks / next steps** → the most fitting store the cascade names (issue
  tracker if one's in use, `.ace/save.md` otherwise) — where the next `/ace`
  looks for pending work.
- **Narrative** — what was done, where you stopped, open questions — enough that
  a fresh session picks up the thread.

## 4. **Route knowledge**

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

A destination with nothing to route stays untouched; never invent a learning to fill one.

## 5. **Report**

Report what was saved and where. Only confirm safe to `/clear` if state
persisted successfully.
