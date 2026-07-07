# ACE Workflow

## Orientation

Before starting at step 1, figure out where you already are — conversation history, git
state (`git status`, `git log --oneline -5`), loaded skills, in-progress tasks or scratch
files. You may be mid-workflow; if so, resume at the right phase. The phases are a map, not
a mandatory start-to-finish sequence.

- **Dirty tree with coherent changes?** → verify, audit, or commit.
- **Plan confirmed, no changes yet?** → red.
- **Tests failing for the expected reason?** → green.
- **Fresh session, clean tree?** → task discovery.
- **Just committed?** → checkpoint, then loop back to task discovery.
- **A Monitor you didn't start this session is still running?** → likely an ace-connect
  engine that outlived a `/clear` (context wiped, Monitor and slug survive). Load
  `ace-connect` to recover its wire format and mode before touching `.inbox.log`.

## Task discovery

1. **Cleanup** — check `git status` and `git diff`. Uncommitted or staged changes from
   prior work: present them and ask whether to commit, stash, or discard. Don't proceed to
   task selection with a dirty working tree.

2. **Surface** — read the storage cascade in order (below); collect pending tasks, open
   questions, and blockers. Present them as a list. If nothing found, suggest tasks or state
   "nothing pending."

3. **Propose** — suggest the natural next task from what was surfaced, and identify which
   skills to load. **Stop.** Don't load skills, don't start execution. Wait for the user to
   confirm or refine. On confirm ("ok", "go", "do it", or a task pick), proceed to planning
   — `/ace` need not be invoked again.

## Planning

4. **Specs** — read the project's source of truth (specs, design docs, PRDs, RFCs, ADRs).
   Compare against the ask; note gaps, contradictions, outdated sections; extract acceptance
   criteria. Don't edit yet — carry findings forward to the plan.

5. **Draft plan** — explore the space: alternatives, trade-offs, edge cases. List every
   change (spec updates first, then tests, then code), file by file, stating what changes.
   If ambiguous, ask. If too large, propose a breakdown first. Identify which skills to load.

6. **Simplify plan** — cut anything unnecessary; prefer deletions; merge combinable steps.
   Aim for elegant just-enough — not the minimum possible, not the perfect solution, an
   elegant fit for the ask. Don't cut requirements or edge cases the spec or user called out
   — simplify the *how*, not the *what*.

7. **Test plan** — define validation before implementation: tests to add/update, the narrow
   command to run first, broader checks before commit, any manual verification. TDD by
   default (plan the failing test first); where it doesn't apply, state why and name the
   substitute verification. Don't invent fake tests for docs-only, config-only, mechanical,
   or untestable changes.

8. **Confirm** — present the simplified plan and test plan. **Stop.** Don't edit files,
   don't run commands, don't implement. Wait for explicit approval. If the user refines or
   redirects, return to the plan step.

## TDD execution

Size the execution before editing (across red, green, refactor): single-file or
self-contained work stays in the main context; multi-file or cross-module work warrants
isolated agents, one per non-overlapping file group. Criterion: context need, not line count.

9. **Red** — on approval, add or update tests first; run the narrow target; confirm it fails
   for the expected reason. If TDD doesn't apply, state the approved exception and use the
   planned substitute. Follow loaded skill conventions. If something unexpected comes up,
   stop and surface it — don't work around it silently.

10. **Green** — smallest change that satisfies the failing tests. If red was skipped under an
    approved exception, make the change here and carry the substitute forward. Stay within
    the confirmed plan; if behavior, scope, or file set must change, return to planning.

11. **Refactor** — once narrow tests pass, clean up without changing behavior; prefer
    deletions; elegant just-enough. Don't cut requirements or edge cases the spec or user
    called out — simplify the *how*, not the *what*. If no cleanup is needed, say so and
    move on.

12. **Verify** — run the planned narrow and broad checks. A missing test case → add the test
    and loop red/green/refactor again. If a planned check can't run, record why and
    substitute the closest useful verification.

## Review and close

13. **Audit** — re-read every changed file (not just diffs). Verify alignment: code matches
    spec, the simplified plan was followed, the test plan ran (or deviations were justified),
    conventions and loaded skill rules respected. Categorize every finding:

   - **Violation** — clear skill or spec rule broken. Blocks; must be fixed.
   - **Borderline** — judgment call the skill permits. Flag once; leave unless the user
     pushes for a fix.
   - **Out of scope** — pre-existing, not introduced by this change. Note in the report;
     don't fix unless asked.

   Run tests and lints if available and not already covered by verification. If anything's
   off, fix it and re-audit — the audit converges, it doesn't just terminate. Don't commit
   until the Violation bucket is empty.

14. **Commit** — commit using the repository's existing commit conventions and message
    format.

15. **Checkpoint** — persist progress before looping back to task discovery. Two modes:

   - **Light (default)** — update scratch files or tasks with what was done, what's next,
     open questions. Just enough that the next loop or a surprise compaction doesn't lose the
     thread. Then loop back to task discovery.

   - **Full save + clear** — when the just-finished work was context-heavy, escalate.
     Heaviness lives in the change *or* the conversation: many files touched, large reads,
     isolated agents, a long planning/design discussion (even if the change was tiny), many
     turns, several tasks this session, or a compaction already fired. On any of these, run
     `ace-save` **immediately and without asking** — don't offer it as a choice, don't wait
     for approval (it's notes-only and reversible). Only *after* the save, recommend the user
     `/clear` and re-`/ace` for fresh context — that, and only that, is theirs to call. Stop
     there; don't barrel into task discovery in a bloated context. If the user declines
     `/clear`, fall back to looping in-session.

   Judgment call, not a gauge reading — you can't see the context meter, so estimate from
   what the task and session actually involved.

## Two-phase audit every few tasks

Every 2–3 completed tasks, run a batch pass beyond the per-task audit. Spawn audit subagents:
(A) code-quality (correctness, DRY, test strength, skill compliance over the batch), then
(B) architecture/cleanup (boundaries, layering, dead code, simplification over the module
graph). Fold findings into the next plan as fix-tasks; don't let them stall forward motion.

## Storage cascade

Pick the one or two most likely to have what you need; widen only if they come up empty,
contradict each other, or seem to lack important context. Write to the most fitting available
location — e.g. persist tasks in the project's issue tracker if one's in use, not scratch
files.

1. **`$ARGUMENTS`** — user told you what to focus on.
2. **Built-in tasks/memory** — survives compaction, not `/clear` or session exit.
3. **Agent inbox** — if an ace-connect bridge is running and `.inbox.log` exists in the repo
   root, read it for tasks queued by peer agents.
4. **Task tracker** — Linear, GitHub Issues, Jira, or whatever the project uses.
5. **Scratch files** — `.tasks.md`, `TODO.md`, CLAUDE.md scratchpad.
6. **Git state** — `git status`, `git diff`, `git log --oneline -20`.
