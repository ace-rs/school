# ACE Workflow — Unattended (AFK)

Run under `ace-afk`'s operating envelope and pre-flight decision-basis. Forward motion is
the default; stopping is the exception.

## The stamp chain

The contract is `ace/ledger.md` — in the `ace` skill's directory, sibling to this
one. Read it and follow it, and hold it *more* binding here: with no human watching,
the stamps are the only witness. Evidence may also live in a subagent summary or a
`.ace/` trail entry — the stamp points at it there, never restates it. The stamp adds
a `files:` field:

```
⛓ <step> | files: <paths touched this step> | ev: "<decisive line>" | next: <step>
```

Apply `ace/ledger.md`'s display rule to this extended stamp: fenced on Markdown conversation
surfaces and plain text everywhere else. Emit no ANSI escapes.

On top of the contract:

- **File-set binding.** The simplified plan (step 6) is the binding file-set,
  enumerated once in the plan its stamp points at; the test plan (step 7) covers the
  same paths per class. Later stamps list only the files touched that step and cite
  the rest as `files: <touched> per ⛓ simplify`. From step 9 on, only listed files may
  be touched. An unlisted file needed mid-edit means the plan was wrong: stop, return
  to step 5, re-plan with the file included. A rationale ("docs-only", "no tests
  needed for this part") covers exactly the paths listed under it and says nothing
  about any other file.
- **Three chains, always.** Spec + tests + code is the shape of every real slice; a
  class that seems absent is a mis-scoped slice, not an exemption. Absence is never
  inferred.
- **Exemptions mean the decision-basis.** The contract's "user's verbatim words" is,
  after Go, the pre-flight decision-basis, quoted. A deviation the basis doesn't
  cover in its own words is not yours to mint: log it as a blocker and pick up the
  next unblocked slice.
- **Subagents return stamps.** A delegated slice or step is done only when the
  subagent's summary contains the stamps — file-set, evidence, next — for the steps it
  executed. A summary without stamps means the slice is not done; re-run it, don't
  paper over it.

Standing rules for the whole run:

- **Resolve open choices by the basis, don't ask.** Apply the decision-basis from
  pre-flight, record the call in `.ace/save.ledger.md`, move on. Surface a choice only
  when the basis is genuinely silent *and* it is expensive to reverse — and even then,
  in afk that is a logged blocker, not a stall.
- **Record the calls you make as you make them, not as questions** — into the `.ace/`
  trail, which is the crash-safe restore point.
- **Stamp provenance; unmarked is yours.** A call you make solo is `agent:inferred` and
  stays provisional — it turns SETTLED only with the user's verbatim words, and you
  never replay it later as theirs. Going far is the goal; putting your own calls in the
  user's mouth is not.
- **`docs/` output follows the gate.** Exploratory output a run genuinely produces — a
  research dump, a survey, a comparison — files in `docs/scratch/` with its "not spec
  because ___" line. Placement is chosen at plan time (step 5), as attended.
- **Keep making progress.** A finished goal or clean checkpoint is where you pick up
  the next startable task — inside the envelope and state rules — not where you stop.
  Keep going while there's work with no unresolved choice and no unearnable blocker.
- **Preserve context.** Enable the harness's automatic context rollover when supported.
  Keep the driver thin enough that a long run survives repeated context windows.
- **Earn the blocker.** Before logging a missing input, run both gates:
  - **Acquire input.** Obtain the real sample, fixture, dependency, dataset, or test target
    inside the operating envelope.
  - **Create a faithful substitute.** When the real input cannot be obtained, create the
    smallest substitute that preserves the relevant behavior and acceptance criteria. Do
    not weaken requirements, fabricate evidence, or let temporary scaffolding become
    shipped behavior merely to keep moving. If fidelity cannot be preserved, log the
    missing input as a blocker.

  The blocker entry cites the failed acquisition and the failed or quality-reducing
  substitution. Without both citations, the blocker cannot be logged.
- **Thin orchestrator — delegate by default.** You drive; you do not do the work. Every
  edit, search, and research step goes to a subagent in fresh context, and you keep
  only its summary — which must carry the stamps. Delegate even a single sequential
  task — the driver's context must stay thin or the loop compacts mid-run. Parallel
  subagents for speed are encouraged on top.

## Orientation

Same as the attended workflow: figure out where you already are from conversation, git
state, loaded skills, and in-progress tasks. The step order is fixed; orientation's
only freedom is picking the entry point, once, with a stamp citing the evidence. A dirty
tree containing one coherent slice with reconstructable prerequisite evidence enters at
Verify (12), Audit (13), or Commit (14), at the earliest unproven step. A dirty tree with
mixed or incoherent changes, or prerequisite evidence that cannot be reconstructed,
enters at Cleanup (1).

Entering mid-chain, reconstruct the artifacts the entry step depends on into the
transcript from what orientation found (the recorded plan in the trail, the failing-test
output, the diff), then stamp pointing at them. Enter Commit only when evidence of
verification and a fresh zero-Violation audit can be reconstructed. If the evidence
cannot be reconstructed, enter Cleanup.

## Task discovery

1. **Cleanup** — check `git status`/`git diff`. A clean tree closes with
   `next: 2 Surface`. For mixed or incoherent changes, or changes whose prerequisite
   evidence cannot be reconstructed, do not edit, separate, stash, discard, or commit
   them. Log the exact state as a blocker and close with `next: done`; control returns to
   the `ace-afk` handoff. Cleanup never commits.
2. **Surface** — open by reprinting the cleanup stamp. Read the storage cascade; collect
   pending tasks, open questions, blockers.
3. **Select** — open by reprinting the surface stamp. Pick the next task by the
   decision-basis and record it. No propose-and-wait; the basis decides. Identify which
   skills the slice needs.

## Planning

4. **Specs** — open by reprinting the select stamp. Read the project's source of truth
   (`docs/spec/` and what it points at; start from `docs/spec/README.md` if it has an
   index). The spec is authoritative — comply rather than re-deciding what it settles,
   and treat a contradiction between spec and ask as one for the decision-basis to
   resolve, not a licence to rewrite the spec. Extract acceptance criteria; note gaps.
5. **Draft plan** — open by reprinting the specs stamp. List every change (specs first,
   then tests, then code), **file by file, path by path** — this list is the binding
   file-set. For any durable doc the slice produces, name its target `docs/` folder now
   by walking the gate in `docs/README.md`. In an unattended run the gate resolves to
   `docs/scratch/` for exploratory output and to `.ace/` for everything else;
   `docs/spec/` is reachable only if writing it was the ask.
6. **Simplify plan** — open by reprinting the draft-plan stamp. Cut to an elegant
   just-enough fit; prefer deletions; don't cut spec/called-out edge cases.
7. **Test plan** — open by reprinting the simplify stamp. Define validation before
   implementing, **per change-class** (spec, tests, code), per path: TDD by default
   (failing test first); where red/green doesn't fit a class, that class still gets a
   real named verification — render, link-check, consistency against code. No class is
   left without a plan; no plan waives another class's paths.
8. **Record the plan** — open by reprinting the test-plan stamp. The narrative goes in
   `.ace/save.md`, each open slice in `.ace/save.ledger.md` with a status and a
   provenance. Read `ace-save/trail.md` — in the `ace-save` skill's directory, sibling
   to this one — before writing either file and follow it — no
   user is present to notice a dropped line. No confirm gate — the basis and the
   envelope replace it. If the plan exceeds the decision-basis (a genuinely silent,
   expensive, irreversible choice), log a blocker and pick up the next unblocked slice.

## TDD execution

Delegate the slice's edits to a subagent by default (see Thin orchestrator) — the
driver holds the plan and the stamps, not the file contents. Split a multi-file slice
into one subagent per non-overlapping file group so parallel edits don't collide. Each
subagent receives the stamps its steps must quote and returns the stamps its steps
produced; a stamp-less return means the step did not happen.

9. **Red** — open by reprinting the recorded plan stamp. Add/update tests first, touching
   only listed files; confirm they fail for the expected reason; execute a class's
   named substitute where red/green doesn't fit.
10. **Green** — open by reprinting the red stamp. Smallest change that satisfies the
    tests, touching only listed files; an unlisted file needed → stop and close with
    `next: 5 Draft plan`.
11. **Refactor** — open by reprinting the green stamp. Clean up without behavior change
    within the file-set; prefer deletions; elegant just-enough. No cleanup needed → the
    stamp says so with the reason (a run with small evidence, not a skip).
12. **Verify** — open by reprinting the refactor stamp. Run the planned narrow + broad
    checks, every class, every path; loop red/green/refactor on a missing case (re-
    entering at 9 with a stamp noting why); substitute the closest useful check if one
    can't run, recording why.

## Review and close

13. **Audit** — open by reprinting the verify stamp. First clause is mechanical: walk
    `git diff --stat` and confirm every changed file appears in the plan's file-set and
    inside a complete stamp chain (plan → test plan → red → green → refactor →
    verify); a file
    outside the chain is a laundering breach — return to step 5 for it. Then the
    content pass: re-read every changed file (not just diffs). Categorize findings:
    **Violation** (clear skill/spec rule broken or chain/coverage breach — blocks, must
    fix), **Borderline** (judgment call the skill permits — flag once, leave),
    **Out-of-scope** (pre-existing, not introduced here — note, don't fix). Fix every
    Violation and re-audit; the audit converges. Run tests + lints.
14. **Commit** — open by reprinting the audit stamp. Commit on the current branch using
    the repo's commit convention, closing this coherent, completed slice. **Envelope: do
    not push, publish, release, or deploy** — those wait for the human.
15. **Checkpoint** — open by reprinting the commit stamp. Update the `.ace/` trail: what
    landed goes in `save.md`, the next step and any open blocker go in
    `save.ledger.md` with a status and a provenance, so a crash or compaction leaves a
    clean restore point. Follow `ace-save/trail.md`: revise `save.md` in place, never
    regenerate it, never drop a line to keep it short. No `/ace-save` or `/clear`
    between slices — the subagent boundary gives fresh context, the trail gives
    continuity. Close with `next: 1 Cleanup` while slices remain or `next: done` when none
    remain.

## Two-phase audit every 2–3 slices

Spawn audit subagents: (A) code-quality (correctness, DRY, test strength, skill
compliance over the batch), then (B) architecture/cleanup (boundaries, layering, dead
code, simplification over the module graph). Fold findings into the plan as fix-slices;
don't let them stall forward motion.

## Loop or stop

Verify passes + slices remain → spawn the next. Stop only at a genuine blocker
(basis-silent + expensive + irreversible, logged), a failed verify the subagent
couldn't fix, or an empty plan — leaving `.ace/save.md` describing where the run
stopped and `.ace/save.ledger.md` holding the next step as an item. On stop, return to
`ace-afk`; it disarms the heartbeat before writing `.ace/afk.log`.

## Storage cascade

Same as the attended workflow ($ARGUMENTS → built-in tasks → agent inbox
(`.ace/connect.log`) → task tracker → `.ace/` trail (`save.md`/`save.ledger.md`) → git
state).
