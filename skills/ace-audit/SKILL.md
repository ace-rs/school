---
name: ace-audit
description: >
  Audit landed work against its governing skills and repository rules, as a findings
  report or an audit-fix loop. TRIGGER on `/ace-audit`, "audit loop", "fix loop", or
  requests to review, audit, or check a diff or body of work. DO NOT TRIGGER for the
  normal `ace` audit phase, routine coding, or work with no reviewable scope.
argument-hint: "[scope, e.g. paths or a commit range; say \"loop\" to fix until clean]"
---

# ace-audit

Print `## ace-audit` as the first line.

## Menu

| Operation | Steps        | Use when                                                         |
|-----------|--------------|------------------------------------------------------------------|
| Fix loop  | P1–P3, L1–L2 | the user mentions a loop, fixing, or repairing                   |
| Findings  | P1–P3, A1–A2 | the user chose findings only, or a stop condition switched to it |

A fix loop is the main use of this skill. It is not one audit: it audits, fixes, verifies,
and audits the full scope again until a pass is clean. Do not stop after one pass to hand
findings back.

Read `ace/ledger.md`, `ace/workflow.md`, and `ace/audit-loop.md` in the `ace` skill's
directory. Keep the scope, loaded rules, checks, findings, round log, and close state as
evidence.

## Prepare

- **P1. Select scope.** For recovery, use unstaged and staged changes reported by
  `git diff --name-only` and `git diff --cached --name-only`. For a standalone pass, use
  `$ARGUMENTS`. On a clean tree with no arguments, use the unpushed range when an upstream
  exists. If none identifies a body of work, ask the user to name it. This is a Wait.
- **P2. Load governing rules.** Read the repository instructions and every convention
  they point to. For code, load the relevant language, framework, and infrastructure
  skills. For `skills/<name>/SKILL.md`, load `ace-skill` when available. Every file must
  have a governing surface; repository instructions govern when no narrower skill fits.
- **P3. Choose the operation.** When the user's words mention a loop, fixing, or
  repairing, quote them and run **Fix loop**. Otherwise ask: "Findings only, or a fix loop
  until clean?" This is a Wait.

## Fix loop

- **L1. Run the loop.** Follow `ace/audit-loop.md` from its step 1: freeze the plan, run
  rounds, cite a rule for every fix, never write rules, freeze ping-pong locations, and
  stop at 10 passes. When it switches to a findings list, continue at A2.
- **L2. Close.** Commit only when the repository instructions authorize autonomous local
  commits; otherwise report the reviewed diff and wait. A local commit does not authorize
  pushing or another outward action.

## Findings

- **A1. Inspect full scope.** Check the implementation and structure against the loaded
  rules. Run the read-only checks needed to substantiate findings. Categorize each finding
  with the `ace/workflow.md` Audit rules. When materially different valid designs remain
  and no rule ranks them, report the ambiguity as a Borderline.
- **A2. Report.** Report the full scope, checks, Violations, Borderlines, and out-of-scope
  findings. Do not edit, commit, or take another action from a findings request.

## Completion contract

Findings complete with the checked scope and categorized findings. A fix loop completes
with the final zero-Violation full pass, the round log, verification results, and commit
hash or reviewed uncommitted diff. A loop stopped by `ace/audit-loop.md` completes with
its report and Wait. A missing scope, operation choice, or design choice completes only
its named Wait; report what the next step requires.
