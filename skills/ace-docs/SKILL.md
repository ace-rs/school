---
name: ace-docs
description: >
  Scaffold a durable-docs directory: usage docs (guides/, reference/) sorted by
  type, plus a design record (spec/, decisions/, notes/) sorted by permanence.
  TRIGGER on `/ace-docs`, "set up docs", "scaffold docs", "where should
  ADRs/specs/guides/reference go", or before creating the first durable doc in a
  repo with no `docs/`. DO NOT TRIGGER for editing existing docs or authoring the
  prose inside individual docs — this scaffolds the structure, not the content.
---

# ace-docs

Print `## ace-docs` as the first line.

Scaffold a `docs/` directory with two clusters of sub-directories. The clusters
sort on *different axes on purpose* — that asymmetry is the design:

**Usage** — outward-facing: how to use what this repo produces. Sorted by
**type** (a how-to and a lookup table read differently and fail when mixed).
Both living; edit in place.

- `docs/guides/` — task-oriented how-to and getting-started. *How do I do X?*
- `docs/reference/` — lookup facts: API, CLI flags, config keys, schemas,
  glossaries, external links. *What exactly is X?* Scan, don't read.

**Design record** — inward-facing: how and why this repo is built. Sorted by
**permanence** (how long the claim stays current).

- `docs/spec/` — design and architecture; intent and how-it-works. *What we
  intend, and how the system fits together.* Living; updated in place.
- `docs/decisions/` — dated ADRs. *What we decided, and why not the
  alternative.* Frozen at the moment of decision; supersede, never edit.
- `docs/notes/` — research, surveys, drafts, exploration. *What we explored.*
  Disposable; dated.

Routing when unsure: prose you read to *understand the system* → `spec/`; facts
you scan to *look something up* → `reference/`; steps to *accomplish a task* →
`guides/`; a *ruling* worth defending against re-litigation → `decisions/`;
everything else → `notes/` (the default).

Most repos use a subset — a library may need only `decisions/` + `notes/`; a
tool with users adds `guides/` + `reference/`. An empty dir with a README is a
valid signpost; that is the nudge. Don't manufacture content to fill a folder.

The agent entry point is not a folder: the `CLAUDE.md` / `AGENTS.md` pointer
(step 4) is the *schema document* that tells an agent how `docs/` is laid out.
Keep it as the single index — no separate `llms.txt`.

When content is complex — multi-component flows, state machines, layered
relationships — and `/visualise` or similar is available, produce an HTML
visualisation *alongside* the markdown. The HTML supplements; it never replaces.

## When to run this skill

Run when:

- A repo has no durable-docs convention and you're about to create the first
  artifact — a guide, reference page, spec, decision, or research dump.
- The user explicitly asks to scaffold the docs directory.
- An existing project's docs are scattered (root-level `DECISIONS.md`, ad-hoc
  `notes/` outside any container, `RFCs/` parallel to `docs/`) and the user
  wants to consolidate.

Don't run when:

- A `docs/` directory already exists with a different shape — adopting this
  shape there is a migration question, not a scaffold question. Discuss first.
- The repo uses a different convention with a strong reason (e.g. a framework
  that owns `docs/` for generated output). Suggest the shape but defer.

## Steps

1. **Check what exists.** `ls docs/` if it exists. If any target sub-dir already
   lives there, stop and discuss before overwriting.

2. **Create the tree.**

   ```sh
   mkdir -p docs/guides docs/reference docs/spec docs/decisions docs/notes
   ```

3. **Drop the six READMEs** from this skill's `templates/` directory:

   - `templates/root-README.md` → `docs/README.md`
   - `templates/guides-README.md` → `docs/guides/README.md`
   - `templates/reference-README.md` → `docs/reference/README.md`
   - `templates/spec-README.md` → `docs/spec/README.md`
   - `templates/decisions-README.md` → `docs/decisions/README.md`
   - `templates/notes-README.md` → `docs/notes/README.md`

   Templates are short and project-agnostic. Copy verbatim; let the user
   customize after.

4. **Wire up the harness instructions file** — `CLAUDE.md`, `AGENTS.md`, or
   both. Add a short section pointing at `docs/`:

   ```markdown
   ## Durable artifacts

   `docs/` — usage docs (`guides/`, `reference/`; sorted by type) and a design
   record (`spec/`, `decisions/`, `notes/`; sorted by permanence). Default to
   `notes/`. See `docs/README.md` and per-dir READMEs for routing.
   ```

   This pointer is the schema document an agent reads to navigate `docs/`; keep
   it short — the file loads every session, and the detail lives in the READMEs.
   Place it near other "where things go" guidance (Repo layout / Conventions).
   If neither file exists, ask which to create.

5. **Commit.** One commit:

   ```
   Scaffold docs/ — usage + design-record clusters

   Two clusters: usage docs (guides/, reference/) sorted by type; the design
   record (spec/, decisions/, notes/) sorted by permanence. Each sub-dir has a
   README defining scope. CLAUDE.md (or AGENTS.md) points at it as the
   schema/index.
   ```

## Gotchas

- **Don't pre-fill any dir with example content.** An empty dir + README beats a
  sample to delete.
- **Date-prefix filenames only in `decisions/` and `notes/`** — the moment
  matters there. `guides/`, `reference/`, `spec/` use `<slug>.md`; they describe
  a thing, not a moment.
- **Keep `guides/` and `reference/` distinct.** A guide walks one task
  start-to-finish; reference enumerates facts to scan. When a guide needs the
  exhaustive list, link to `reference/` rather than inlining it.
- **Don't symlink scattered docs.** Move them so `git log --follow` keeps
  history. Migrating existing docs in is a separate task — propose it, don't
  fold it into the scaffold.
- **Auto-generated wikis (DeepWiki and similar) are a regenerable supplement**
  over these human-curated docs — not a sixth folder here, and not a
  replacement.
