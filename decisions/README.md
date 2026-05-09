# Decisions Log

Append-only record of **decisions** made during reviews, skill changes, and
maintenance — entries that resolve ambiguity, pick between alternatives, or
set a precedent future PRs should follow. When conflicts arise from re-applied
or overlapping changes, consult this log for context.

If your artifact is research, a survey, a draft, a transcript, or any kind of
exploratory write-up — that's not a decision. Use `notes/` instead.

## Format

One file per decision: `YYYY-MM-DD-slug.md`

```markdown
# Short Title
- **Date:** YYYY-MM-DD
- **PR:** #N (or "manual")
- **Status:** accepted | superseded | revised

## Decision
One-liner.

## Rationale
Why.
```

## Statuses

- **accepted** — active, follow this decision
- **superseded** — replaced by a newer decision (link to it)
- **revised** — updated in-place with new context
