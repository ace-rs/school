---
name: ace-init
description: >
  Onboard a repo into ACE. TRIGGER on `/ace-init`, "initialize ACE", "onboard this repo",
  the first setup after `ace setup`, a material project-shape change, or an explicit
  request for its optional spec run. DO NOT TRIGGER at session boundaries, for routine
  work, or to start a spec run without the user's request.
argument-hint: "[optional focus, e.g. 'skills only' or 'docs too']"
---

# ace-init

Print `## ace-init` as the first line.

Configure ACE for the repository and leave durable orientation for later sessions.

## Menu

| Operation             | Steps | Use when                                             |
|-----------------------|-------|------------------------------------------------------|
| Lay down structure    | S1–S8 | first onboarding or a material project-shape change  |
| Run the optional spec | F1–F7 | code lacks durable explainers and the user approves  |

Complete S1–S8 before the first spec run. For a later spec-only request, resume at F1 when
S8's installed files and review evidence still match the repo. Otherwise return to S2,
record the earliest stale S step in the plan, and resume from there. F1 is a separate
Wait. `$ARGUMENTS` narrows the requested scope.

## Procedure evidence

Read `ace/ledger.md` in the `ace` skill's directory. Keep `.ace/init-plan.md`, the S6
authorization, the `ace link` result, and each review result as evidence. For a spec run,
also keep the separate F1 authorization. Do not print per-step markers.

## Lay down structure

- **S1. Check prerequisites.** Confirm that `ace setup` has produced an ACE config. If it
  has not, report that prerequisite and stop. Do not invoke a harness-native initializer.
  Read the repo's always-loaded instructions and any durable docs rules before planning.
- **S2. Open the plan.** Create or reopen `.ace/init-plan.md`. Read an existing plan and
  reconcile it with the current repo before using it. Check whether `.ace/` is gitignored.
  When it is not, record the required `.gitignore` edit in the plan; do not make that
  tracked edit before approval. Keep every proposed Phase 1 write in this plan.
- **S3. Skim the repo.** Record the stack, entry points, top-level shape, domain, existing
  instructions, project commands, style rules, branch and commit conventions, recent
  commits, and current working-tree state. Keep this to a skim; F1–F7 own the deep scan.
- **S4. Plan always-loaded instructions.** Record the exact proposed edits to
  `CLAUDE.md`, `AGENTS.md`, or the repo's equivalent. Cover what the repo is, the commands
  and conventions a later agent needs, the active skill selection, and the durable-docs
  root pointer when applicable. If no instruction file exists, name the file to create.

  Include this block in the plan and label it **Proposed future commit autonomy policy**:

  ```markdown
  ## Git checkpoints

  Commit coherent, completed slices autonomously after completing the checks required for
  that work. Do not ask for permission to make a local commit. A local commit does not
  authorize pushing, publishing, merging, releasing, deploying, or any other change to
  shared or external state; each requires separate user authorization.
  ```

  State that the user may revise or omit the block. Explain that approval authorizes later
  local commits after required checks and grants no outward authority.
- **S5. Plan skills and docs.** Run `ace skills --all`. For a candidate whose purpose is
  unclear, read its frontmatter `description` under the school path reported by
  `ace paths`. Choose the config layer by audience and record each inclusion or exclusion
  with one short reason tied to S3.

  | File             | Scope                 | Use for                 |
  |------------------|-----------------------|-------------------------|
  | `ace.toml`       | shared, committed     | the team-wide skill set |
  | `ace.local.toml` | personal, uncommitted | personal overrides      |

  Record the proposed selection as an exact `skills = [...]` edit or exact
  `ace skills include` and `ace skills exclude` commands; both produce the same layered
  result. Do not apply either form before S7. Use `ace skills` to inspect the active set
  and `ace config` to inspect the resolved config.

  Preserve the supporting skill directories each selected skill reads; a directory being
  available does not mean its skill is loaded. Keep both `ace` and `ace-save` whenever
  any ACE Home skill remains. Keep `ace-docs` when the plan includes a scaffold or spec
  run. Keep `ace-skill` when the repo will use `ace-school` to author or revise skills.
  Record each required inclusion in the plan.

  Decide whether the repo needs durable architecture, domain, or design docs. When it
  does, identify the durable-docs root named by the repo's always-loaded instructions. If
  none is named, inspect `docs/` and `.docs/`. Record an ambiguous pair of unnamed roots,
  an existing root with `README.md`, an incomplete root missing `README.md`, or an
  `ace-docs` scaffold plus a `docs/spec/` project overview as future work. Do not
  scaffold or repair docs during S1–S8. When the repo needs no durable docs and has no
  existing root, record `no docs`.
- **S6. Review and wait.** Finalize `.ace/init-plan.md` with the S3 findings and every
  proposed write. Present the complete batch. Call out the commit-autonomy block, its
  local-only authority, and the user's option to revise or omit it. Wait for explicit
  approval of the whole plan. This is a Wait.
- **S7. Apply the approved plan.** Open by quoting the approval. Make the instruction,
  config, and `.gitignore` edits in one batch. Install only the approved commit-autonomy
  wording; if the user omitted it, preserve the existing policy unless the approved plan
  says otherwise. Run `ace link`. If the current harness does not reload changed skills,
  report that a relaunch is required.
- **S8. Verify and close.** Compare every write with the approved plan. Confirm the
  resolved skill set with `ace skills` and `ace config`, then remove `.ace/init-plan.md`.
  Report changed files, link result, resolved skill set, review result, and any approved
  future docs work. Commit the completed onboarding when the approved policy or existing
  instructions authorize a local commit. Otherwise, report the reviewed files and wait
  for explicit commit approval; open by quoting that approval before committing. Stop;
  do not begin F1 without its separate approval.

## Run the optional spec

A spec run distills implemented behavior into durable explainers. It does not invent a
design or replace reconciliation against the code.

- **F1. Scope and wait.** List candidate units and order them by dependency, change
  frequency, risk, and current understanding. Use subsystems, domain models, key flows,
  and integration boundaries as units. Present the ordered scope and wait for explicit
  approval. This is a Wait.
- **F2. Prepare docs.** Open by quoting the approved scope. Resolve the durable-docs root
  from the current always-loaded instructions. If none is named, inspect `docs/` and
  `.docs/`. If both exist without one being named, report the ambiguity and stop. If a
  present root lacks `README.md` or `spec/README.md`, report the incomplete tree and stop.
  If no root exists, run `ace-docs` before writing the first unit and use its scaffolded
  root. Read the root gate. Route project behavior and its exact surface to that root's
  `spec/`; route retained third-party lookup to its `vendor/` only when the gate names
  that destination. Report a missing destination and stop; do not create it or route the
  artifact elsewhere.
- **F3. Study one unit.** Deep-read the implementation for the next approved unit. Gather
  behavior, contracts, data shapes, invariants, errors, edge cases, and non-obvious
  intent.
- **F4. Reconcile claims.** Check every proposed claim against the implementation. Report
  intended and implemented behavior separately when they diverge.
- **F5. Write the spec.** Run the unit through the normal `ace` planning phases, then
  write through the durable-docs gate selected in F2. Amend that root's `spec/` for
  everything settled. Never scaffold a decisions log as a default.
- **F6. Review the unit.** Verify every claim against the implementation and approved
  scope. Fix every mismatch. Keep the changed spec, source references, and clean review
  as evidence.
- **F7. Continue or close.** Repeat F3–F6 for the next approved unit. When the approved
  scope is exhausted, report each spec path and its review evidence, then stop. A smaller
  approved scope may end after one seed spec.

After onboarding, use `/ace` for recurring project work. Run `ace-init` again only when
its installed orientation no longer fits or the user explicitly requests the optional
spec run.
