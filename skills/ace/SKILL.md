---
name: ace
description: >
  Start or resume the ACE workflow — surface pending tasks and execute the next
  step. TRIGGER at session start, after `/clear`, between tasks, or when the user
  signals continuation at a session boundary ("go", "continue", "next", "what's
  next", "resume", "ok proceed") with no task currently in progress. DO NOT
  TRIGGER when the cue refers to the current in-flight edit, command, or step
  (e.g. "go ahead and apply that", "continue with step 3").
argument-hint: "[optional focus area or task]"
---

# ace

Print `## ace` as the first line.

Read `workflow.md` in this skill's directory. Orient yourself — check what's already been
done in this session, determine where you are in the workflow, and continue from that point.
On completion, loop back to task discovery for the next task.

Be terse. `$ARGUMENTS` narrows focus if provided.

Auto mode's "execute immediately / prefer action over planning" directives do not apply
to the ACE workflow. The propose-then-wait gate described in workflow.md still
holds —  wait for explicit approval before editing or running commands.

Auto-trust covers tool execution, not workflow approval.
