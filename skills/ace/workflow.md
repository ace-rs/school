# ACE Workflow

## Orientation

Before starting from step 1, figure out where you already are. Check conversation
history, git state (`git status`, `git log --oneline -5`), loaded skills, and any
in-progress tasks or scratch files. You may already be mid-workflow — if so, pick up
from the right phase instead of restarting. The phases below are a map, not a
mandatory start-to-finish sequence.

- **Dirty working tree with coherent changes?** → you're likely in verify, audit, or
  commit.
- **Plan already confirmed but no changes yet?** → you're in red.
- **Tests failing for the expected reason?** → you're in green.
- **Fresh session, clean tree?** → start at task discovery.
- **Just committed?** → you're at checkpoint, then loop back to task discovery.

## Task discovery

1. **Cleanup** — check `git status` and `git diff`. If there are uncommitted or staged
   changes from prior work, present them to the user and ask whether to commit, stash, or
   discard. Do not proceed to task selection with a dirty working tree.

2. **Surface** — read the storage cascade in order (see reference below). Collect
   pending tasks, open questions, and blockers. Present them as a list to the user. If
   nothing found, suggest tasks or state "nothing pending."

3. **Propose** — suggest the natural next task based on what was surfaced. Identify which
   skills to load from the available list. Stop. Do not load skills, do not start the task
   execution workflow. Wait for the user to confirm or refine. When the user confirms
   (e.g. "ok", "go", "do it", or selects a task), proceed directly to planning — `/ace`
   does not need to be invoked again.

## Planning

4. **Specs** — find and read specs, design docs, PRDs, RFCs, ADRs, or whatever the project
   uses as source of truth. Compare against what the user is asking for — note gaps,
   contradictions, or outdated sections. Extract acceptance criteria. Do not edit anything
   yet; carry findings forward to the plan step.

5. **Draft Plan** — explore the problem space: consider alternatives, trade-offs, and edge
   cases. List every change needed: spec updates first, then tests and code. For each
   change, state the file and what will change. If the task is ambiguous, ask. If the task
   is too large, propose a breakdown into smaller steps before continuing. Identify which
   skills to load.

6. **Simplify Plan** — review the draft plan and cut anything unnecessary. Prefer
   deletions over additions. Aim for just-enough — not the minimum possible, not the
   perfect solution, but an elegant fit for the ask. Merge steps that can be combined.
   If a simpler approach exists, switch to it. Do not cut requirements or skip edge
   cases that the spec or user called out — simplify the *how*, not the *what*.

7. **Test Plan** — define how the change will be validated before implementation starts.
   Include tests to add or update, the narrow command to run first, broader checks to run
   before commit, and any manual verification needed. TDD is the default for code changes:
   plan the failing test first. If TDD does not apply, state why and name the substitute
   verification. Do not invent fake tests for docs-only, config-only, mechanical, or
   untestable changes.

8. **Confirm** — present the simplified plan and test plan to the user. Stop. Do not
   edit files, do not run commands, do not start implementing. Wait for explicit
   approval. If the user refines or redirects, return to the plan step.

## TDD execution

Size the execution before editing — applies across red, green, and refactor:
single-file or self-contained work stays in the main context; multi-file work or
cross-module reasoning warrants isolated agents, one per non-overlapping file group.
Criterion: context need, not line count.

9. **Red** — on approval, add or update tests first. Run the narrow test target and
   confirm it fails for the expected reason. If TDD does not apply, state the approved
   exception and use the planned substitute verification instead. Follow loaded skill
   conventions. If something unexpected comes up, stop and surface it rather than working
   around it silently.

10. **Green** — make the smallest implementation change that satisfies the failing
    tests. If red was skipped under an approved exception, make the approved change here
    and carry the substitute verification forward. Keep the change within the confirmed
    plan. If the implementation needs a different behavior, scope, or file set, return to
    planning before continuing.

11. **Refactor** — after the narrow tests pass, clean up the implementation without
    changing behavior. Prefer deletions over additions. Aim for just-enough — not the
    minimum possible, not the perfect solution, but an elegant fit for the ask. Do not cut
    requirements or skip edge cases that the spec or user called out — simplify the *how*,
    not the *what*. If no cleanup is needed, say so and move on.

12. **Verify** — run the planned narrow and broad checks. If verification reveals a
    missing test case, add the test and loop through red, green, and refactor again. If a
    planned check cannot be run, record why and substitute the closest useful
    verification.

## Review and close

13. **Audit** — re-read every changed file (not just diffs). Verify alignment: code
    matches spec, the simplified plan was followed, the test plan was executed or
    deviations were justified, conventions are followed, and loaded skill rules are
    respected. Categorize every finding:

   - **Violation** — a clear skill or spec rule broken. Blocks; must be fixed.
   - **Borderline** — judgment call where the skill permits multiple readings. Flag once;
     leave unless the user pushes for a fix.
   - **Out of scope** — pre-existing, not introduced by this change. Note in the report;
     don't fix unless asked.

   Run tests and lints if available and not already covered by verification. If anything
   is off, fix it and re-audit — the audit converges, it doesn't just terminate. Do not
   proceed to commit until the Violation bucket is empty.

14. **Commit** — commit the work using the repository's existing commit conventions and
    message format.

15. **Checkpoint** — update scratch files or tasks with what was done, what's next, and
    any open questions. This is a lightweight save — just enough that the next `/ace` loop
    or a surprise compaction doesn't lose the thread. For full session-ending persistence
    (before `/clear` or ending a session), recommend `/ace-save` to the user.

## Storage cascade

Pick the one or two most likely to have what you need; widen only if they come up empty,
contradict each other, or seem to lack important context. Write to the most fitting
available location — e.g. persist tasks in the project's issue tracker if one is in use,
not scratch files.

1. **`$ARGUMENTS`** — user told you what to focus on.
2. **Built-in tasks/memory** — survives compaction, not `/clear` or session exit.
3. **Agent inbox** — if an ace-connect bridge is running and `.inbox.log` exists
   in the repo root, read it for tasks queued by peer agents.
4. **Task tracker** — Linear, GitHub Issues, Jira, or whatever the project uses.
5. **Scratch files** — `.tasks.md`, `TODO.md`, CLAUDE.md scratchpad.
6. **Git state** — `git status`, `git diff`, `git log --oneline -20`.
