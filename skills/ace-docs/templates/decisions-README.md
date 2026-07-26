# Decisions Log

**Point-in-time defenses against future re-litigation** — rulings on
*contested* questions, recorded so the same argument doesn't have to be
re-fought next quarter. Each entry is frozen at the moment of decision;
if a later ruling reverses it, write a new dated decision that links back
and mark the old one `superseded`.

This folder is **not** a routing destination. It is never where something
goes *instead of* `../spec/` — every settled thing is a spec amendment
first, and a decision is an extra artifact written on top of it.

## When to add an entry

Only two triggers, and the spec edit happens either way:

- **A live alternative lost.** Two reasonable approaches were debated,
  one won, and without the entry the next debate replays from scratch —
  or a reviewer pushed back and the defense is worth preserving.
- **The answer cuts against the obvious default** — mainstream practice,
  what an agent's training data would suggest, or this project's own
  prior convention — so a future reader would assume we just didn't know
  better.

**Don't** add a decision for anything settled. Being told to do something
is not contention. Agreeing on an approach nobody argued against is not
contention. Picking the conventional library, naming a file, fixing a
format — none of that is contention. Amend `../spec/` and move on. A log
padded with uncontested entries buries the load-bearing ones, and an
unwritten decision costs at most one re-argument.

If your artifact is research, a survey, a draft, a transcript, or any
exploratory write-up — that's scratch, not a decision. Use `../scratch/`.
If it's forward-looking design, use `../spec/`.

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
Why this, and specifically why *not* the obvious alternative — that's
the part that prevents re-litigation.
```

## Statuses

- **accepted** — active, follow this decision
- **superseded** — replaced by a newer decision (link to it)
- **revised** — updated in-place with new context
