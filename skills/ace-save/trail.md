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

## Whose words are whose

The user states; you derive. What they state lands in `docs/spec/` the way they
stated it — the rule, plainly, at the length they gave it, with no reason
supplied and no record of how it came up.

What you derive is yours and provisional. Taken up, it becomes their sentence.
Carried on past, it goes away and leaves nothing behind — withdrawing it is your
own move, made without asking.

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
struck through. A settled rule lives in `docs/`; here it appears only as a
one-line pointer. An item with a status lives in `save.ledger.md`, never here.

Past ~60 lines the file is telling you items are overdue to graduate. That is
a reading, not a ceiling — go move them out. Never shrink the file for its own
sake, and if nothing can move, leave it long and say so in the report.

## `.ace/save.ledger.md` — items

A single in-flight buffer across all open walks, not per-topic. The only home
of item statuses. Every item is one entry — status, provenance, claim, and its
evidence — in the same quoted-evidence grammar as the stamp chain
(`ace/ledger.md`), with a different source: a stamp's `ev:` quotes tool output;
an item's `ev:` quotes the user.

```markdown
SETTLED · user:verbatim — **Short claim, bolded.** What the item is and what
  they said, wrapped at 90 columns with a two-space indent. | ev: "their exact
  words"

open · agent:inferred — **Another claim.** No ev — they haven't said it.
```

Statuses group by whether the entry can leave the file:

**No exit — the entry stays until the user takes it up.**

- `open` — raised, not yet put to the user.
- `presented` — put to them; they advanced without answering on substance.
- `proposed` — a specific fix offered, awaiting their yes or no. A standing
  rule may force the answer; cite the rule as the derivation and still wait.
- `deferred` — real, deliberately not now.
- `needs-disambiguation` — their words admit two readings; a question is
  pending.

These hold an item carrying the user's words. An `agent:inferred` item at any of
them is yours, and `withdrawn` is open to it at any time.

**Exits the ledger.**

- `SETTLED` — the user said it. Verbatim words required. Graduates; see
  *Graduating an item*.
- `KILLED` — the user said no to it. Verbatim words required. Graduates; see
  *Graduating an item*.
- `withdrawn` — you dropped a derivation of your own, with no user input. Delete
  the entry and write nothing anywhere. The reason is always that you no longer
  hold it; file length is never the reason.

Provenance: `user:verbatim` (their exact, quotable words) · `user:paraphrased`
(their intent, your wording) · `agent:inferred` (you derived it — they never
said it).

Default provenance is `agent:inferred`: an item written without a quoted user
phrase IS agent-derived, whatever else it's tagged. Their words or it isn't
theirs — SETTLED/KILLED must carry the user's verbatim words in `ev:`; an entry
with no `ev:` quote is malformed and reads as `agent:inferred`. Forgetting to
down-rank a solo call fails safe — it stays a derivation. Ambiguity the model
resolves stays `agent:inferred` until the user confirms — never folded into the
record as stated fact.

Withdraw a derivation once the work moves past it or they carry on without
taking it up. Surface the items carrying their words at the next save, and never
trim one for length. A long ledger is derivations you are still holding.

## How a line leaves — both files

A line goes when it moves to a named destination, when the thing it describes is
finished or superseded, or when you withdraw a derivation of your own. The last
two leave with no destination. Say in the save report where each moved line
went, and name any that were deleted.

Never drop a line to hit a size. Never rank lines by importance to choose what
to cut — how important a line looks is a judgment about where it belongs and
how tersely to write it, never about whether it survives.

## Graduating an item

An item the user stated leaves by landing through the `docs/README.md` gate —
which means `spec/`, current design truth. Write the rule as they said it, at
the length they gave it: no reason they didn't supply, no note that a choice was
made or what it was weighed against. Once it lands, trim the entry from the
ledger and leave a one-line pointer in `save.md`. The ledger stays short because
stated items leave and derivations get withdrawn, not because entries are rare.

- `SETTLED` — write their sentence into the spec.
- `KILLED` — delete from the spec whatever their words kill, and edit any
  sentence that still teaches the killed thing. A derivation of yours was never
  in the spec: delete the entry and write nothing.

Only an item carrying the user's verbatim words graduates. What it was tagged
beforehand doesn't matter — an `agent:inferred` item the user kills graduates on
their words — but a derivation they never took up leaves by withdrawal instead,
however confident it is.

**No `docs/` in the repo.** The first time an item settles with nowhere to
graduate to, recommend the user run `/ace-docs`, and wait for their go. Never
scaffold `docs/` inside a save. Until they approve, the item stays in the
ledger — that is the correct state, not a backlog to clear.
