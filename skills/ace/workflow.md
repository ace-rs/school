# ACE Workflow

## The stamp chain

Every step in this workflow runs under the stamp-chain contract in `ledger.md`, in
this skill's directory — read it and follow it: evidence quoted, never re-pasted;
mandatory reprint-or-reuse entry; stamp-named succession; no skip vocabulary; exemptions only in the
user's verbatim words. This workflow's stamp adds a `files:` field:

```
⛓ <step> | files: <paths touched this step> | ev: "<decisive line>" | next: <step>
```

Apply `ledger.md`'s display rule to this extended stamp: fenced on Markdown conversation
surfaces and plain text everywhere else. Emit no ANSI escapes.

Two rules are this workflow's own:

- **File-set binding.** The simplified plan (step 6) is the binding file-set: every
  path the task covers, enumerated once, in the plan prose its stamp points at; the
  test plan (step 7) covers those same paths per class. Later stamps list only the
  files touched that step and cite the rest as `files: <touched> per ⛓ simplify`. From
  step 9 on, you may only touch files in the binding list. Touching an unlisted file
  activates a file-set rebind. Do not touch the new path. Close the current step with
  `next: 5 Draft plan`, complete steps 5–7 with the
  expanded set, then use step 8's rebind branch. A changed goal, scope, or acceptance
  criterion is a task change, not a file-set correction: surface it and wait for the
  user. A rationale like "docs-only" or "no tests needed for this part" covers exactly
  the paths listed under it and says nothing about any other file.
- **Three chains, always.** The normal task is spec + tests + code — the workflow
  mandates spec-first, so all three classes exist in every real task and each runs the
  full cycle. A class that seems absent is a mis-scoped task, not an exemption: a spec
  edit with no code chain means spec and code now disagree, which is itself the code
  task. Absence is never inferred.

## Orientation

Before anything else, figure out where you already are — conversation history, git
state (`git status`, `git log --oneline -5`), loaded skills, in-progress tasks or
scratch files. You may be mid-workflow. The step order below is fixed; orientation's
only freedom is picking the **entry point**, once, with a stamp citing the evidence:

- **Dirty tree with coherent changes?** → enter at verify (12), audit (13), or
  commit (14).
- **Plan confirmed, no changes yet?** → enter at red (9).
- **Tests failing for the expected reason?** → enter at green (10).
- **Fresh session, clean tree?** → enter at task discovery (1).
- **Just committed?** → enter at checkpoint (15), then loop to task discovery.
- **A background listener you didn't start this session is still running (e.g. a
  Monitor task, on a harness that has one)?** → likely an ace-connect engine that
  outlived a `/clear` (context wiped, listener and slug survive). Load
  `ace-connect` to recover its wire format and mode before touching `.ace/connect.log`.

Entering mid-chain, reconstruct the artifacts your entry step depends on into the
transcript first — present the confirmed plan, the failing-test output, the diff — then
stamp pointing at them. If they can't be reconstructed, you are not where you thought:
enter earlier.

Resuming recorded work: read `.ace/save.md` and `.ace/save.ledger.md`.
**Present the record first:** statuses, provenance, next open item, as-is — before
anything of your own. An `agent:inferred` item is surfaced as your derivation, never as
a stated fact, and yours to withdraw. Say what you'd derive after that, labeled, at
most once. Ledger statuses bind: SETTLED/KILLED items are closed — reopening one is a
Violation, not diligence. Trust the citation, not the label: a SETTLED/KILLED item with
no quoted user phrase is treated as `agent:inferred` — a forgotten or mis-stamped
provenance resolves to the safe side.

Accused of losing or forgetting something ("you lost X", "we said Y"): grep the trail
and quote what you find *before* any self-diagnosis — never adopt the amnesia framing
unverified; a claim about your own failure is a causal claim like any other.

## Task discovery

1. **Cleanup** — check `git status` and `git diff`. Uncommitted or staged changes from
   prior work: present them and ask whether to commit, stash, or discard. Don't proceed
   to task selection with a dirty working tree.

2. **Surface** — open by reprinting or reusing the cleanup stamp. Read the storage cascade in order
   (below); collect pending tasks, open questions, and blockers. Present them as a
   list. If nothing found, suggest tasks or state "nothing pending."

3. **Propose** — open by reprinting or reusing the surface stamp. Suggest the natural next task from
   what was surfaced, and identify which skills to load. **Stop.** Don't load skills,
   don't start execution. Wait for the user to confirm or refine. The confirmation opens
   Specs and quotes the user's words. `/ace` need not be invoked again.

## Planning

4. **Specs** — open by reprinting or reusing the propose stamp (the user's confirmation). Read the
   project's source of truth (`docs/spec/` and any design docs, PRDs, RFCs it points
   at; start from `docs/spec/README.md` if it has an index). The spec is authoritative —
   comply with it rather than re-deciding a question it already settles. Compare against
   the ask; note gaps, contradictions, outdated sections; extract the acceptance
   criteria. Don't edit yet.

5. **Draft plan** — open by reprinting or reusing the specs stamp. Explore the space: alternatives,
   trade-offs, edge cases. List every change — spec updates first, then tests, then
   code — **file by file, path by path**: this list is the file-set later steps are
   bound to. For any durable doc this task produces, name its target `docs/` folder now
   by walking the routing gate in `docs/README.md` — decide placement at plan time, not
   when filing. If ambiguous, ask. If too large, propose a breakdown first. Identify
   which skills to load.

6. **Simplify plan** — open by reprinting or reusing the draft-plan stamp. Cut anything unnecessary;
   prefer deletions; merge combinable steps. Aim for elegant just-enough — not the
   minimum possible, not the perfect solution, an elegant fit for the ask. Don't cut
   requirements or edge cases the spec or user called out — simplify the *how*, not the
   *what*.

7. **Test plan** — open by reprinting or reusing the simplify stamp. Define validation before
   implementation, **per change-class in the plan** (spec, tests, code): tests to
   add/update, the narrow command to run first, broader checks before commit, any
   manual verification. TDD by default (plan the failing test first). Where TDD's
   red/green shape doesn't fit a class (a docs edit has no failing test), the class
   still gets a real verification plan — render, link-check, consistency against
   code — named here, per path. No class is left without a plan; no plan waives
   another class's paths.

8. **Confirm or notify** — open by reprinting or reusing the test-plan stamp.

   - **Initial plan:** present the simplified plan and test plan. Stop and wait for
     explicit approval. The approval opens Red and quotes the user's words.
   - **File-set rebind after initial approval:** present the revised plan and test plan
     as a notification. Do not wait; the notification opens Red.

   If the user redirects either plan, return to step 5. A changed goal, scope, or
   acceptance criterion always uses the initial-plan branch.

## TDD execution

Size the execution before editing (across red, green, refactor): single-file or
self-contained work stays in the main context; multi-file or cross-module work warrants
isolated agents, one per non-overlapping file group. Criterion: context need, not line
count. An isolated agent receives the stamps its slice needs and must return its own
stamps — file-set, evidence, next — or its slice is not done.

9. **Red** — open by reprinting or reusing the confirm stamp (the approved plan + test plan). Add or
   update tests first, touching only files in the test-plan's file-set; run the narrow
   target; confirm it fails for the expected reason. For a class whose plan named a
   substitute verification, execute the substitute's setup now. If something unexpected
   comes up, stop and surface it — don't work around it silently.

10. **Green** — open by reprinting or reusing the red stamp. Make the smallest change that
    satisfies those tests, touching only files in the plan's file-set. A file you need
    but didn't list means the plan was wrong, not that the list was advisory: activate
    the file-set rebind and close this step with `next: 5 Draft plan`.

11. **Refactor** — open by reprinting or reusing the green stamp. Clean up without changing behavior,
    within the same file-set; prefer deletions; elegant just-enough. Don't cut
    requirements or edge cases the spec or user called out. If no cleanup is needed,
    the stamp says so explicitly with the reason — that is a run with small evidence,
    not a skip.

12. **Verify** — open by reprinting or reusing the refactor stamp. Run the planned narrow and broad
    checks from step 7, every class, every path. A missing test case → add the test and
    loop red/green/refactor again (the loop re-enters at 9 with a stamp noting why). If
    a planned check can't run, record why in the stamp and substitute the closest
    useful verification.

## Review and close

13. **Audit** — open by reprinting or reusing the verify stamp. First clause is mechanical: walk
    `git diff --stat` and confirm **every changed file appears in the plan's file-set
    and inside a complete stamp chain** (plan → test plan → red → green → refactor →
    verify). A
    file outside the chain is the laundering breach — activate the file-set rebind and
    close this step with `next: 5 Draft plan`. Otherwise, continue to the content
    pass: re-read every changed file (not just diffs); verify code matches spec, the
    simplified plan was followed, conventions and loaded skill rules respected.
    Categorize every finding:

   - **Violation** — clear skill or spec rule broken, or a chain/coverage breach.
     Blocks; must be fixed.
   - **Borderline** — judgment call the skill permits. Flag once; leave unless the user
     pushes for a fix.
   - **Out of scope** — pre-existing, not introduced by this change. Note in the
     report; don't fix unless asked.

   Run tests and lints if available and not already covered by verification. Treat the
   audit as a convergence loop: complete a full-scope pass, fix every Violation, verify
   the fixes, then restart the whole audit from its mechanical clause without stopping
   or handing control back. Never close the step from a dirty pass or a partial rescan.
   Proceed only after a fresh full-scope pass finds zero Violations and requires no
   changes.

14. **Commit** — open by reprinting or reusing the audit stamp (empty Violation bucket).
    Commit using the repository's existing commit conventions and message format.

15. **Checkpoint** — open by reprinting or reusing the commit stamp. Persist progress before looping
    back to task discovery. Two modes:

   - **Light (default)** — update the `.ace/` trail or tasks. What was done goes in
     `save.md`; next steps and open questions go in `save.ledger.md`, each with a
     status and a provenance. Read `ace-save/trail.md` — in the `ace-save` skill's
     directory, sibling to this one — before writing either file and follow it —
     revise `save.md` in place, never regenerate it, and never drop a line to keep
     the file short. Just enough that the next loop or a surprise compaction
     doesn't lose the thread.

   - **Full save + clear** — when the just-finished work was context-heavy, escalate.
     Heaviness lives in the change *or* the conversation: many files touched, large
     reads, isolated agents, a long planning/design discussion (even if the change was
     tiny), many turns, several tasks this session, or a compaction already fired. On
     any of these, run `ace-save` **immediately and without asking** — don't offer it
     as a choice, don't wait for approval (it's notes-only and reversible). Only
     *after* the save, recommend the user `/clear` and re-`/ace` for fresh context —
     that, and only that, is theirs to call. Stop there; don't barrel into task
     discovery in a bloated context. If the user declines `/clear`, fall back to
     looping in-session.

   🚨 **Invariant (hard):** running `ace-save` is a precondition for naming `/clear`.
   Never suggest, mention, or hint at `/clear` in a turn that didn't run `ace-save`
   first — the save is automatic and unconditional. Heaviness only decides whether to
   *escalate* at all; it never gates the save once `/clear` is on the table.
   Recommending clear without a preceding save is a Violation.

   Heaviness is a judgment call, not a gauge reading — you can't see the context meter,
   so estimate from what the task and session actually involved.

## Two-phase audit every few tasks

Every 2–3 completed tasks, run a batch pass beyond the per-task audit. Spawn audit
subagents: (A) code-quality (correctness, DRY, test strength, skill compliance over the
batch), then (B) architecture/cleanup (boundaries, layering, dead code, simplification
over the module graph). Fold findings into the next plan as fix-tasks; don't let them
stall forward motion.

## Storage cascade

Pick the one or two most likely to have what you need; widen only if they come up empty,
contradict each other, or seem to lack important context. Write to the most fitting
available location — e.g. persist tasks in the project's issue tracker if one's in use,
not scratch files.

1. **`$ARGUMENTS`** — user told you what to focus on.
2. **Built-in tasks/memory** — survives compaction, not `/clear` or session exit.
3. **Agent inbox** — if an ace-connect bridge is running and `.ace/connect.log` exists,
   read it for tasks queued by peer agents.
4. **Task tracker** — Linear, GitHub Issues, Jira, or whatever the project uses.
5. **Scratch trail** — `.ace/save.md` (current state) and `.ace/save.ledger.md` (open
   items); fall back to any `.tasks.md`, `TODO.md`, or CLAUDE.md scratchpad.
6. **Git state** — `git status`, `git diff`, `git log --oneline -20`.
