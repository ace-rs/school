---
name: ace-audit
description: >
  Audit landed work against its governing skills and repository rules. TRIGGER on
  `/ace-audit` or requests to review, audit, or check a diff or body of work. DO NOT
  TRIGGER for the normal `ace` audit phase, routine coding, or work with no reviewable
  scope.
argument-hint: "[scope for a standalone pass, e.g. paths or a commit range]"
---

# ace-audit

Print `## ace-audit` as the first line.

An audit request grants assessment only. Repair requires an explicit action request or
standing repository authority that names repair.

## Menu

| Operation          | Steps        | Use when                                      |
|--------------------|--------------|-----------------------------------------------|
| Assess work        | P1–P2, A1–A2 | the user asks to review, audit, or check work |
| Repair violations  | P1–P2, R1–R3 | the user explicitly asks to fix audit results |

Read `ace/ledger.md` and `ace/workflow.md` in the `ace` skill's directory. Keep the scope,
loaded rules, checks, findings, and close state as evidence.

## Prepare

- **P1. Select scope.** For recovery, use unstaged and staged changes reported by
  `git diff --name-only` and `git diff --cached --name-only`. For a standalone pass, use
  `$ARGUMENTS`. On a clean tree with no arguments, use the unpushed range when an upstream
  exists. If none identifies a body of work, ask the user to name it. This is a Wait.
- **P2. Load governing rules.** Read the repository instructions and every convention
  they point to. For code, load the relevant language, framework, and infrastructure
  skills. For `skills/<name>/SKILL.md`, load `ace-skill` when available. Every file must
  have a governing surface; repository instructions govern when no narrower skill fits.

## Assess work

- **A1. Inspect full scope.** Check the implementation and structure against the loaded
  rules. Run the read-only checks needed to substantiate findings. Categorize each finding
  with the `ace/workflow.md` Audit rules. When materially different valid designs remain
  and no rule ranks them, report the ambiguity as a Borderline.
- **A2. Report.** Report the full scope, checks, Violations, Borderlines, and out-of-scope
  findings. Do not edit, commit, or take another action from an audit request.

## Repair violations

- **R1. Confirm repair authority.** Cite the user's explicit repair request or the loaded
  standing instruction that authorizes repair. If neither exists, switch to **Assess
  work**. If a required design choice remains unresolved, ask one narrow question and
  wait. This is a Wait.
- **R2. Repair to convergence.** Fix every Violation, run the affected checks, then repeat
  the full-scope audit from P2. Continue until a fresh full-scope pass finds zero
  Violations and requires no changes. Never close on a partial or dirty rescan.
- **R3. Close.** Commit only when the repository instructions authorize autonomous local
  commits; otherwise report the reviewed diff and wait. A local commit does not authorize
  pushing or another outward action.

## Completion contract

Assessment completes with the checked scope and categorized findings. Repair completes
with the final zero-Violation full pass, verification results, and commit hash or reviewed
uncommitted diff. A missing scope, authority, or design choice completes only its named
Wait; report what the next step requires.
