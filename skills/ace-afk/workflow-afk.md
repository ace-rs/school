# ACE Workflow — Unattended (AFK)

This is the ace workflow with every propose/confirm gate removed, for unattended runs under
`ace-afk`. The gates are replaced by the afk **envelope** (no push/publish/deploy, no
global-state mutation, no working-tree destruction, commit-don't-push) and the pre-flight
**decision-basis** established before the run. Forward motion is the default; stopping is the
exception.

Standing rules for the whole run:

- **Resolve forks by the basis, don't ask.** Apply the decision-basis from pre-flight, record
  the choice in the durable record, move on. Surface a fork only when the basis is genuinely
  silent *and* the choice is expensive to reverse — and even then, in afk that is a logged
  blocker, not a stall.
- **Record decisions as you make them, not as questions** — into the breadcrumb / durable
  record, which is the crash-safe restore + fork point.
- **Keep making progress.** A finished goal or clean checkpoint is where you pick up the next
  startable task — inside the envelope and state rules — not where you stop. Keep going while
  there's work with no unresolved decision and no unearnable blocker.
- **Earn the blocker.** Earn a missing input first — fetch it, stub it, build it yourself —
  before logging it as needing the human.
- **Thin orchestrator — delegate by default.** You drive; you do not do the work. Every edit,
  search, and research step goes to a subagent in fresh context, and you keep only its summary.
  This is the default mode, not an optimization: the point is keeping the *driver's* context
  thin so the loop survives long runs, not speed. Parallel subagents for speed are encouraged
  on top.

## Orientation

Same as the attended workflow: figure out where you already are from conversation, git state,
loaded skills, and in-progress tasks before starting at step 1.

## Task discovery

1. **Cleanup** — check `git status`/`git diff`. Uncommitted coherent work from a prior slice:
   commit it on the current branch (envelope: commit, don't push). Don't proceed on a dirty
   tree.
2. **Surface** — read the storage cascade; collect pending tasks, open questions, blockers.
3. **Select** — pick the next task by the decision-basis and record it. No propose-and-wait;
   the basis decides. Identify which skills the slice needs.

## Planning

4. **Specs** — read the project's source of truth; extract acceptance criteria; note gaps.
5. **Draft plan** — list every change (specs first, then tests, then code), file by file.
6. **Simplify plan** — cut to an elegant just-enough fit; prefer deletions; don't cut
   spec/called-out edge cases.
7. **Test plan** — define validation before implementing; TDD by default (failing test
   first); name the substitute verification where TDD doesn't apply. Don't invent fake tests
   for docs-only, config-only, mechanical, or untestable changes.
8. **Record the plan** in the durable record and proceed. No confirm gate — the basis and the
   envelope replace it. If the plan exceeds the decision-basis (a genuinely silent, expensive,
   irreversible fork), log a blocker and pick up the next unblocked slice.

## TDD execution

Delegate the slice's edits to a subagent by default (see Thin orchestrator) — the driver holds
the plan and the summary, not the file contents. Split a multi-file slice into one subagent per
non-overlapping file group so parallel edits don't collide.

9. **Red** — add/update tests first; confirm they fail for the expected reason. State the
   exception + substitute verification if TDD doesn't apply.
10. **Green** — smallest change that satisfies the tests; stay within the recorded plan.
11. **Refactor** — clean up without behavior change; prefer deletions; elegant just-enough.
12. **Verify** — run the planned narrow + broad checks; loop red/green/refactor on a missing
    case; substitute the closest useful check if one can't run.

## Review and close

13. **Audit** — re-read every changed file (not just diffs). Categorize findings: **Violation**
    (clear skill/spec rule broken — blocks, must fix), **Borderline** (judgment call the skill
    permits — flag once, leave), **Out-of-scope** (pre-existing, not introduced here — note,
    don't fix). Fix every Violation and re-audit; the audit converges. Run tests + lints.
14. **Commit** — commit on the current branch using the repo's commit convention.
    **Envelope: do not push, publish, release, or deploy** — those wait for the human.
15. **Checkpoint** — update the breadcrumb / durable record (what landed, what's next, open
    blockers) so a crash or compaction leaves a clean restore point. No `/ace-save` or
    `/clear` between slices — the subagent boundary gives fresh context, the breadcrumb gives
    continuity.

## Two-phase audit every 2–3 slices

Spawn audit subagents: (A) code-quality (correctness, DRY, test strength, skill compliance over
the batch), then (B) architecture/cleanup (boundaries, layering, dead code, simplification over
the module graph). Fold findings into the plan as fix-slices; don't let them stall forward
motion.

## Loop or stop

Verify passes + slices remain → spawn the next. Stop only at a genuine blocker (basis-silent +
expensive + irreversible, logged), a failed verify the subagent couldn't fix, or an empty plan
— leaving the breadcrumb pointing at the next step. On stop, write the run summary to `.afk.log`.

## Storage cascade

Same as the attended workflow ($ARGUMENTS → built-in tasks → agent inbox → task tracker →
scratch files → git state).
