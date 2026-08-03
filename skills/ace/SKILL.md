---
name: ace
description: >
  Start or resume the ACE workflow — re-orient to where it stands, then take the
  next step. TRIGGER at session start, after `/clear`, between tasks, or when the user
  signals continuation at a session boundary ("go", "continue", "next", "what's
  next", "resume", "ok proceed") with no task currently in progress. DO NOT
  TRIGGER when the cue refers to the current in-flight edit, command, or step
  (e.g. "go ahead and apply that", "continue with step 3").
argument-hint: "[optional focus area or task]"
---

# ace

Print `## ace` as the first line.

Read `workflow.md` in this skill's directory. Every invocation is two beats: first
**re-orient** — check what's already been done this session and where you are in the
workflow — then **take the next step** from there. Repeated `/ace` calls just repeat this,
walking the workflow forward so the user needn't name each phase.

Be terse. `$ARGUMENTS` narrows focus if provided.
