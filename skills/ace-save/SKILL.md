---
name: ace-save
description: >
  Persist session state for the next ACE session. TRIGGER on "save session", "save
  state", "checkpoint", "before I clear", "wrap up", "end of session", or an imminent
  `/clear`, exit, or context switch. Also trigger when joining a session not started with
  `ace`. DO NOT TRIGGER for commits or ordinary file saves; this writes session records.
argument-hint: "[notes or context to preserve]"
---

# ace-save

Print `## ace-save` as the first line.

Use **Save a checkpoint** (1–5) to preserve the current session without changing code.

Read `ace/ledger.md`, the Storage cascade in `ace/workflow.md`, and
`ace-save/trail.md`. The trail file defines layout, status, provenance, removal, and
graduation rules. Keep the survey cheap: inspect `git status` and the one or two stores
already in use.

## **1. Load contracts**

Identify the repository boundary, stores already in use, and authority for each possible
write. A save request authorizes repository-local session records. It does not authorize
an external tracker, shared service, or file outside the repository.

## **2. Survey state**

Survey the conversation, `git status`, and the one or two stores already in use. Include
`$ARGUMENTS` when provided. Do not mutate any store. Identify completed work, the current
stop point, open items, settled user statements, and provisional agent derivations.

## **3. Persist breadcrumb**

Write the local breadcrumb under `.ace/` using `trail.md`:

- Put the current narrative, standing facts, and pointers in `.ace/save.md`.
- Put every open item, including pending tasks, in `.ace/save.ledger.md` with status and
  provenance. Leave at most a one-line pointer to them in `.ace/save.md`.

Do not replace either trail file wholesale. At a target already being written, remove
only entries that `trail.md` permits to leave and record the destination or completion in
the save report.

## **4. Route authorized knowledge**

A learning that outlived the task goes to exactly one place, checked top-down by who it
serves:

- **Every project that loads a skill** (generic tooling/language fact the skill
  covers) → record a pending school change in `.ace/save.ledger.md` with status,
  provenance, target skill, and proposed addition. Do not run the branch, push, or PR flow
  during a save.
- **This repo's team** (settled rules, specs, shared patterns) → the durable-docs root
  named by the repo's always-loaded instructions, or a repository-local task file.
- **You, everywhere** (how the agent should behave for you, your preferences) →
  a user-level instructions file only when the user explicitly authorizes that
  out-of-repository write.
- **This repo only** (a fact specific to this codebase) → project `CLAUDE.md`.

An external tracker, shared service, or out-of-repository file requires explicit user
authority naming that destination. Without it, keep the item in the local breadcrumb with
its provenance and the intended destination. Never silently substitute global memory.

Also record school-bound artifacts in `.ace/save.ledger.md`: skill edits already in the
working tree and non-trivial design calls intended for the school's durable-docs `spec/`.
Graduate a design call into the resolved root's `spec/` only when it carries the user's
verbatim evidence required by `trail.md`, the school checkout is the current repository,
and the save request authorizes that local record. Otherwise keep it in the ledger. Never
enter or mutate another checkout during a save.

A destination with nothing to route stays untouched. Never invent a learning to fill one.

## **5. Report**

Report every written destination, moved or deleted trail entry, retained item, and skipped
destination that lacked authority. Confirm safe to `/clear` only when the repository-local
trail persisted successfully.

## Completion contract

Keep the survey, changed trail files, provenance, and report as evidence under
`ace/ledger.md`. A successful checkpoint ends with the exact local paths that preserve
the next session. A failed local write ends with the error and does not claim that
`/clear` is safe. A missing external-write authority keeps the item locally and does not
block the checkpoint.
