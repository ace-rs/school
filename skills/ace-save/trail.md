# The `.ace/` trail format

Read this before writing anything under `.ace/`. It binds every skill that
writes the trail, not just `ace-save`.

The trail lives in `.ace/` and is gitignored — runtime scratch, never
committed, and never recoverable from git. A line removed here is gone.

```
.ace/
  save.md            current truth: now / standing facts / pointers
  save.ledger.md     in-flight items: status + provenance per item
```

## What goes where

Anything carrying a status is an item and belongs to `save.ledger.md`.
Everything else — the narrative, what holds across sessions, where to look —
is `save.md`.

## `.ace/save.md` — current truth

Sections: now / standing facts / pointers.

Revise it in place. Change the lines that changed and leave the rest alone.
Never regenerate the file from scratch — a line you did not re-derive this
session is a line silently lost.

No history and no corrections-of-corrections: a dead line is absent, not
struck through. A settled ruling lives in `docs/`; here it appears only as a
one-line pointer. An item with a status lives in `save.ledger.md`, never here.

Past ~60 lines the file is telling you items are overdue to graduate. That is
a reading, not a ceiling — go move them out. Never shrink the file for its own
sake, and if nothing can move, leave it long and say so in the report.

## `.ace/save.ledger.md` — items

A single in-flight buffer across all open walks, not per-topic. The only home
of item statuses. Every item carries a status AND a provenance, both leading
the entry:

```markdown
SETTLED · user:verbatim — **Short claim, bolded.** What the item is and what
  the ruling was, wrapped at 90 columns with a two-space indent.
  "their exact words"

open · agent:inferred — **Another claim.** No quote line — nothing is ruled.
```

Statuses group by whether the entry can leave the file:

**No exit — the entry stays until the user rules on it.**

- `open` — raised, not yet put to the user.
- `presented` — put to them; they advanced without ruling on substance.
- `proposed` — a specific fix offered, awaiting their yes or no. A standing
  rule may force the answer; cite the rule as the derivation and still wait.
- `deferred` — real, deliberately not now.
- `needs-disambiguation` — their words admit two readings; a question is
  pending.

**Exits the ledger** — see *Graduating an item*.

- `SETTLED` — the user ruled it in. Verbatim words required.
- `KILLED` — the user ruled it out. Verbatim words required.

Provenance: `user:verbatim` (their exact, quotable words) · `user:paraphrased`
(their intent, my wording) · `agent:inferred` (I derived it — they never said
it).

Default provenance is `agent:inferred`: an item written without a quoted user
phrase IS agent-derived, whatever else it's tagged. Settling is the burden of
proof, not inferring — SETTLED/KILLED must embed the user's verbatim words
inline; a ruling with no quoted phrase is malformed and reads as
`agent:inferred`. Forgetting to down-rank a solo call fails safe — it stays a
derivation. Ambiguity the model resolves stays `agent:inferred` until the user
confirms — never folded into the record as stated fact.

An `agent:inferred` item stays until the user rules on it. A long ledger means
a lot is open with them: surface it at the next save. Never trim it for
length.

## How a line leaves — both files

A line goes only when it moves to a named destination, or when the thing it
describes is finished or superseded. A killed item with nothing to amend in the
spec is the one deletion with no destination — see *Graduating an item*. Say in
the save report where each moved line went, and name any that were deleted.

Never drop a line to hit a size. Never rank lines by importance to choose what
to cut — how important a line looks is a judgment about where it belongs and
how tersely to write it, never about whether it survives.

## Graduating an item

A ruled item leaves by landing its durable form through the `docs/README.md`
gate — which means `spec/`, current design truth. Once it lands, trim the entry
from the ledger and leave a one-line pointer in `save.md`. The ledger stays
short because ruled items leave, not because they're rare.

- `SETTLED` — lock the ruling in as a spec amendment.
- `KILLED` — delete from the spec whatever the ruling kills. Where the idea
  would otherwise be raised again, add a sentence or two of rationale so it
  stays killed. An `agent:inferred` kill is the usual case: nobody is holding
  the idea, so without the rationale the agent re-derives it next session.
  Where nothing in the spec would resurface it, delete the entry and write
  nothing.

Only a ruling with the user's verbatim words graduates. What the item was
tagged before the ruling doesn't matter — an `agent:inferred` item the user
kills graduates on their words — but a derivation the user never ruled on
never does, however confident it is.

**No `docs/` in the repo.** The first time an item settles with nowhere to
graduate to, recommend the user run `/ace-docs`, and wait for their go. Never
scaffold `docs/` inside a save. Until they approve, the item stays in the
ledger — that is the correct state, not a backlog to clear.
