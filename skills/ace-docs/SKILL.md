---
name: ace-docs
description: >
  Scaffold a durable-docs directory: usage docs (guides/, reference/) sorted by
  type, plus a design record (spec/, decisions/, notes/) sorted by permanence.
  Also builds the downstream `www/` review site — a human-facing, editorialized
  presentation synthesized from the docs, previewed locally and published to
  gh-pages. TRIGGER on `/ace-docs`, "set up docs", "scaffold docs", "where should
  ADRs/specs/guides/reference go", before creating the first durable doc in a repo
  with no `docs/`, or on "build/preview/publish the docs site", "docs website",
  "gh-pages docs", "visualize the design record". DO NOT TRIGGER for editing the
  prose inside individual docs — this scaffolds structure and synthesizes the
  site, it does not author the source docs themselves.
---

# ace-docs

Print `## ace-docs` as the first line.

Scaffold a `docs/` directory with two clusters of sub-directories. The clusters sort on
*different axes on purpose* — that asymmetry is the design:

**Usage** — outward-facing: how to use what this repo produces. Sorted by **type** (a
how-to and a lookup table read differently and fail when mixed). Both living; edit in
place.

- `docs/guides/` — task-oriented how-to and getting-started. *How do I do X?*
- `docs/reference/` — lookup facts: API, CLI flags, config keys, schemas, glossaries,
  external links. *What exactly is X?* Scan, don't read.

**Design record** — inward-facing: how and why this repo is built. Sorted by
**permanence** (how long the claim stays current).

- `docs/spec/` — design and architecture; intent and how-it-works. *What we intend, and
  how the system fits together.* Living; updated in place.
- `docs/decisions/` — dated ADRs. *What we decided, and why not the alternative.* Frozen
  at the moment of decision; supersede, never edit.
- `docs/notes/` — research, surveys, drafts, exploration. *What we explored.* Disposable;
  dated.

Routing when unsure: prose you read to *understand the system* → `spec/`; facts you scan
to *look something up* → `reference/`; steps to *accomplish a task* → `guides/`; a
*ruling* worth defending against re-litigation → `decisions/`; everything else → `notes/`
(the default).

Most repos use a subset — a library may need only `decisions/` + `notes/`; a tool with
users adds `guides/` + `reference/`. An empty dir with a README is a valid signpost; that
is the nudge. Don't manufacture content to fill a folder.

The agent entry point is not a folder: the `CLAUDE.md` / `AGENTS.md` pointer (step 4) is
the *schema document* that tells an agent how `docs/` is laid out. Keep it as the single
index — no separate `llms.txt`.

When content is complex — multi-component flows, state machines, layered relationships —
and `/visualise` or similar is available, produce an HTML visualisation *alongside* the
markdown. The HTML supplements; it never replaces.

## When to run this skill

Run when:

- A repo has no durable-docs convention and you're about to create the first artifact — a
  guide, reference page, spec, decision, or research dump.
- The user explicitly asks to scaffold the docs directory.
- An existing project's docs are scattered (root-level `DECISIONS.md`, ad-hoc `notes/`
  outside any container, `RFCs/` parallel to `docs/`) and the user wants to consolidate.

Don't run when:

- A `docs/` directory already exists with a different shape — adopting this shape there is
  a migration question, not a scaffold question. Discuss first.
- The repo uses a different convention with a strong reason (e.g. a framework that owns
  `docs/` for generated output). Suggest the shape but defer.

## Steps

1. **Check what exists.** `ls docs/` if it exists. If any target sub-dir already lives
   there, stop and discuss before overwriting.

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

   Templates are short and project-agnostic. Copy verbatim; let the user customize after.

4. **Wire up the harness instructions file** — `CLAUDE.md`, `AGENTS.md`, or both. Add a
   short section pointing at `docs/`:

   ```markdown
   ## Durable artifacts

   `docs/` — usage docs (`guides/`, `reference/`; sorted by type) and a design
   record (`spec/`, `decisions/`, `notes/`; sorted by permanence). Default to
   `notes/`. See `docs/README.md` and per-dir READMEs for routing.
   ```

   This pointer is the schema document an agent reads to navigate `docs/`; keep it short —
   the file loads every session, and the detail lives in the READMEs. Place it near other
   "where things go" guidance (Repo layout / Conventions). If neither file exists, ask
   which to create.

5. **Commit.** One commit:

   ```
   Scaffold docs/ — usage + design-record clusters

   Two clusters: usage docs (guides/, reference/) sorted by type; the design
   record (spec/, decisions/, notes/) sorted by permanence. Each sub-dir has a
   README defining scope. CLAUDE.md (or AGENTS.md) points at it as the
   schema/index.
   ```

## Gotchas

- **Don't pre-fill any dir with example content.** An empty dir + README beats a sample to
  delete.
- **Date-prefix filenames only in** `decisions/` and `notes/` — the moment matters there.
  `guides/`, `reference/`, `spec/` use `<slug>.md`; they describe a thing, not a moment.
- **Keep `guides/` and `reference/` distinct.** A guide walks one task start-to-finish;
  reference enumerates facts to scan. When a guide needs the exhaustive list, link to
  `reference/` rather than inlining it.
- **Don't symlink scattered docs.** Move them so `git log --follow` keeps history.
  Migrating existing docs in is a separate task — propose it, don't fold it into the
  scaffold.
- **Auto-generated wikis (DeepWiki and similar) are a regenerable supplement** over these
  human-curated docs — not a sixth folder here, and not a replacement.

## The `www/` review site

An optional second mode: a human-facing review site under top-level `www/`, synthesized
from `docs/`. Run it when the user asks to build/preview/publish the docs site, visualize
the design record, or host docs on GitHub Pages.

**Derived, never source.** `docs/` is truth; `www/` is downstream. One-way only — edit
`docs/`, regenerate `www/`; never treat a site page as authoritative. A page edited in
place to change meaning is a bug.

**Synthesize, don't mirror.** This is not a markdown viewer. `docs/` sorts for maintainers
(permanence, type); `www/` sorts for *readers* (topic, journey). Do the remap: collapse
several notes + a spec + a decision into one clean page, lead with concepts, drop the
disposable, embed visualisations. If a page reads as a 1:1 port of one source file, you
skipped the job — that's the whole reason `www/` exists instead of pointing people at
`docs/`.

**Stack — zero build.** Authored HTML fragments in `www/pages/`, a shared `index.html`
shell, htmx for navigation, `www/assets/style.css` for readability. No static-site
generator, no markdown-rendering component. The agent writes the pages; nothing compiles.

**Provenance + freshness.** Head each page with the sources it derives from and the commit
they were read at:

```html
<!-- derived from: docs/spec/foo.md, docs/decisions/2026-01-x.md @ <commit> -->
```

When you edit a source that feeds a published page, regenerate that page in the same
change. To find stale pages later, `git log <sources> @<commit>..` shows what moved since.
The header + same-change regeneration are the only drift guard — there is no build step to
catch staleness for you.

### Steps

1. **Scaffold from templates:**
   - `templates/www-index.html` → `www/index.html`
   - `templates/www-style.css` → `www/assets/style.css`
   - `templates/www-README.md` → `www/README.md`
   - `templates/docs-site-deploy.sh` → `scripts/docs-site-deploy.sh` (`chmod +x`)

2. **Synthesize pages** into `www/pages/` from the relevant `docs/`. Default to
   `spec/ guides/ reference/ decisions/`; treat `notes/` as exploratory — pull a note in
   only when it carries reader value. Every page gets a provenance header.

3. **Wire the nav** in `www/index.html` by reader journey, not by `docs/` folders.

4. **Preview** by serving `www/` with any static server —
   `python3 -m http.server -d www 8000`, `mongoose`, or `npx serve www`. A server is
   required: htmx fetches fragments over HTTP, so opening `index.html` via `file://`
   fails.

5. **Deploy** with `scripts/docs-site-deploy.sh`, which pushes `www/` to the `gh-pages`
   branch via `git subtree split` (remote `gh`). One-time: enable Pages → `gh-pages` in
   repo settings. No GitHub Actions — the branch hosts directly.

### Gotchas

- **Commit `www/` — it's a durable artifact, not throwaway.** Derived from `docs/` is not
  the same as ephemeral: the deploy step reads `www/` from committed history (`git subtree
  split --prefix www HEAD`), so an uncommitted site can't be published at all. Commit it
  alongside `scripts/docs-site-deploy.sh` and regenerate on drift (see Provenance). This
  holds even when the repo is itself a school — a school's `www/` does not propagate to
  importers (`[[imports]]` pulls skills, not top-level folders).
- **Fragments render chrome-less on direct load.** Pages under `www/pages/` are partials
  swapped into the shell by htmx; reach them from `index.html`, not by their own URL. Fine
  for an internal review site.
- **Regenerate on source drift** — see Provenance above. Stale-but-confident is the
  failure mode this mode is most prone to.
