# The `.ace/` trail format

Read this contract before writing under `.ace/`. The trail is repository-local,
gitignored runtime state. Never commit it. A removed line is not recoverable from git.

Use **Update the trail** (U1–U3) for a checkpoint. Use **Graduate an item** (G1–G3) only
after the user settles or kills it in verbatim words.

## Layout

```text
.ace/
  save.md            current truth: now / standing facts / pointers
  save.ledger.md     in-flight items: status + provenance per item
```

Anything carrying a status is an item and belongs in `save.ledger.md`. Everything else
belongs in `save.md`.

## Words and provenance

The user states; the agent derives. Put a rule the user states in the durable-docs root's
`spec/` exactly as stated: no added reason and no record of alternatives. Keep an agent
derivation provisional. It becomes the user's statement only when the user takes it up
in their own words.

Use one provenance value on every ledger item:

| Provenance         | Use when                                              |
|--------------------|-------------------------------------------------------|
| `user:verbatim`    | `ev:` preserves the user's exact words                |
| `user:paraphrased` | the claim restates the user's intent in agent words   |
| `agent:inferred`   | the agent derived the claim                           |

Default to `agent:inferred`. Treat any item without a verbatim `ev:` quote as
`agent:inferred`, regardless of its written label. An ambiguity the agent resolves remains
`agent:inferred` until the user confirms it.

## `.ace/save.md`

Use the sections `now`, `standing facts`, and `pointers`. Revise the existing file in
place. Never regenerate it from scratch. Preserve every line that this session did not
re-establish or close.

Keep no history or correction trail. Remove a dead line instead of striking it through.
Keep settled rules in the repository's durable-docs root; retain only a one-line pointer
here. Keep every item with a status in `save.ledger.md`, never here.

Past about 60 lines, inspect whether material should graduate. This is a review signal,
not a size limit. Never shorten the file merely to meet a length target.

## `.ace/save.ledger.md`

Use one ledger across all open topics. Give each item one entry with status, provenance,
claim, and evidence:

```markdown
SETTLED · user:verbatim — **Short claim, bolded.** What the item is and what
  the user said, wrapped at 90 columns with a two-space indent. | ev: "their
  exact words"

open · agent:inferred — **Another claim.** No ev — the user has not said it.
```

Use these statuses for entries that remain until the user takes them up:

| Status                   | Use when                                                |
|--------------------------|---------------------------------------------------------|
| `open`                   | raised but not presented                                |
| `presented`              | presented; the user advanced without settling it        |
| `proposed`               | a specific fix awaits the user's answer                 |
| `deferred`               | deliberately retained for later                         |
| `needs-disambiguation`   | the user's words admit two readings; a question is open |

A standing rule may determine the proposed answer; cite that rule and still wait for the
user's answer.

Use these statuses for entries that may leave:

| Status      | Use when                                                        |
|-------------|-----------------------------------------------------------------|
| `SETTLED`   | the user accepted or stated the item; verbatim `ev:` required   |
| `KILLED`    | the user rejected the item; verbatim `ev:` required             |
| `withdrawn` | the agent no longer holds its own derivation                    |

Delete a withdrawn entry and write nothing elsewhere. Withdraw an agent derivation once
the work moves past it or the user continues without taking it up. Never withdraw an item
that carries the user's words. Surface those items at the next save and retain their full
`ev:` quotes.

## Update the trail

- **U1. Read before writing.** Read both existing trail files. Classify each new fact as
  current truth, standing fact, pointer, or item. Preserve existing lines unless U2 or G3
  permits removal.
- **U2. Revise in place.** Update `save.md` current truth and pointers. Add or revise
  ledger items with status, provenance, claim, and evidence. Remove a line only when it
  moved to a named destination, became finished or superseded, or is an agent derivation
  being withdrawn.
- **U3. Report changes.** Name every destination for a moved line and every line removed
  as finished, superseded, or withdrawn. Never remove or rank entries to reduce file
  length.

## Graduate an item

- **G1. Verify evidence.** Require the user's verbatim words in `ev:`. Without them, keep
  the item as `agent:inferred` and stop graduation.
- **G2. Route through durable docs.** If a `KILLED` item was never in the spec, delete the
  ledger entry, write nothing, and finish without G3. Otherwise find the durable-docs root
  named by the repo's always-loaded instructions. If none is named, inspect `docs/` and
  `.docs/`. If both exist without one being named, report the ambiguity and keep the item
  in the ledger. A present root without `README.md`, or without `spec/README.md`, is
  incomplete: report the missing file and keep the item in the ledger. When no root
  exists, recommend `ace-docs`, wait for the user's approval, and keep the item in the
  ledger. This is a Wait; never scaffold docs during `ace-save`. With one complete root,
  read its `README.md` and `spec/README.md`. For `SETTLED`, write the user's rule into
  that root's `spec/`. For `KILLED`, remove what the user's words kill from the spec and
  update every sentence that still teaches it.
- **G3. Close the ledger entry.** After the docs change succeeds, remove the item from
  `save.ledger.md` and leave a one-line pointer in `save.md`.

## Completion evidence

An update completes with the changed trail paths and U3 report. Graduation completes with
the verbatim `ev:` quote, destination path, removed ledger entry, and `save.md` pointer.
A killed derivation that never entered the spec completes with its verbatim `ev:` quote
and deleted ledger entry; it has no destination or pointer. A missing docs destination
completes only the named Wait and preserves the item.
