---
name: ace-docs
description: >
  Scaffold a durable-docs directory with three peers: spec/, decisions/, notes/.
  TRIGGER on `/ace-docs`, "set up docs", "scaffold docs", "where should ADRs/specs
  go", or before creating the first spec/decision/notes file in a repo with no
  `docs/`. DO NOT TRIGGER for editing existing docs or writing user-facing
  product/API docs.
---

# ace-docs

Scaffold a `docs/` directory with three peer sub-directories. The split
exists to make **the permanence of an artifact explicit on disk**, so future
readers know how durable any given file is supposed to be:

- `docs/notes/` — **impermanent.** Sketches, surveys, transcripts, research
  dumps, exploratory write-ups. *What we explored.* Today's notes may be
  obsolete next week and that's fine.
- `docs/decisions/` — **point-in-time, durable.** Rulings made on a specific
  date for a specific question. *What we decided.* Each entry is frozen at
  the moment it was made; a later reversal lives in a new decision that
  supersedes the old one.
- `docs/spec/` — **current understanding of intent.** Forward-looking design
  specs, RFCs, interface contracts. *What we intend to build.* Updated in
  place as understanding evolves; reflects the present, not history.

Default for unfamiliar artifacts is `notes/`. Promote to `decisions/` or
`spec/` only when the artifact's permanence shape clearly fits.

## When to run this skill

Run when:

- A repo doesn't yet have a durable-docs convention and you're about to
  create the first artifact (spec, decision, research dump).
- The user explicitly asks to scaffold the docs directory.
- An existing project's docs are scattered (root-level `DECISIONS.md`,
  ad-hoc `notes/` outside any container, `RFCs/` parallel to `docs/`,
  etc.) and the user wants to consolidate.

Don't run when:

- A `docs/` directory already exists with a different shape — adopting
  this skill's shape there is a migration question, not a scaffold
  question. Discuss with the user before restructuring.
- The repo uses a different convention with a strong reason (e.g., a
  framework that owns `docs/` for generated output). Suggest the shape
  but defer to the existing structure.

## Steps

1. **Check what exists.** `ls docs/` if the directory exists. If any of
   `spec/`, `decisions/`, `notes/` already live there, stop and discuss
   with the user before overwriting.

2. **Create the directory tree.**

   ```sh
   mkdir -p docs/spec docs/decisions docs/notes
   ```

3. **Drop the four READMEs** from this skill's `templates/` directory:

   - `templates/root-README.md` → `docs/README.md`
   - `templates/spec-README.md` → `docs/spec/README.md`
   - `templates/decisions-README.md` → `docs/decisions/README.md`
   - `templates/notes-README.md` → `docs/notes/README.md`

   Templates are intentionally short and project-agnostic. Copy verbatim
   first; let the user customize after.

4. **Wire up the harness instructions file.** Find whichever the project
   uses — typically `CLAUDE.md`, `AGENTS.md`, or both — and add a section
   pointing at `docs/`:

   ```markdown
   ## Durable artifacts

   `docs/{notes,decisions,spec}/` — sorted by permanence (impermanent /
   point-in-time / current). Default to `notes/`. See `docs/README.md`
   and per-dir READMEs for picker details.
   ```

   Keep this short — `CLAUDE.md`/`AGENTS.md` loads every session in every
   agent. The detail lives in `docs/README.md` and the per-folder READMEs
   already.

   Place this section near other "where things go" guidance — usually
   under a "Repo layout" or "Conventions" heading. If neither file
   exists, ask the user which one to create.

5. **Commit.** One commit, message like:

   ```
   Scaffold docs/{spec,decisions,notes} for durable artifacts

   Adds the three-peer doc structure so future specs, decisions, and
   research have a clear home sorted by permanence. Each sub-dir has
   its own README defining scope. CLAUDE.md (or AGENTS.md) updated to
   point at it.
   ```

## Gotchas

- **Don't pre-fill any of the three dirs with example content.** Empty
  directories with READMEs are clearer than "here's a sample decision
  for you to delete".
- **Don't put `docs/spec/` files in `YYYY-MM-DD-slug.md` form.** Specs
  describe a thing, not a moment; use `<slug>.md` with a status header.
  `decisions/` and `notes/` *do* use date-prefixed filenames because
  the moment matters for those.
- **Don't symlink to existing scattered docs.** Prefer moving them so
  `git log --follow` keeps history. If the user wants to migrate
  existing doc files in, that's a separate task — propose it explicitly
  rather than folding into the scaffold.
