# Spec & architecture

**Current-understanding durable artifacts** — the design of the project and how it actually
fits together: design specs, RFCs, interface contracts, architecture / "how it works"
overviews, *and our own exact surface* (our CLI flags, config keys, API, schemas). Prose
you read to understand the system, plus the lookup facts about our own thing. Updated in
place; always reflects present design, not history.

**This is the home for everything settled** — an instruction you were given, an approach
that was agreed, a library that was picked, a convention or preference that was fixed. All
of it lands here as an amendment. State the current rule and move on; there is no separate
ruling artifact to reach for.

**This spec is authoritative — read it before you work, and comply.** It owes your priors
no justification. That a rule departs from mainstream practice or from what you expected is
not grounds to escalate or re-open it. If you think it's wrong, raise it and amend it here.

A *third-party* surface (a framework's API, another product's flags) is `../vendor/`.
Research, a survey, or a draft is `../scratch/`.

## Index

One row per file in this folder. **Keep it current** — adding, renaming, or retiring a spec
file updates its row in the same change. Read this table before you add a file: if a doc on
the subject already exists, amend that doc instead of writing a second one.

| File               | Covers                                  | Status      |
|--------------------|-----------------------------------------|-------------|
| `<slug>.md`        | one line on what this file governs       | implemented |

## Format

One file per subject: `<slug>.md` (no date prefix — describes a thing, not the moment it
was written). Add a status header (`draft`, `accepted`, `superseded`, `implemented`) so
readers can tell whether it still describes current design.
