---
name: ace-docs
description: >
  Scaffold durable docs or route the first artifact into them. TRIGGER on `/ace-docs`,
  "set up docs", "scaffold docs", "where should this ADR/spec/guide/reference go", or
  before creating the first lasting artifact in a repo with no docs convention. DO NOT
  TRIGGER for ordinary doc editing or migration of an established docs tree.
---

# ace-docs

Print `## ace-docs` as the first line.

Install a docs tree and the always-loaded instructions that make its rules reachable.

## Menu

| Operation                | Steps | Use when                                           |
|--------------------------|-------|----------------------------------------------------|
| Route an artifact        | R1–R2 | an existing durable-docs root defines the gate     |
| Scaffold durable docs    | S1–S7 | the repo has no durable-docs convention            |
| Open the decisions hatch | D1–D5 | a substantial losing argument needs its own record |

Run only the matching operation. An established tree with a different shape needs a
separately approved migration; assess it and stop.

## Procedure evidence

Read `ace/ledger.md` in the `ace` skill's directory. Keep the existing-tree check,
selected folders, installed instruction block, validation result, and commit as evidence.
Do not print per-step markers.

## Route an artifact

- **R1. Read the gate.** Find the durable-docs root named by the repo's always-loaded
  instructions and inspect that path. If none is named, inspect `docs/` and `.docs/`. If
  neither exists, report that no routing gate exists and stop. If both exist without one
  being named, report the ambiguous root and stop. Treat a present root without
  `README.md` as incomplete; report the missing gate and stop. With one complete root,
  read its `README.md`, then the README of the first folder whose predicate matches the
  artifact. If the gate names no matching folder or either README is missing, report the
  missing destination or routing text and stop. Do not infer a replacement taxonomy,
  create a folder, or route the artifact to another predicate.
- **R2. Report the route.** Name the destination and the exact predicate that selected
  it. A routing request is complete with this assessment. Do not create, move, or edit
  files unless the user separately asks for that write.

## Scaffold durable docs

- **S1. Inspect the repo.** Read its always-loaded instructions and identify any named
  durable-docs root. Inspect that path, plus `docs/` and `.docs/` when present. If a
  present root lacks `README.md`, report the incomplete tree and stop. If more than one
  root exists and the instructions select none, report the ambiguity and stop. If a
  complete root exists, use **Route an artifact** for routing requests; do not scaffold a
  second root. If an established convention differs from this one, present the conflict
  and wait for a migration request. If any scaffold target exists, report its current
  shape and stop before overwriting it.
- **S2. Select folders.** Always select `spec/`. Select `vendor/` for retained third-party
  lookup, `guides/` for task walkthroughs, and `scratch/` for genuinely unsettled
  exploration. Never create empty content merely to justify a folder.
- **S3. Select the instruction file.** Use the repo's existing always-loaded
  `CLAUDE.md`, `AGENTS.md`, or equivalent. If none exists, propose the file to create and
  wait for the user's choice. This is a Wait.
- **S4. Create the approved tree.** Open by quoting the user's choice when S3 waited.
  Create `docs/` and only the selected folders. Never create `docs/decisions/` during
  scaffolding.
- **S5. Install the templates.** Copy this skill's templates using the map below. In the
  root template, remove gate rows and lifecycle references for folders not selected,
  renumber the remaining rows, and preserve the predicates' order. Keep each folder
  template's missing-sibling branches intact. They stop artifacts whose proper
  destination was not selected from being misfiled.

  | Source                        | Destination                | Condition           |
  |-------------------------------|----------------------------|---------------------|
  | `templates/root-README.md`    | `docs/README.md`           | always              |
  | `templates/vendor-README.md`  | `docs/vendor/README.md`    | `vendor/` selected  |
  | `templates/guides-README.md`  | `docs/guides/README.md`    | `guides/` selected  |
  | `templates/spec-README.md`    | `docs/spec/README.md`      | always              |
  | `templates/scratch-README.md` | `docs/scratch/README.md`   | `scratch/` selected |

  Leave the placeholder row in `docs/spec/README.md`; it defines the index shape for the
  next writer.
- **S6. Install the reachable rules.** Insert the block below near the instruction
  file's repository-layout or conventions section. Trim only the folder list to match
  S2. Keep all four bold rules intact.

  ```markdown
  ## Durable artifacts

  `docs/` holds this project's durable record.

  **`docs/spec/` is authoritative — read the relevant spec before working, and comply.**
  It owes no justification: a rule that departs from mainstream practice, from what you
  would have picked, or from what you expected is not grounds to escalate, annotate, or
  re-open it. If a spec is wrong, raise it with the user and amend the spec.

  **Everything settled is a `docs/spec/` amendment** — an instruction you were given, an
  approach that was agreed, a library that was picked, a convention or preference that
  was fixed. Write it there as it was given: the rule, at the length it was given, with
  no reason supplied and no note of what it was chosen over. A one-sentence rule — "use
  RESTful routes" — is a complete entry. There is no decisions log.

  File new material by the gate, first match wins: third-party lookup → `vendor/`; a
  how-to → `guides/`; our own design or surface → `spec/`; unsettled exploration →
  `scratch/` (last resort, opened with a "not spec because ___" line). Nothing defaults
  to `scratch/`.

  **Before writing under `docs/`, read `docs/README.md`, then the destination folder's
  `README.md`.** The root file defines the routing gate. The folder file defines its
  filing test, filename format, and lifecycle rules. Both are binding.

  **`docs/spec/README.md` indexes every spec file — keep it current.** Read the index
  before adding a spec file, so you amend the existing doc on a subject instead of
  writing a second one. Adding, renaming, or retiring a file updates its row in the same
  change.
  ```

- **S7. Validate and close.** Confirm that every selected folder has its README, no
  unselected folder or gate row remains, every omitted category stops instead of routing
  elsewhere, the spec index has its placeholder row, and the always-loaded instructions
  contain the exact four bold rules including the `docs/README.md` pointer. If repository
  instructions authorize autonomous local commits, commit the scaffold as one coherent
  slice.
  Otherwise, report the reviewed files and wait for explicit commit approval. Report the
  changed paths, selected folders, validation result, and pending gate. After approval,
  open by quoting it, commit the scaffold, and report the commit hash.

## Open the decisions hatch

- **D1. Test the exception.** Confirm that an argument actually happened, two positions
  were considered, one lost, and the losing case is too detailed to preserve as one
  sentence. Apply only R1's root-selection checks, then read the resolved root's
  `README.md` and `spec/README.md`; do not route the argument through the normal gate. If
  any exception condition fails, report that the artifact belongs in that root's `spec/`.
  Amend the spec only when the user requested that write, then report the result and stop.
  When every condition holds, continue to D2.
- **D2. Confirm the write.** Present the qualifying argument, the spec file to amend, and
  the proposed decision-record path. Wait for explicit approval to open the folder. This
  is a Wait.
- **D3. Install the folder.** Open by quoting the approval. If the resolved root's
  `decisions/` exists, read its README and stop on any conflict; never overwrite it.
  Otherwise create the folder and copy `templates/decisions-README.md` to its `README.md`.
  Do not add the folder to the routing gate.
- **D4. Make the exception reachable.** Insert this exact block in the repo's
  always-loaded instructions and after the gate in the resolved root's `README.md`.
  Replace `{docs-root}` with that root's path:

  ```markdown
  **Decision records are an exception, not a routing destination.** If
  `{docs-root}/decisions/` exists, read its `README.md` before writing there. Every
  decision record adds a substantial losing argument to an accompanying
  `{docs-root}/spec/` amendment; never route an artifact there from the normal gate.
  ```

  Then write `{docs-root}/decisions/YYYY-MM-DD-slug.md` in the template's format and
  amend the authoritative `{docs-root}/spec/` file in the same change.
- **D5. Validate and close.** Confirm that the current rule is in the resolved root's
  `spec/`, the losing argument is in the decision record, both reachable pointers are
  installed, and no gate names `decisions/`. If repository instructions authorize
  autonomous local commits, commit all surfaces together. Otherwise, report the reviewed
  files and wait for explicit commit approval. Report the paths, validation result, and
  pending gate. After approval, open by quoting it, commit all surfaces together, and
  report the commit hash.

## Migration boundary

Do not fold scattered or established docs into a scaffold. A migration must identify the
source paths, target paths, history-preserving moves, routing conflicts, and user-approved
scope before changing files. A request to review or assess that tree ends with a report.
