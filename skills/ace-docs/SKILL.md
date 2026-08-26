---
name: ace-docs
description: >
  Scaffold a durable-docs directory — guides/ (how-to), vendor/ (third-party
  reference), spec/ (design, surface, and everything settled), scratch/ (residual
  exploration) — with a README per folder and a routing pointer in CLAUDE.md /
  AGENTS.md. TRIGGER on `/ace-docs`, "set up docs", "scaffold docs", "where should
  ADRs/specs/guides/reference go", or before creating the first durable doc in a repo
  with no `docs/`. DO NOT TRIGGER for editing the prose inside individual docs — this
  scaffolds structure, it does not author the docs themselves.
---

# ace-docs

Print `## ace-docs` as the first line.

This skill installs a docs tree and the text that governs it. Place that text verbatim —
the rules bind later sessions only through the files written here, and only the
instructions-file block (step 4) loads without being asked for. Everything else is reached
because that block tells an agent to open it.

If `docs/` already exists and a routing question is being asked, answer from
`docs/README.md`; don't re-scaffold.

## When to run

Run when:

- A repo has no durable-docs convention and the first artifact is about to be created — a
  guide, reference page, spec, or research dump.
- The user explicitly asks to scaffold the docs directory.
- An existing project's docs are scattered (root-level `DECISIONS.md`, ad-hoc `notes/`
  outside any container, `RFCs/` parallel to `docs/`) and the user wants to consolidate.

Don't run when:

- A `docs/` directory already exists with a different shape — that is a migration
  question, not a scaffold question. Discuss first.
- The repo uses a different convention with a strong reason (e.g. a framework that owns
  `docs/` for generated output). Suggest the shape but defer.

## Stamp chain

The numbered steps below run as a stamp chain. Read `ace/ledger.md` — in the `ace`
skill's directory, sibling to this one — and follow its contract: close every step with
its one-line stamp, open the next by reprinting it, no skips, exemptions only in the
user's verbatim words.

## Steps

1. **Check existing docs.** `ls docs/` if it exists. If any target sub-dir already lives
   there, stop and discuss before overwriting.

2. **Select folders.** `spec/` is required because every settled rule lands there. Add
   `guides/`, `vendor/`, and `scratch/` only when the repo will use them. An empty folder
   with its README is a valid signpost; never manufacture content to fill one.

3. **Create tree.** Create the selected folders, never `docs/decisions/`:

   ```sh
   mkdir -p docs/guides docs/vendor docs/spec docs/scratch
   ```

   Remove unselected paths from the command before running it.

4. **Install READMEs.** Use this map. The root row is required; copy only the per-folder
   rows selected in step 2:

   - `templates/root-README.md` → `docs/README.md`
   - `templates/guides-README.md` → `docs/guides/README.md`
   - `templates/vendor-README.md` → `docs/vendor/README.md`
   - `templates/spec-README.md` → `docs/spec/README.md`
   - `templates/scratch-README.md` → `docs/scratch/README.md`

   Each README carries its folder's routing test, format, and lifecycle. The copied
   `docs/README.md` carries the gate: remove rows and lifecycle links for unselected
   folders while preserving the selected predicates' relative order. Copy per-folder
   templates as-is; let the user customize after.

   `docs/spec/README.md` ships with an index table and one placeholder row. Leave the
   placeholder row in place — it shows the shape the next writer must follow.

   `templates/decisions-README.md` ships only if the escape hatch is cut open.

5. **Wire instructions.** Update `CLAUDE.md`, `AGENTS.md`, or both. This is
   the only surface that loads on its own, so it carries every rule that must hold at all
   times plus the instruction that makes the per-folder READMEs reachable. Insert it near
   other "where things go" guidance (Repo layout / Conventions). If neither file exists,
   ask which to create.

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

   **Before writing into a `docs/` folder, read that folder's `README.md` first.** It
   holds the folder's filing test, filename format, and lifecycle rules, and they are
   binding. Nothing else surfaces them.

   **`docs/spec/README.md` indexes every spec file — keep it current.** Read the index
   before adding a spec file, so you amend the existing doc on a subject instead of
   writing a second one. Adding, renaming, or retiring a file updates its row in the same
   change.
   ```

   Trim the folder list to the folders actually created. Keep all four bolded rules
   intact. The last two are load-bearing: a per-folder README is read only when
   something instructs an agent to open it, and an index only stays useful if the rule
   to maintain it loads on every session. This block is the only surface that loads on
   its own — drop either line and the rule stops binding.

6. **Commit.** Make one commit. Use this subject and describe the selected folders in the
   body:

   ```
   Scaffold docs/ — single-gate routing

   Durable folders routed by one gate. Everything settled amends spec/; there is no
   decisions log. Each selected sub-dir has a README defining its test, and
   spec/README.md indexes every spec file when spec/ is selected. CLAUDE.md (or
   AGENTS.md) points at the gate.
   ```

## The escape hatch: `docs/decisions/`

Do not scaffold this folder. It is not in the gate and not a routing destination; assume a
repo has no decisions log and needs none.

Cut it open only when a spec amendment alone would lose something the spec cannot carry:
an argument happened, two positions were on the table, one lost, and the losing case is
detailed enough that without a written record it will be re-argued from scratch. Absent
that, it is a spec edit.

When warranted: `mkdir docs/decisions`, drop `templates/decisions-README.md` →
`docs/decisions/README.md`, write `YYYY-MM-DD-slug.md`, and amend `docs/spec/` in the same
change.

## Gotchas

- **Don't symlink scattered docs.** Move them so `git log --follow` keeps history.
  Migrating existing docs in is a separate task — propose it, don't fold it into the
  scaffold.
- **Auto-generated wikis (DeepWiki and similar) are a regenerable supplement** over these
  human-curated docs — not a fifth folder, and not a replacement.
- **HTML visualisations supplement, never replace.** When content is complex —
  multi-component flows, state machines, layered relationships — and `/visualise` or
  similar is available, store the visualisation beside its markdown source in `docs/`.
