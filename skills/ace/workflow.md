# ACE Workflow

## The stamp chain

Every step in this workflow ends with a **stamp** — one line:

```
⛓ <step> | files: <paths touched this step> | ev: "<decisive line>" | next: <step>
```

- **Evidence is quoted, never re-pasted.** The full artifact — plan text, failing-test
  output, command results — appears exactly once, where the step produced it: the tool
  output or prose already in the transcript. `ev:` quotes at most two decisive lines
  from it, verbatim — the failing assertion, the pass count, the commit hash. A line
  you cannot quote verbatim from this step's own output is no evidence, and a stamp
  without evidence is no stamp. Where the step's work product is prose just presented
  (a plan), the stamp follows it and points at it (`ev: "plan above, 4 files"`) — it
  never restates it.
- **No skip vocabulary.** There is no "skipped", "not applicable", "inferred done", or
  "effectively covered" — those statuses do not exist in this workflow. Every step runs
  for every task. A step whose honest execution is small still runs and leaves real
  evidence: the test plan for a docs change is a real plan (render, link-check,
  spec-vs-code consistency), not a waiver.
- **Chained entry.** Every step opens by reprinting the previous step's stamp line,
  verbatim. No stamp to reprint → the step cannot be entered; go back and produce it.
  Orientation picks the entry step exactly once (with its own stamp citing the evidence
  for the pick); from then on the next step is read off the last stamp, never
  re-derived.
- **Stamp-named succession.** The only step you may open is the one the last stamp
  names, drawn from the fixed order below. "What's next" is never a judgment call after
  entry — it is written in the stamp line you must reprint to proceed.
- **File-set binding.** The simplified plan (step 6) is the binding file-set: every
  path the task covers, enumerated once, in the plan prose its stamp points at; the
  test plan (step 7) covers those same paths per class. Later stamps list only the
  files touched that step and cite the rest as `files: <touched> per ⛓ simplify`. From
  step 9 on, you may only touch files in the binding list. Touching an unlisted file is
  not a small overrun to note — it is the gate: stop the edit, return to step 5, and
  re-plan with the file included. A rationale like "docs-only" or "no tests needed for
  this part" covers exactly the paths listed under it and says nothing about any other
  file.
- **Three chains, always.** The normal task is spec + tests + code — the workflow
  mandates spec-first, so all three classes exist in every real task and each runs the
  full cycle. A class that seems absent is a mis-scoped task, not an exemption: a spec
  edit with no code chain means spec and code now disagree, which is itself the code
  task. Absence is never inferred.
- **Exemptions need the user's verbatim words.** The only valid deviation from a step
  cites the user's in-session words, quoted in the stamp. A self-minted rationale
  ("it's a spec, no test needed") quotes nobody and is void on its face. The agent has
  no authority to mint an exemption.

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
- **A Monitor you didn't start this session is still running?** → likely an ace-connect
  engine that outlived a `/clear` (context wiped, Monitor and slug survive). Load
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
   to task selection with a dirty working tree. Stamp ev: the decisive `git status`
   line, clean or resolved; next: surface.

2. **Surface** — open by reprinting the cleanup stamp. Read the storage cascade in order
   (below); collect pending tasks, open questions, and blockers. Present them as a
   list. If nothing found, suggest tasks or state "nothing pending." Stamp ev: points
   at the list above and names the cascade sources read; next: propose.

3. **Propose** — open by reprinting the surface stamp. Suggest the natural next task from
   what was surfaced, and identify which skills to load. **Stop.** Don't load skills,
   don't start execution. Wait for the user to confirm or refine. On confirm ("ok",
   "go", "do it", or a task pick), stamp with the user's confirming words quoted;
   next: specs. `/ace` need not be invoked again.

## Planning

4. **Specs** — open by reprinting the propose stamp (the user's confirmation). Read the
   project's source of truth (`docs/spec/` and any design docs, PRDs, RFCs it points
   at; start from `docs/spec/README.md` if it has an index). The spec is authoritative —
   comply with it rather than re-deciding a question it already settles. Compare against
   the ask; note gaps, contradictions, outdated sections; extract the acceptance
   criteria. Don't edit yet. Stamp ev: the spec files read, pointing at the criteria
   above; next: draft plan.

5. **Draft plan** — open by reprinting the specs stamp. Explore the space: alternatives,
   trade-offs, edge cases. List every change — spec updates first, then tests, then
   code — **file by file, path by path**: this list is the file-set later steps are
   bound to. For any durable doc this task produces, name its target `docs/` folder now
   by walking the routing gate in `docs/README.md` — decide placement at plan time, not
   when filing. If ambiguous, ask. If too large, propose a breakdown first. Identify
   which skills to load. Stamp ev: points at the file-by-file plan above; next:
   simplify plan.

6. **Simplify plan** — open by reprinting the draft-plan stamp. Cut anything unnecessary;
   prefer deletions; merge combinable steps. Aim for elegant just-enough — not the
   minimum possible, not the perfect solution, an elegant fit for the ask. Don't cut
   requirements or edge cases the spec or user called out — simplify the *how*, not the
   *what*. Stamp ev: points at the surviving file-by-file plan above (the binding
   file-set); next: test plan.

7. **Test plan** — open by reprinting the simplify stamp. Define validation before
   implementation, **per change-class in the plan** (spec, tests, code): tests to
   add/update, the narrow command to run first, broader checks before commit, any
   manual verification. TDD by default (plan the failing test first). Where TDD's
   red/green shape doesn't fit a class (a docs edit has no failing test), the class
   still gets a real verification plan — render, link-check, consistency against
   code — named here, per path. No class is left without a plan; no plan waives
   another class's paths. Stamp ev: points at the per-class, per-path validation plan
   above; next: confirm.

8. **Confirm** — open by reprinting the test-plan stamp. Present the simplified plan and
   test plan. **Stop.** Don't edit files, don't run commands, don't implement. Wait for
   explicit approval. If the user refines or redirects, return to step 5. Stamp: the
   user's approving words quoted; next: red.

## TDD execution

Size the execution before editing (across red, green, refactor): single-file or
self-contained work stays in the main context; multi-file or cross-module work warrants
isolated agents, one per non-overlapping file group. Criterion: context need, not line
count. An isolated agent receives the stamps its slice needs and must return its own
stamps — file-set, evidence, next — or its slice is not done.

9. **Red** — open by reprinting the confirm stamp (the approved plan + test plan). Add or
   update tests first, touching only files in the test-plan's file-set; run the narrow
   target; confirm it fails for the expected reason. For a class whose plan named a
   substitute verification, execute the substitute's setup now. If something unexpected
   comes up, stop and surface it — don't work around it silently. Stamp: files touched;
   ev: the failing assertion line (or the substitute's decisive line); next: green.

10. **Green** — open by reprinting the red stamp. Make the smallest change that
    satisfies those tests, touching only files in the plan's file-set. A file you need
    but didn't list means the plan was wrong, not that the list was advisory: stop,
    return to step 5. Stamp: files touched; ev: the passing narrow-test summary line;
    next: refactor.

11. **Refactor** — open by reprinting the green stamp. Clean up without changing behavior,
    within the same file-set; prefer deletions; elegant just-enough. Don't cut
    requirements or edge cases the spec or user called out. If no cleanup is needed,
    the stamp says so explicitly with the reason — that is a run with small evidence,
    not a skip. Stamp ev: a one-line cleanup summary (or the explicit no-cleanup
    finding) plus the still-passing test line; next: verify.

12. **Verify** — open by reprinting the refactor stamp. Run the planned narrow and broad
    checks from step 7, every class, every path. A missing test case → add the test and
    loop red/green/refactor again (the loop re-enters at 9 with a stamp noting why). If
    a planned check can't run, record why in the stamp and substitute the closest
    useful verification. Stamp ev: one decisive line per planned check, from its actual
    output; next: audit.

## Review and close

13. **Audit** — open by reprinting the verify stamp. First clause is mechanical: walk
    `git diff --stat` and confirm **every changed file appears in the plan's file-set
    and inside a complete stamp chain** (plan → test plan → red → green → verify). A
    file outside the chain is the laundering breach — return to step 5 for it. Then the
    content pass: re-read every changed file (not just diffs); verify code matches
    spec, the simplified plan was followed, conventions and loaded skill rules
    respected. Categorize every finding:

   - **Violation** — clear skill or spec rule broken, or a chain/coverage breach.
     Blocks; must be fixed.
   - **Borderline** — judgment call the skill permits. Flag once; leave unless the user
     pushes for a fix.
   - **Out of scope** — pre-existing, not introduced by this change. Note in the
     report; don't fix unless asked.

   Run tests and lints if available and not already covered by verification. If
   anything's off, fix it and re-audit — the audit converges, it doesn't just
   terminate. Don't proceed until the Violation bucket is empty. Stamp ev: finding
   counts by bucket, Violation = 0; next: commit.

14. **Commit** — open by reprinting the audit stamp (empty Violation bucket). Commit using
    the repository's existing commit conventions and message format. Stamp ev: the
    commit hash and subject line; next: checkpoint.

15. **Checkpoint** — open by reprinting the commit stamp. Persist progress before looping
    back to task discovery. Two modes:

   - **Light (default)** — update the `.ace/` trail or tasks. What was done goes in
     `save.md`; next steps and open questions go in `save.ledger.md`, each with a
     status and a provenance. Read `ace-save/trail.md` before writing either file and
     follow it — revise `save.md` in place, never regenerate it, and never drop a line
     to keep the file short. Just enough that the next loop or a surprise compaction
     doesn't lose the thread. Stamp ev: the trail files written; next: task discovery
     (1).

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
