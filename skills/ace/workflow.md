# ACE Workflow

Read `ledger.md` in this directory. Work through six phases. Keep decisive evidence in
the conversation or durable trail; do not emit a marker for routine steps.

## 1. Orient

Read the conversation, loaded skills, project instructions and specs, `.ace/save.md`,
`.ace/save.ledger.md`, and git state when present. Present recorded statuses and
provenance before adding your own derivation. Treat SETTLED and KILLED items as closed
unless the user reopens them. Without quoted user words, treat either as agent-inferred.

Inspect existing changes. Continue a coherent slice at its earliest unproven phase when
its scope and prerequisite evidence can be reconstructed. If changes are mixed or their
origin is unclear, present the exact state and wait for the user's disposition. Do not
select new work over an unresolved tree.

For task discovery, search the storage cascade below, present what is pending, and propose
the natural next task. Stop for the user's confirmation before planning it. A direct user
request already supplies that confirmation.

## 2. Plan

Read the project's source of truth and extract the acceptance criteria. Resolve the
smallest coherent design that satisfies them. Name the main areas involved and the
validation appropriate to each kind of change. Use failing tests first for behavior when
they fit; use rendering, link, consistency, or inspection checks for prose and config.

Present the plan before editing. Proceed when the user already approved that approach;
otherwise wait for approval. Keep edits within the agreed task; include supporting changes
needed to complete it, and ask before unrelated cleanup or expanding the goal. A changed
goal, scope, or acceptance criterion requires new approval.

## 3. Implement

Make the planned change. For behavior changes, establish the expected failure, make it
pass, then improve the resulting structure. For other changes, apply their planned
validation setup. Prefer deletion and reuse over new units. Stop and surface unexpected
requirements instead of silently widening the goal.

## 4. Verify

Run the planned narrow and broad checks for every changed file. Add missing behavior cases
and repeat implementation when a gap appears. If a planned check cannot run, state why and
run the closest useful check. Preserve the decisive results for the final report.

## 5. Audit

Review `git diff --stat`, then re-read every changed file. Verify that each change serves
the agreed task and that the result matches the user request, specs, project conventions,
and loaded skills.
Classify findings:

- **Violation** — a clear rule, requirement, or scope breach. Fix it, verify again, and
  restart the full audit.
- **Borderline** — a permitted judgment call. Flag it once and leave it unless the user
  decides otherwise.
- **Out of scope** — pre-existing and not introduced here. Report it without fixing it.

Proceed only after a fresh full pass finds zero Violations and requires no changes.

## 6. Close

When repository instructions authorize autonomous local commits, commit the coherent
slice on the current branch using its convention. A local commit grants no authority to
push or take another outward action.

Update the `.ace/` trail when continuity needs it. Read `ace-save/trail.md` first. Put
completed context in `save.md`; put open items in `save.ledger.md` with status and
provenance. Then loop to Orient or stop when the requested work is complete.

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
