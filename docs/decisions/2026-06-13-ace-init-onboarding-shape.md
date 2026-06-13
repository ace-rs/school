# ace-init: batched, explicit, self-contained onboarding

- **Date:** 2026-06-13
- **PR:** manual (commit c9b60f5)
- **Status:** accepted

## Decision

`ace-init` onboards a repo into ACE in two phases. Phase 1 (structure) skims the repo,
then collects the instructions-file edits, skills selection, and docs decision into one
plan file applied in a single approved batch. Phase 2 (optional, gated) is a full spec run
that distills existing code into durable explainers. It triggers only on explicit request
— no auto-fire, no `/ace` nudge — does its own analysis without a harness-native init, and
references `ace learn` loosely rather than wrapping or replacing it.

## Rationale

Why each call went against the obvious default:

- **No native-init dependency** (reversed mid-design). The obvious `/init`-like move is to
  run the harness's native init for the baseline. Rejected: a native init runs its own
  full-codebase analysis — the token-heavy scan Phase 1 keeps to a skim — so it duplicates
  work, and naming `/init` ties the skill to one harness, breaking the agnostic rule every
  ACE skill holds. ace-init writes the instructions file from its own skim instead.

- **One plan, one batch — not per-file propose-then-wait.** ACE's workflow gates each
  write separately. For onboarding that's a start-stop slog across instructions file,
  skills, and docs. Instead: scan first, collect every proposed change into one plan file,
  approve as a whole, apply in a single pass. Still propose-then-wait, just batched.

- **Explicit trigger only.** The obvious default for an onboarding skill — and the initial
  recommendation — was to auto-fire on an un-onboarded repo, or have `/ace` nudge toward
  it. Rejected to avoid colliding with `/ace`'s own session-start orientation; ace-init
  fires only when the user asks.

- **Loose coupling to `ace learn`.** The `ace learn` CLI already studies the project,
  edits the instructions file, and narrows the skills filter — a subset of ace-init.
  Rather than make ace-init the engine `ace learn` runs (a binary change) or wrap the CLI,
  ace-init references it as the quick mechanical alternative. The two coexist.

- **Spec run distills, not generates.** A spec is an explainer reverse-derived from code
  that already exists — so a later reader skips the deep scan — not new source-of-truth.
  That drives "reconcile each claim against the implementation" over "write the spec."

Skill: `skills/ace-init/SKILL.md`; overview row and section in `ACE.md`.
