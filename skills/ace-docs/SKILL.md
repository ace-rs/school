---
name: ace-docs
description: >
  Scaffold a durable-docs directory routed by a single gate — guides/ (how-to),
  vendor/ (third-party reference), spec/ (design, surface, and everything settled),
  scratch/ (residual exploration). TRIGGER on `/ace-docs`, "set up docs", "scaffold
  docs", "where should ADRs/specs/guides/reference go", or before creating the first
  durable doc in a repo with no `docs/`. DO NOT TRIGGER for editing the prose inside
  individual docs — this scaffolds structure, it does not author the docs themselves.
---

# ace-docs

Print `## ace-docs` as the first line.

Scaffold a `docs/` directory of four folders, each named as a **predicate** — the name is
the test, so filing is a match, not a judgment call:

- `docs/guides/` — task-oriented how-to, start to finish. *How do I do X?* — using the
  product or operating the repo. Living; edit in place.
- `docs/vendor/` — third-party lookup you keep reaching for: a framework's commands, an
  external API/CLI. *What exactly does their thing do?* Link-first; mark provenance. Living.
- `docs/spec/` — design, architecture, how-it-works, and our own exact surface (our flags,
  config, API). *How our system is built and meant to work.* Living; edit in place.
- `docs/scratch/` — unsettled exploration: research, surveys, drafts. *What we're still
  working out.* The residual home; disposable; dated.

**Route by the gate, not by vibe.** One axis — the question the artifact answers. Walk it
top to bottom and file at the first yes; the bottom charges a toll, so nothing lands in
`scratch/` by default:

1. Third-party facts you keep to look up? → `vendor/` (link-first, mark provenance)
2. A how-to — using the product *or* operating the repo? → `guides/` (script repeatable
   operations; the guide holds the judgment a script can't)
3. How our system is built or meant to work, including its own config/CLI surface? →
   `spec/`
4. None of the above — genuinely unsettled exploration → `scratch/`, opened with a
   one-line "not spec because ___."

**Everything settled is a `spec/` amendment.** An instruction you were given, an approach
that was agreed, a library that was picked, a convention or preference that was fixed — all
of it is an edit to `spec/`. Make the edit, state the current rule, move on. There is no
fifth folder and no separate ruling artifact to reach for.

**The spec is authoritative — read it before you work, and comply.** It owes your priors no
justification. That a rule departs from mainstream practice, from what you'd have picked,
or from what you expected is not grounds to escalate, annotate, or re-open it. If the spec
is wrong, raise it with the user and amend the spec.

Permanence is not a sorting axis — it falls out of the answer: `guides`/`vendor`/`spec` are
living, `scratch` disposable. Read it off the folder.

**Spec outruns code.** Something agreed but not yet implemented belongs in `spec/` now.
Flag the affected section intended/target and land it in the same stroke; never leave the
spec teaching a design that has been abandoned. Never strand a settled rule in a
resume/handoff note.

Most repos use a subset — a library may need only `spec/` + `scratch/`; a tool with users
adds `guides/` + `vendor/`. An empty dir with a README is a valid signpost. Don't
manufacture content to fill a folder.

The agent entry point is not a folder: the `CLAUDE.md` / `AGENTS.md` pointer (step 4) is
the schema document that tells an agent how `docs/` is laid out. Keep it as the single
index — no separate `llms.txt`.

When content is complex — multi-component flows, state machines, layered relationships —
and `/visualise` or similar is available, produce an HTML visualisation alongside the
markdown, stored beside its source in `docs/`. The HTML supplements; it never replaces.

## The escape hatch: `docs/decisions/`

**This folder does not exist.** It is not scaffolded, not in the gate, and not something to
route to. Assume any repo has no decisions log and needs none.

Cut it open only when a spec amendment alone would lose something the spec cannot carry:
an argument happened, two positions were on the table, one lost, and the losing case is
detailed enough that without a written record it will be re-argued from scratch. The
evidence is in the conversation or the review thread. Absent that evidence, there was no
argument.

Not escape-hatch material: a preference the user stated. A convention that was fixed. A
library that was picked. A rule that departs from expectation. Anything summarizable in a
sentence — that sentence is the spec edit. Lock it into `spec/` and be done.

When the hatch is warranted: `mkdir docs/decisions`, drop `templates/decisions-README.md`,
write `YYYY-MM-DD-slug.md`, and amend `spec/` in the same change — a reader learns current
state from `spec/`, never from `decisions/`. Entries are frozen; supersede, never edit.

## Scaffold the `docs/` tree

### When to run

Run when:

- A repo has no durable-docs convention and the first artifact is about to be created — a
  guide, reference page, spec, or research dump.
- The user explicitly asks to scaffold the docs directory.
- An existing project's docs are scattered (root-level `DECISIONS.md`, ad-hoc `notes/`
  outside any container, `RFCs/` parallel to `docs/`) and the user wants to consolidate.

Don't run when:

- A `docs/` directory already exists with a different shape — that is a migration question,
  not a scaffold question. Discuss first.
- The repo uses a different convention with a strong reason (e.g. a framework that owns
  `docs/` for generated output). Suggest the shape but defer.

### Steps

1. **Check what exists.** `ls docs/` if it exists. If any target sub-dir already lives
   there, stop and discuss before overwriting.

2. **Create the tree.**

   ```sh
   mkdir -p docs/guides docs/vendor docs/spec docs/scratch
   ```

   No `docs/decisions/` — see the escape hatch above.

3. **Drop the five READMEs** from this skill's `templates/` directory:

   - `templates/root-README.md` → `docs/README.md`
   - `templates/guides-README.md` → `docs/guides/README.md`
   - `templates/vendor-README.md` → `docs/vendor/README.md`
   - `templates/spec-README.md` → `docs/spec/README.md`
   - `templates/scratch-README.md` → `docs/scratch/README.md`

   `templates/decisions-README.md` ships only if the escape hatch is cut open. Copy
   templates verbatim; let the user customize after.

4. **Wire up the harness instructions file** — `CLAUDE.md`, `AGENTS.md`, or both. Add a
   short section pointing at `docs/`:

   ```markdown
   ## Durable artifacts

   `docs/` — file by the routing gate in `docs/README.md`: third-party lookup →
   `vendor/`; a how-to → `guides/`; our own design/surface → `spec/`; unsettled
   exploration → `scratch/` (last resort, opened with a "not spec because ___" line).
   Nothing defaults to `scratch/`. Everything settled — instructions, conventions,
   preferences, rulings — is a `spec/` amendment; the spec is authoritative, so read it
   before working and comply. There is no decisions log.
   ```

   Keep the pointer short — it loads every session and the detail lives in the READMEs.
   Place it near other "where things go" guidance (Repo layout / Conventions). If neither
   file exists, ask which to create.

5. **Commit.** One commit:

   ```
   Scaffold docs/ — single-gate routing

   Four folders routed by one gate: vendor/ (third-party reference), guides/
   (how-to), spec/ (our design + surface), scratch/ (residual exploration).
   Everything settled amends spec/; there is no decisions log. Each sub-dir has a
   README defining its test. CLAUDE.md (or AGENTS.md) points at it as the
   schema/index.
   ```

### Gotchas

- **Don't pre-fill any dir with example content.** An empty dir + README beats a sample to
  delete.
- **Date-prefix filenames only in** `scratch/` (and `decisions/` if the hatch is open).
  `guides/`, `vendor/`, `spec/` use `<slug>.md`; they describe a thing, not a moment.
- **Script repeatable operations, don't narrate them.** Encode the steps in `scripts/*.sh`
  and let the guide hold the invocation plus the judgment a script can't.
- **`vendor/` is link-first.** Cache the slice you reuse plus a provenance marker, never
  mirror a whole external API — the copy rots when upstream ships.
- **`scratch/` is residual, not default.** Reachable only by failing every gate above it;
  each file opens with a one-line "not spec because ___." A file that lands there without
  that line is misfiled.
- **Don't symlink scattered docs.** Move them so `git log --follow` keeps history.
  Migrating existing docs in is a separate task — propose it, don't fold it into the
  scaffold.
- **Auto-generated wikis (DeepWiki and similar) are a regenerable supplement** over these
  human-curated docs — not a fifth folder here, and not a replacement.

### Tending scratch/ — retention and collapse

`scratch/` is disposable, with two carve-outs once notes accumulate:

- **Provenance pins a file.** A scratch note cited as provenance by another doc is retained
  even though scratch/ is disposable — the toll and disposability govern new filing, not
  deletion of already-cited material. Prune the rest freely; never orphan a citation.
- **Collapse prior art.** When scratch design notes pile up on one theme, consolidate them
  into a single `scratch/prior-art.md` digest: one section per source note, each
  cross-linked to the live `spec/` doc it fed. Repoint any citations to the digest, drop the
  absorbed notes. `prior-art.md` is the one undated file in `scratch/`.
