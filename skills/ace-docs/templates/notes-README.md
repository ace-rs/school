# Notes

Durable artifacts that are **not decisions** — research dumps, surveys, drafts,
transcripts, exploratory write-ups, feature-request bodies. Anything an agent
or human produces that's worth preserving for future context but doesn't resolve
ambiguity, pick between alternatives, or set a precedent.

If it *is* a decision, use `../decisions/` instead. If it describes
intended-to-build behavior, use `../spec/`.

## Format

One file per artifact: `YYYY-MM-DD-slug.md`. No required template — write
whatever shape fits the content. A short header (date, who/what produced it,
what it's for) is helpful but not enforced.

## Lifecycle

Append-only by default. Updates that materially change the conclusion belong
in a new dated file that links back; minor corrections in-place are fine.
Nothing here is binding — these are notes, not policy.
