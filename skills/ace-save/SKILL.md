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

Read `workflow.md` in the `ace` skill directory for the storage cascade.

Do not touch code. At every target you write, also drop stale entries (completed
tasks, superseded prefs, resolved questions, contradicted learnings).

## 1. Resume breadcrumb

Survey the conversation and `git status`, then persist to the storage cascade:
- **Tasks / next steps** → the most fitting store the cascade names (issue
  tracker if one's in use, scratch file otherwise) — where the next `/ace` looks
  for pending work.
- **Narrative** — what was done, where you stopped, open questions — enough that
  a fresh session picks up the thread.
Include `$ARGUMENTS` if provided.

## 2. Route durable knowledge

A learning that outlived the task goes to exactly one place, by **who it
serves** — checked top-down, stop at the first fit:
- **Every project that loads a skill** (generic tooling/language fact the skill
  covers) → amend that skill via `ace-school`; file with `issue-creator` if the
  fix isn't obvious. Never memory — there it dies with your machine instead of
  reaching the skill's subscribers.
- **This repo's team** (decisions, specs, shared patterns) → `docs/` or the
  issue tracker. Never memory — it doesn't reach teammates or other agents.
- **You, everywhere** (how Claude should behave for you, your preferences) →
  user MEMORY (`~/.claude/projects/<slug>/memory/MEMORY.md`).
- **This repo only** (a fact specific to this codebase) → project `CLAUDE.md`.

Also sweep for school-bound artifacts that aren't learnings: skill edits already
in the working tree (→ `ace-school` to commit/PR) and non-trivial design calls
(→ the school's decisions log if it keeps one).

Skip anything that doesn't apply; don't invent learnings.

Report what was saved and where. Only confirm safe to `/clear` if state
persisted successfully.
