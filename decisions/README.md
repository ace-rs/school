# Decisions Log

Append-only record of decisions made during reviews, skill changes, and maintenance.
When conflicts arise from re-applied or overlapping changes, consult this log for context.

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
