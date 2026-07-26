# Spec & architecture

**Current-understanding durable artifacts** — the design of the project and how it actually
fits together: design specs, RFCs, interface contracts, architecture / "how it works"
overviews, *and our own exact surface* (our CLI flags, config keys, API, schemas). Prose
you read to understand the system, plus the lookup facts about our own thing. Updated in
place; always reflects present design, not history.

**This is the default home for anything settled** — an instruction you were given, an
approach that was agreed, a library that was picked, a convention that was fixed. All of it
lands here as an amendment. `../decisions/` is not an alternative destination: it is a
dated entry written *on top of* a spec amendment, and only when the call was contested.

A *third-party* surface (a framework's API, another product's flags) is `../vendor/`.
Research, a survey, or a draft is `../scratch/`.

## Format

One file per subject: `<slug>.md` (no date prefix — describes a thing, not the moment it
was written). Add a status header (`draft`, `accepted`, `superseded`, `implemented`) so
readers can tell whether it still describes current design.
