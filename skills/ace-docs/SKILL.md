---
name: ace-docs
description: >
  Scaffold a durable-docs directory with three peers: spec/, decisions/, notes/.
  TRIGGER when the user says "set up docs", "where should I put this design
  doc/decision/research", "we need a place for ADRs", "scaffold the docs
  directory", or invokes `/ace-docs`. Also use when an agent is about to
  create the first design spec, decision record, or research write-up in a
  repo that has no `docs/` yet — set the structure up first instead of
  improvising a one-off location. DO NOT TRIGGER for editing existing
  individual doc files, generating user-facing product docs, or writing API
  reference / man pages.
---

# ace-docs

Scaffold a `docs/` directory with three peer sub-directories so future
artifacts have a clear, mutually-exclusive home:

- `docs/spec/` — forward-looking design specifications. *What we intend
  to build.*
- `docs/decisions/` — rulings that resolve ambiguity or set a precedent
  future PRs should follow. *What we decided.*
- `docs/notes/` — research, surveys, drafts, transcripts, exploratory
  write-ups. *What we explored.*

The point of three peers (versus one catch-all) is to stop "everything
becomes a decision record" gravity. Most artifacts agents and humans
produce are notes, not decisions. With `notes/` available as the
default, agents stop force-fitting research into `decisions/`.

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

   All under `docs/` — three peers, mutually exclusive. Pick by artifact
   shape:

   - `docs/spec/` — forward-looking design specs, RFCs, interface
     contracts. *What we intend to build.*
   - `docs/decisions/` — rulings that resolve ambiguity or set a
     precedent future PRs should follow. *What we decided.*
   - `docs/notes/` — research, surveys, drafts, transcripts, exploratory
     write-ups. *What we explored.*

   Default for "this might be useful later" is `docs/notes/`. Move to
   `docs/decisions/` only if you can name what was decided in one line;
   to `docs/spec/` only if it describes intended-to-build behavior.
   ```

   Place this section near other "where things go" guidance — usually
   under a "Repo layout" or "Conventions" heading. If neither file
   exists, ask the user which one to create.

5. **Commit.** One commit, message like:

   ```
   Scaffold docs/{spec,decisions,notes} for durable artifacts

   Adds the three-peer doc structure so future specs, decisions, and
   research have a clear home. Each sub-dir has its own README defining
   scope. CLAUDE.md (or AGENTS.md) updated to point at it.
   ```

## Gotchas

- **Don't pre-fill any of the three dirs with example content.** Empty
  directories with READMEs are clearer than "here's a sample decision
  for you to delete".
- **Don't put `docs/spec/` files in `YYYY-MM-DD-slug.md` form.** Specs
  describe a thing, not a moment; use `<slug>.md` with a status header.
  `decisions/` and `notes/` *do* use date-prefixed filenames.
- **Don't symlink to existing scattered docs.** Prefer moving them so
  `git log --follow` keeps history. If the user wants to migrate
  existing doc files in, that's a separate task — propose it explicitly
  rather than folding into the scaffold.
