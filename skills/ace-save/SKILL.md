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

Save session state so the next `/ace` can pick up cleanly.
Read `workflow.md` in the `ace` skill directory for the storage cascade.

Walk this checklist. Do not touch code. At each target you write to, also drop
stale entries (completed tasks, superseded preferences, resolved questions,
contradicted learnings).

1. **Session notes** — survey conversation + `git status`. Write what was done,
   what's next, and any open questions to the first available durable store in
   the cascade. If `$ARGUMENTS` provided, include those notes.

2. **Learnings** — scan for durable knowledge that emerged this session:
   - Preferences about how Claude should behave → append to user MEMORY
     (`~/.claude/projects/<slug>/memory/MEMORY.md`).
   - Facts about this codebase/project → append to project `CLAUDE.md`.
   Skip if nothing durable surfaced. Don't invent learnings.

3. **School proposals** — scan for school-bound work:
   - Skill edits already in working tree → load `ace-school` to commit/PR.
   - Skill gap, alignment regression, or new pattern worth capturing → load
     `issue-creator` to file in the school's issue tracker.
   - Non-trivial design call made during session → if the school keeps a
     decisions log, add an entry per its conventions.
   Skip silently if none apply.

Report what was saved and where. Only confirm safe to `/clear` if state was
persisted to durable storage successfully.
