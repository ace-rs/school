# ACE Workflow

## Orientation

Before starting from step 1, figure out where you already are. Check conversation history,
git state (`git status`, `git log --oneline -5`), loaded skills, and any in-progress tasks
or scratch files. You may already be mid-workflow — if so, pick up from the right phase
instead of restarting. The phases below are a map, not a mandatory start-to-finish sequence.

- **Dirty working tree with coherent changes?** → you're likely in audit or commit.
- **Plan already confirmed but no changes yet?** → you're in implement.
- **Fresh session, clean tree?** → start at task discovery.
- **Just committed?** → you're at checkpoint, then loop back to task discovery.

## Task discovery

1. **Cleanup** — check `git status` and `git diff`. If there are uncommitted or staged
   changes from prior work, present them to the user and ask whether to commit, stash, or
   discard. Do not proceed to task selection with a dirty working tree.

2. **Surface** — read the storage cascade in order (see reference below). Collect pending
   tasks, open questions, and blockers. Present them as a list to the user. If nothing found,
   suggest tasks or state "nothing pending."

3. **Propose** — suggest the natural next task based on what was surfaced. Identify which
   skills to load from the available list. Stop. Do not load skills, do not start the task
   execution workflow. Wait for the user to confirm or refine. When the user confirms (e.g.
   "ok", "go", "do it", or selects a task), proceed directly to task execution — `/ace` does
   not need to be invoked again.

## Task execution

4. **Specs** — find and read specs, design docs, PRDs, RFCs, ADRs, or whatever the project
   uses as source of truth. Compare against what the user is asking for — note gaps,
   contradictions, or outdated sections. Do not edit anything yet; carry findings forward to
   the plan step.

5. **Plan** — explore the problem space: consider alternatives, trade-offs, and edge cases.
   List every change needed: spec updates first, then code. For each change, state the file
   and what will change. If the task is ambiguous, ask. If the task is too large, propose a
   breakdown into smaller steps before continuing. Identify which skills to load.

6. **Simplify** — review the plan and cut anything unnecessary. Prefer deletions over
   additions. Aim for just-enough — not the minimum possible, not the perfect solution, but
   an elegant fit for the ask. Merge steps that can be combined. If a simpler approach exists,
   switch to it. Do not cut requirements or skip edge cases that the spec or user called out —
   simplify the *how*, not the *what*.

7. **Confirm** — present the final plan to the user. Stop. Do not edit files, do not run
   commands, do not start implementing. Wait for explicit approval. If the user refines or
   redirects, return to the plan step.

8. **Implement** — on approval, make the changes. Spec updates first, then code. Follow
   loaded skill conventions. If something unexpected comes up during implementation, stop and
   surface it rather than working around it silently. Size the execution: single-file or
   self-contained work stays in the main context with parallel `Edit` calls; multi-file work
   or cross-module reasoning warrants `isolation: worktree` agents, one per non-overlapping
   file group. Criterion: whether it needs its own context window, not line count.

9. **Audit** — re-read every changed file (not just diffs). Verify alignment: code matches
   spec, conventions are followed, loaded skill rules are respected. Check that tests exist,
   align with the changes, and cover the important cases. Categorize every finding:

   - **Violation** — a clear skill or spec rule broken. Blocks; must be fixed.
   - **Borderline** — judgment call where the skill permits multiple readings. Flag once;
     leave unless the user pushes for a fix.
   - **Out of scope** — pre-existing, not introduced by this change. Note in the report;
     don't fix unless asked.

   Run tests and lints if available. If anything is off, fix it and re-audit — the audit
   converges, it doesn't just terminate. Do not proceed to commit until the Violation bucket
   is empty.

10. **Commit** — commit the work per `general-coding` commit conventions. Follow the
    project's existing message format.

11. **Checkpoint** — update scratch files or tasks with what was done, what's next, and any
    open questions. This is a lightweight save — just enough that the next `/ace` loop or a
    surprise compaction doesn't lose the thread. For full session-ending persistence (before
    `/clear` or ending a session), recommend `/ace-save` to the user.

## Storage cascade

Pick the one or two most likely to have what you need; widen only if they come up empty,
contradict each other, or seem to lack important context. Write to the most fitting
available location — e.g. persist tasks in the project's issue tracker if one is in use,
not scratch files.

1. **`$ARGUMENTS`** — user told you what to focus on.
2. **Built-in tasks/memory** — survives compaction, not `/clear` or session exit.
3. **Task tracker** — Linear, GitHub Issues, Jira, or whatever the project uses.
4. **Scratch files** — `.tasks.md`, `TODO.md`, CLAUDE.md scratchpad.
5. **Git state** — `git status`, `git diff`, `git log --oneline -20`.
