---
name: ace
description: >
  Start or resume the ACE workflow. TRIGGER at session start, after `/clear`, between
  tasks, or on "go", "continue", "next", "what's next", or "resume" when no task is
  active. DO NOT TRIGGER when the cue refers to an in-flight edit, command, or step.
argument-hint: "[optional focus area or task]"
---

# ace

Print `## ace` as the first line.

Use **Advance the workflow** (A1–A2) to orient from evidence and continue the current or
next approved task.

Read `workflow.md` and `ledger.md` in this skill's directory before A1.

## Advance the workflow

- **A1. Re-orient.** Run `workflow.md` phase 1. Identify the active task, its authority,
  the earliest phase whose prerequisites lack evidence, and any Wait or blocker.
- **A2. Continue.** Run from that phase until the task completes or `workflow.md` requires
  a Wait or reports a blocker. Repeated invocations begin again at A1.

## Completion contract

Keep the decisive evidence required by `ledger.md`. Report the current phase and its
evidence when the workflow pauses. An action task completes through Close, an assessment
through its full-scope Audit report, and discovery through the user's selection or its
named Wait.

Be terse. `$ARGUMENTS` narrows focus if provided.
