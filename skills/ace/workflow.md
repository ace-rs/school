# ACE Workflow

Read `ledger.md` in this directory and `ace-save/trail.md` before writing the trail.

Use **Resume a task** (1–6) for an approved action request or a coherent existing slice.
Use **Assess work** (1, 2, 4, 5) for a read-only review request; report findings without
editing or committing. Use **Discover a task** (1) when no task is active.

## **1. Orient**

Read the conversation, loaded skills, project instructions and specs, `.ace/save.md`,
`.ace/save.ledger.md`, and git state when present. Present recorded statuses and
provenance before adding your own derivation. Treat SETTLED and KILLED items as closed
unless the user reopens them. Without quoted user words, treat either as agent-inferred.

Inspect existing changes. Continue a coherent slice at its earliest unproven phase only
when its scope, authority, and prerequisite evidence can be reconstructed. If changes are
mixed, their origin is unclear, or authority for the next action is absent, present the
exact state and wait for the user's disposition. This is a Wait. Do not select new work
over an unresolved tree.

For task discovery, search the storage cascade below, present what is pending, and propose
the natural next task. Wait for the user's confirmation before planning it. A direct
action request authorizes only the action it names. A request to check, review, audit, or
investigate authorizes assessment and a findings report only.

Evidence: the selected task, source of authority, current repository state, and next
phase. For discovery, the user's confirmation is required evidence before phase 2.

## **2. Plan**

Read the project's source of truth and extract the acceptance criteria. Resolve the
smallest coherent design that satisfies them. Name the main areas involved and the
validation appropriate to each kind of change. Use failing tests first for behavior when
they fit; use rendering, link, consistency, or inspection checks for prose and config.

Present the plan before editing. Proceed when the user already approved the action and
approach; otherwise wait for approval. This is a Wait. Keep edits within the agreed task;
include supporting changes required to complete it. A changed goal, scope, acceptance
criterion, or outward action requires new authority.

For assessment-only work, define the scope and checks, then continue to phase 4 without
editing. Evidence: acceptance criteria, approach, validation, and applicable approval.

## **3. Implement**

Make the planned change. For behavior changes, establish the expected failure, make it
pass, then improve the resulting structure. For other changes, apply their planned
validation setup. Prefer deletion and reuse over new units. Stop and surface unexpected
requirements instead of silently widening the goal.

Evidence: the resulting diff and any expected failure used to guide a behavior change.

## **4. Verify**

Run the planned narrow and broad checks for every changed file. Add missing behavior cases
and repeat implementation when a gap appears. If a planned check cannot run, state why and
run the closest useful check. Preserve the decisive results for the final report.

In assessment-only work, run read-only checks and preserve their results. Do not repair a
finding without explicit authority to edit.

## **5. Audit**

Inspect the entire selected scope, including every changed file for an action task or
every selected path and commit for an assessment. Verify that each relevant change serves
the agreed task and that the result matches the user request, specs, project conventions,
and loaded skills.
Classify findings:

- **Violation** — a clear rule, requirement, or scope breach. In an authorized action
  task, fix it, verify again, and restart the full audit. In assessment-only work, record
  it without editing.
- **Borderline** — a permitted judgment call. Flag it once and leave it unless the user
  asks to change it.
- **Out of scope** — pre-existing and not introduced here. Report it without fixing it.

An authorized action task proceeds only after a fresh full pass finds zero Violations and
requires no changes. An assessment completes with the full-scope findings and checks; it
does not imply repair.

## **6. Close**

When repository instructions authorize autonomous local commits, commit the coherent
slice on the current branch using its convention. Otherwise report the reviewed diff and
wait. This is a Wait. A local commit grants no authority to push or take another outward
action. Assessment-only work never commits.

Update the `.ace/` trail when continuity needs it. Read `ace-save/trail.md` first. Put
completed context in `save.md`; put open items in `save.ledger.md` with status and
provenance. Then loop to Orient or stop when the requested work is complete.

## Completion evidence

Report the selected operation, scope, verification results, audit result, and close state.
For a completed action, cite the clean full audit and commit hash or reviewed uncommitted
diff. For an assessment, cite the checked scope and categorized findings. For a Wait or
blocker, state the missing authority, input, or evidence and the phase that resumes next.

## Broader audit

Run a broader code and architecture audit when changes cross architectural boundaries or
the normal audit reveals a systemic problem. Fold resulting work into a new plan.

## Storage cascade

Read the one or two most likely sources first; widen only when they are empty,
contradictory, or incomplete. Write to the most fitting existing location.

1. `$ARGUMENTS` or the user's direct request.
2. The project's task tracker.
3. `.ace/save.md`, `.ace/save.ledger.md`, or an established project task file.
4. Agent inbox when the project uses one.
5. `git status`, `git diff`, and recent git history.
