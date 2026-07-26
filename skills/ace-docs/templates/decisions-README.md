# Decisions Log — the escape hatch

**This folder is not a routing destination.** It exists only because
someone hit a case `../spec/` genuinely could not carry. It is not where
something goes *instead of* the spec: every settled thing is a spec
amendment, and an entry here is an extra artifact written on top of one.

Default state for a repo is **no decisions log at all**. If you are
deciding where something goes, the answer is `../spec/`.

## When an entry is warranted

Both must hold:

1. **An argument actually happened.** Two positions were on the table,
   one lost, and the loser will otherwise come back. The evidence is in
   the conversation or the review thread — if you can't point to it,
   there was no argument.
2. **The losing case is substantial.** Detailed enough that it would be
   re-argued from scratch without a written record. If you can state it
   in a sentence, that sentence is the spec edit.

**The spec is authoritative — read it before you work, and comply.** It
owes your priors no justification. A rule that departs from mainstream
practice, from what you'd have chosen, or from what you expected is *not*
grounds for an entry: the spec says so, so do it. If you think the spec
is wrong, raise it and amend the spec — don't route around it here.

**Not warranted:** a preference the user stated. A convention we fixed. A
library we picked. A format, a name, a default. Amend `../spec/` and move
on. A log padded with uncontested entries buries the load-bearing ones.

If your artifact is research, a survey, a draft, a transcript, or any
exploratory write-up — that's `../scratch/`. Everything else is
`../spec/`.

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
The losing case, in full, and why it lost — that's the part that
prevents re-litigation, and the only reason this file exists rather than
a spec edit alone.
```

`../spec/` is amended in the same change; a reader learns current state
from the spec, never from here.

## Statuses

- **accepted** — active, follow this decision
- **superseded** — replaced by a newer decision (link to it)
- **revised** — updated in-place with new context
