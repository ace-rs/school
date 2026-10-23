# Audit fix loop

Use this contract when a skill points here for an authorized fix loop. A fix loop is not
one audit. It repeats audit, fix, verify, and a fresh full-scope audit until a pass is
clean or a stop condition below fires. Do not stop after one pass to hand findings back.

## 1. Freeze the plan

Before the first edit, write `.ace/audit.md` with:

- the scope: paths or commit range;
- the rule files loaded for that scope;
- the task the loop serves, quoted from the user or the approved plan.

The plan does not change during the loop. Report anything outside it; do not act on it.

## 2. Run each round

1. Run a full-scope audit. Classify findings with the Audit rules of `ace/workflow.md`.
2. Before fixing, check the size of the work. When fixing the Violations would touch
   about half or more of the files in scope, or needs design changes instead of local
   edits, stop the loop. Tell the user the work needs a planned work pass, not an audit
   loop. Report the findings list. Make no further edits.
3. Fix each Violation. Every fix cites the rule it enforces as `file:line` with the quoted
   rule text from a loaded surface. Without such a quote the finding is not a Violation:
   report it and do not edit.
4. Verify the affected checks.
5. Compare the round's diff with the plan. Revert any change outside the scope and report
   it.
6. Append the round to the round log in `.ace/audit.md`: round number, Violations
   found, and each fix as file, location, before → after in one line, and cited rule.

## 3. Never write rules in the loop

Do not create or amend specs, skills, `CLAUDE.md`, `AGENTS.md`, or other instruction
files, unless the plan's task is to edit that exact file. When a rule seems missing,
record a **Proposed rule** in the report for the user to decide.

## 4. Stop ping-pong edits

Before applying a fix, read the round log. Do not apply the fix when it:

- returns a location to the state an earlier round changed it from (A → B, then B → A);
  or
- alternates the same location between two cited rules.

Freeze that location instead. Record a **Conflict** that cites both rules. Exclude frozen
locations from later rounds and continue with the other findings.

## 5. Cap the loop

Run at most 10 full-scope passes. After the 10th, stop even when Violations remain.

## 6. Close

The loop ends on a fresh full-scope pass with zero Violations and no changes, or on a
stop condition. Report the round log, open Violations, Conflicts, Proposed rules, and
out-of-scope findings. After a stop condition, wait for the user. This is a Wait.
