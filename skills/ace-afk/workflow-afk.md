# ACE Workflow — Unattended (AFK)

This is the ace workflow with every propose/confirm gate removed, for unattended runs
under `ace-afk`. The gates are replaced by the afk **envelope** (no push/publish/deploy,
no global-state mutation, no working-tree destruction, commit-don't-push) and the
pre-flight **decision-basis** established before the run. Forward motion is the default;
stopping is the exception.

## The stamp chain

The contract is `ace/ledger.md` — in the `ace` skill's directory, sibling to this
one. Read it and follow it, and hold it *more* binding here: with no human watching,
the stamps are the only witness. Evidence may also live in a subagent summary or a
`.ace/` trail entry — the stamp points at it there, never restates it. The stamp adds
a `files:` field:

```
⛓ <step> | files: <paths touched this step> | ev: "<decisive line>" | next: <step>
```

Apply `ace/ledger.md`'s display-only styling rule to this extended stamp. Keep `files:`,
the step name, separators, evidence, and values in the muted base color. Highlight only
`⛓ <step number>`, the literal `ev:`, and the literal `next:` in cyan.

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
- **Never amend `docs/spec/` on your own initiative.** The spec holds what the user
  stated, and they are away. Every call you make alone stays in `.ace/save.ledger.md`
  as `agent:inferred` until they take it up, and is yours to withdraw when the work
  moves past it. The one exception is an explicit ask: if writing or updating a spec
  *is* the task they handed you, write it and route it by `docs/README.md` like any
  other work.
- **`docs/` output follows the gate.** Exploratory output a run genuinely produces — a
  research dump, a survey, a comparison — files in `docs/scratch/` with its "not spec
  because ___" line. Placement is chosen at plan time (step 5), as attended.
- **Keep making progress.** A finished goal or clean checkpoint is where you pick up
  the next startable task — inside the envelope and state rules — not where you stop.
  Keep going while there's work with no unresolved choice and no unearnable blocker.
- **Earn the blocker.** Earn a missing input first — fetch it, stub it, build it
  yourself — before logging it as needing the human.
- **Thin orchestrator — delegate by default.** You drive; you do not do the work. Every
  edit, search, and research step goes to a subagent in fresh context, and you keep
  only its summary — which must carry the stamps. Delegate even a single sequential
  task — the driver's context must stay thin or the loop compacts mid-run. Parallel
  subagents for speed are encouraged on top.

## Orientation

Same as the attended workflow: figure out where you already are from conversation, git
state, loaded skills, and in-progress tasks. The step order is fixed; orientation's
only freedom is picking the entry point, once, with a stamp citing the evidence.
Entering mid-chain, reconstruct the artifacts the entry step depends on into the
transcript from what orientation found (the recorded plan in the trail, the
failing-test output, the diff), then stamp pointing at them; if they can't be
reconstructed, enter earlier.

## Task discovery

1. **Cleanup** — check `git status`/`git diff`. Uncommitted coherent work from a prior
   slice: commit it on the current branch (envelope: commit, don't push). Don't proceed
   on a dirty tree. Stamp ev: the decisive `git status` line; next: surface.
2. **Surface** — open by reprinting the cleanup stamp. Read the storage cascade; collect
   pending tasks, open questions, blockers. Stamp ev: points at the list above and
   names the sources read; next: select.
3. **Select** — open by reprinting the surface stamp. Pick the next task by the
   decision-basis and record it. No propose-and-wait; the basis decides. Identify which
   skills the slice needs. Stamp ev: the pick and the basis clause that decided it;
   next: specs.

## Planning

4. **Specs** — open by reprinting the select stamp. Read the project's source of truth
   (`docs/spec/` and what it points at; start from `docs/spec/README.md` if it has an
   index). The spec is authoritative — comply rather than re-deciding what it settles,
   and treat a contradiction between spec and ask as one for the decision-basis to
   resolve, not a licence to rewrite the spec. Extract acceptance criteria; note gaps.
   Stamp ev: the spec files read, pointing at the criteria above; next: draft plan.
5. **Draft plan** — open by reprinting the specs stamp. List every change (specs first,
   then tests, then code), **file by file, path by path** — this list is the binding
   file-set. For any durable doc the slice produces, name its target `docs/` folder now
   by walking the gate in `docs/README.md`. In an unattended run the gate resolves to
   `docs/scratch/` for exploratory output and to `.ace/` for everything else;
   `docs/spec/` is reachable only if writing it was the ask. Stamp ev: points at the
   file-by-file plan above; next: simplify plan.
6. **Simplify plan** — open by reprinting the draft-plan stamp. Cut to an elegant
   just-enough fit; prefer deletions; don't cut spec/called-out edge cases. Stamp ev:
   points at the surviving plan above (the binding file-set); next: test plan.
7. **Test plan** — open by reprinting the simplify stamp. Define validation before
   implementing, **per change-class** (spec, tests, code), per path: TDD by default
   (failing test first); where red/green doesn't fit a class, that class still gets a
   real named verification — render, link-check, consistency against code. No class is
   left without a plan; no plan waives another class's paths. Stamp ev: points at the
   per-class validation plan above; next: record the plan.
8. **Record the plan** — open by reprinting the test-plan stamp. The narrative goes in
   `.ace/save.md`, each open slice in `.ace/save.ledger.md` with a status and a
   provenance. Read `ace-save/trail.md` — in the `ace-save` skill's directory, sibling
   to this one — before writing either file and follow it — no
   user is present to notice a dropped line. No confirm gate — the basis and the
   envelope replace it. If the plan exceeds the decision-basis (a genuinely silent,
   expensive, irreversible choice), log a blocker and pick up the next unblocked slice.
   Stamp ev: the trail files written; next: red.

## TDD execution

Delegate the slice's edits to a subagent by default (see Thin orchestrator) — the
driver holds the plan and the stamps, not the file contents. Split a multi-file slice
into one subagent per non-overlapping file group so parallel edits don't collide. Each
subagent receives the stamps its steps must quote and returns the stamps its steps
produced; a stamp-less return means the step did not happen.

9. **Red** — open by reprinting the recorded plan stamp. Add/update tests first, touching
   only listed files; confirm they fail for the expected reason; execute a class's
   named substitute where red/green doesn't fit. Stamp: files touched; ev: the failing
   assertion line (or the substitute's decisive line); next: green.
10. **Green** — open by reprinting the red stamp. Smallest change that satisfies the
    tests, touching only listed files; an unlisted file needed → stop, return to step
    5. Stamp: files touched; ev: the passing narrow-test summary line; next: refactor.
11. **Refactor** — open by reprinting the green stamp. Clean up without behavior change
    within the file-set; prefer deletions; elegant just-enough. No cleanup needed → the
    stamp says so with the reason (a run with small evidence, not a skip). Stamp ev: a
    one-line cleanup summary (or the no-cleanup finding) plus the passing-test line;
    next: verify.
12. **Verify** — open by reprinting the refactor stamp. Run the planned narrow + broad
    checks, every class, every path; loop red/green/refactor on a missing case (re-
    entering at 9 with a stamp noting why); substitute the closest useful check if one
    can't run, recording why. Stamp ev: one decisive line per planned check; next:
    audit.

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
    Violation and re-audit; the audit converges. Run tests + lints. Stamp ev: finding
    counts by bucket, Violation = 0; next: commit.
14. **Commit** — open by reprinting the audit stamp. Commit on the current branch using
    the repo's commit convention. **Envelope: do not push, publish, release, or
    deploy** — those wait for the human. Stamp ev: the commit hash and subject line;
    next: checkpoint.
15. **Checkpoint** — open by reprinting the commit stamp. Update the `.ace/` trail: what
    landed goes in `save.md`, the next step and any open blocker go in
    `save.ledger.md` with a status and a provenance, so a crash or compaction leaves a
    clean restore point. Follow `ace-save/trail.md`: revise `save.md` in place, never
    regenerate it, never drop a line to keep it short. No `/ace-save` or `/clear`
    between slices — the subagent boundary gives fresh context, the trail gives
    continuity. Stamp ev: the trail files written; next: task discovery (1), or
    Loop-or-stop.

## Two-phase audit every 2–3 slices

Spawn audit subagents: (A) code-quality (correctness, DRY, test strength, skill
compliance over the batch), then (B) architecture/cleanup (boundaries, layering, dead
code, simplification over the module graph). Fold findings into the plan as fix-slices;
don't let them stall forward motion.

## Loop or stop

Verify passes + slices remain → spawn the next. Stop only at a genuine blocker
(basis-silent + expensive + irreversible, logged), a failed verify the subagent
couldn't fix, or an empty plan — leaving `.ace/save.md` describing where the run
stopped and `.ace/save.ledger.md` holding the next step as an item. On stop, write the
run summary to `.ace/afk.log`.

## Storage cascade

Same as the attended workflow ($ARGUMENTS → built-in tasks → agent inbox
(`.ace/connect.log`) → task tracker → `.ace/` trail (`save.md`/`save.ledger.md`) → git
state).
