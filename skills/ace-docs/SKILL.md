---
name: ace-docs
description: >
  Scaffold a durable-docs directory routed by a single gate — guides/ (how-to),
  vendor/ (third-party reference), spec/ (our design + surface), decisions/ (dated
  rulings), scratch/ (residual exploration). Also builds the downstream `www/` review site — a human-facing, editorialized
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

This skill has two modes over one source of truth, `docs/`: **scaffold** the tree
(default), and **build the `www/` review site** from it (its own section below). Both use
the `docs/` structure below.

Scaffold a `docs/` directory of five folders, each named as a **predicate** — the name is
the test, so filing is a match, not a judgment call:

- `docs/guides/` — task-oriented how-to, start to finish. *How do I do X?* — using the
  product or operating the repo. Living; edit in place.
- `docs/vendor/` — third-party lookup you keep reaching for: a framework's commands, an
  external API/CLI. *What exactly does their thing do?* Link-first; mark provenance. Living.
- `docs/spec/` — design, architecture, how-it-works, and our own exact surface (our flags,
  config, API). *How our system is built and meant to work.* Living; edit in place.
- `docs/decisions/` — dated rulings. *What we decided, and why not the alternative.* Frozen
  at the moment of decision; supersede, never edit.
- `docs/scratch/` — unsettled exploration: research, surveys, drafts. *What we're still
  working out.* The residual home; disposable; dated.

**Route by the gate, not by vibe.** One axis — the question the artifact answers. Walk it
top to bottom and file at the first yes; the bottom charges a toll, so nothing lands in
`scratch/` by default:

1. A ruling you'd defend if reopened? → `decisions/`
2. Third-party facts you keep to look up? → `vendor/` (link-first, mark provenance)
3. A how-to — using the product *or* operating the repo? → `guides/` (script repeatable
   operations; the guide holds the judgment a script can't)
4. How our system is built or meant to work, including its own config/CLI surface? →
   `spec/`
5. None of the above — genuinely unsettled exploration → `scratch/`, opened with a
   one-line "not spec/decision because ___."

Permanence is not a sorting axis — it falls out of the answer: `guides`/`vendor`/`spec` are
living, `decisions` frozen, `scratch` disposable. Don't reason about it; read it off the
folder.

**Decided-but-not-yet-applied.** A decision often outruns the code — agreed but not yet
implemented. Route it or it gets re-litigated each time someone reconstructs the design
from spec + code. `spec/` is the living *what*, `decisions/` the frozen *why*: a reader
learns current state from `spec/`, never from `decisions/`. So a ruling that changes or
retires existing behavior updates `spec/` in the same stroke — even before the code lands —
with the affected section flagged intended/target and pointing to the ADR; never leave the
spec teaching the superseded design. Never strand a ruling in a resume/handoff note: those
don't survive the next handoff. Promote it to `decisions/` and reflect it in `spec/`
immediately.

Most repos use a subset — a library may need only `decisions/` + `scratch/`; a tool with
users adds `guides/` + `vendor/`. An empty dir with a README is a valid signpost. Don't
manufacture content to fill a folder.

The agent entry point is not a folder: the `CLAUDE.md` / `AGENTS.md` pointer (step 4) is
the *schema document* that tells an agent how `docs/` is laid out. Keep it as the single
index — no separate `llms.txt`.

When content is complex — multi-component flows, state machines, layered relationships —
and `/visualise` or similar is available, produce an HTML visualisation *alongside* the
markdown. The HTML supplements; it never replaces. Such visualisations live with their
source in `docs/`; the `www/` site (below) is where they reach readers.

## Scaffold the `docs/` tree

### When to run

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

### Steps

1. **Check what exists.** `ls docs/` if it exists. If any target sub-dir already lives
   there, stop and discuss before overwriting.

2. **Create the tree.**

   ```sh
   mkdir -p docs/guides docs/vendor docs/spec docs/decisions docs/scratch
   ```

3. **Drop the six READMEs** from this skill's `templates/` directory:

   - `templates/root-README.md` → `docs/README.md`
   - `templates/guides-README.md` → `docs/guides/README.md`
   - `templates/vendor-README.md` → `docs/vendor/README.md`
   - `templates/spec-README.md` → `docs/spec/README.md`
   - `templates/decisions-README.md` → `docs/decisions/README.md`
   - `templates/scratch-README.md` → `docs/scratch/README.md`

   Templates are short and project-agnostic. Copy verbatim; let the user customize after.

4. **Wire up the harness instructions file** — `CLAUDE.md`, `AGENTS.md`, or both. Add a
   short section pointing at `docs/`:

   ```markdown
   ## Durable artifacts

   `docs/` — file by the routing gate in `docs/README.md`: a ruling → `decisions/`;
   third-party lookup → `vendor/`; a how-to → `guides/`; our own design/surface →
   `spec/`; unsettled exploration → `scratch/` (last resort, opened with a
   "not spec/decision because ___" line). Nothing defaults to `scratch/`.
   ```

   This pointer is the schema document an agent reads to navigate `docs/`; keep it short —
   the file loads every session, and the detail lives in the READMEs. Place it near other
   "where things go" guidance (Repo layout / Conventions). If neither file exists, ask
   which to create.

5. **Commit.** One commit:

   ```
   Scaffold docs/ — single-gate routing

   Five folders routed by one gate: guides/ (how-to), vendor/ (third-party
   reference), spec/ (our design + surface), decisions/ (dated rulings), scratch/
   (residual exploration). Each sub-dir has a README defining its test. CLAUDE.md
   (or AGENTS.md) points at it as the schema/index.
   ```

### Gotchas

- **Don't pre-fill any dir with example content.** An empty dir + README beats a sample to
  delete.
- **Date-prefix filenames only in** `decisions/` and `scratch/` — the moment matters there.
  `guides/`, `vendor/`, `spec/` use `<slug>.md`; they describe a thing, not a moment.
- **Script repeatable operations, don't narrate them.** An operational guide an agent
  re-runs by hand is a latent mistake — encode the steps in `scripts/*.sh` and let the
  guide hold the invocation plus the judgment a script can't.
- **`vendor/` is link-first.** Cache the slice you reuse plus a provenance marker, never
  mirror a whole external API — the copy rots when upstream ships.
- **`scratch/` is residual, not default.** Reachable only by failing every gate above it;
  each file opens with a one-line "not spec/decision because ___." A file that lands there
  without that line is misfiled.
- **Don't symlink scattered docs.** Move them so `git log --follow` keeps history.
  Migrating existing docs in is a separate task — propose it, don't fold it into the
  scaffold.
- **Auto-generated wikis (DeepWiki and similar) are a regenerable supplement** over these
  human-curated docs — not a sixth folder here, and not a replacement.

### Tending scratch/ — retention and collapse

`scratch/` is disposable, with two carve-outs once notes accumulate:

- **Provenance pins a file.** A scratch note a frozen `decisions/` ruling cites as
  provenance is retained even though scratch/ is disposable — the toll and disposability
  govern *new filing*, not deletion of already-cited material. Prune the rest freely; never
  orphan a decision's citation.
- **Collapse prior art.** When scratch design notes pile up on one theme, consolidate them
  into a single `scratch/prior-art.md` digest: one section per source note, each
  cross-linked to the live `spec/` or `decisions/` doc it fed. Repoint any citations to the
  digest, drop the absorbed notes. One digest with live cross-links beats N stale drafts,
  and it becomes the retained provenance the rule above protects. `prior-art.md` is the one
  undated file in `scratch/`.

## Build the `www/` review site

A human-facing review site under top-level `www/`, synthesized from `docs/`. Run it when
the user asks to build/preview/publish the docs site, visualize the design record, or host
docs on GitHub Pages.

**Derived, never source.** `docs/` is truth; `www/` is downstream. One-way only — edit
`docs/`, regenerate `www/`; never treat a site page as authoritative. A page edited in
place to change meaning is a bug.

**Synthesize, don't mirror.** This is not a markdown viewer. `docs/` sorts for maintainers
(permanence, type); `www/` sorts for *readers* (topic, journey). Do the remap: collapse
several notes + a spec + a decision into one clean page, lead with concepts, drop the
disposable, embed visualisations. If a page reads as a 1:1 port of one source file, you
skipped the job.

**Stack — zero build.** Authored HTML fragments in `www/pages/`, a shared `index.html`
shell, htmx for navigation, `www/assets/style.css` for the look. No static-site generator,
no markdown-rendering component — author every page by hand; nothing compiles.

**Components.** The stylesheet ships a flat `/visualise` -style design (light/dark, Space
Grotesk/Mono, an electric-cyan accent) and a small component vocabulary — notes, panels,
compare columns, stats, steps, tags, trees, schematic figures. Read
[`references/components.md`](references/components.md) before authoring pages; use those
classes rather than inventing per-page styles.

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

1. **Scaffold from templates** — first run only. If `www/` already exists, skip this and
   regenerate pages in place; re-copying clobbers hand-wired nav and styling.
   - `templates/www-index.html` → `www/index.html`
   - `templates/www-style.css` → `www/assets/style.css`
   - `templates/www-README.md` → `www/README.md`
   - `templates/docs-site-deploy.sh` → `scripts/docs-site-deploy.sh` (`chmod +x`)

2. **Synthesize pages** into `www/pages/` from the relevant `docs/`. Default to
   `spec/ guides/ vendor/ decisions/`; treat `scratch/` as exploratory — pull one in
   only when it carries reader value. Every page gets a provenance header.

3. **Wire the nav** in `www/index.html` by reader journey, not by `docs/` folders.

4. **Preview** by serving `www/` with any static server —
   `python3 -m http.server -d www 8000`, `mongoose`, or `npx serve www`. A server is
   required: htmx fetches fragments over HTTP, so opening `index.html` via `file://`
   fails.

5. **Commit** `www/` (and `scripts/docs-site-deploy.sh` on first run). Deploy reads the
   site from committed history, so an uncommitted `www/` can't be published.

6. **Deploy** with `scripts/docs-site-deploy.sh`, which pushes `www/` to the `gh-pages`
   branch via `git subtree split` (remote `gh`). One-time: enable Pages → `gh-pages` in
   repo settings. No GitHub Actions — the branch hosts directly.

### Gotchas

- **`www/` is a durable artifact — commit it, don't treat it as throwaway.** Derived from
  `docs/` is not the same as ephemeral; commit the site (step 5) and regenerate it on
  drift (see Provenance). This holds even when the repo is itself a school — a school's
  `www/` does not propagate to importers (`[[imports]]` pulls skills, not top-level
  folders).
- **Keep fragment links relative and don't push URLs.** htmx swaps `www/pages/*.html`
  partials into the shell. Use `hx-get="pages/x.html"` with no `hx-push-url`: relative
  links resolve against the unchanging site root, so the site works under any base path (a
  gh-pages project lives at `/<repo>/`). Pushing the fragment path rebases the next
  relative link and every later nav 404s. The tradeoff is a single-URL site — no deep
  links or back-button history, which is fine for a review surface.
- **Regenerate on source drift.** See Provenance. The trap is a page that's stale but
  still reads confidently — regenerate it in the same edit that changes the source.
