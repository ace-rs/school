# The ACE session trail

How a session's state persists across `/clear`, exit, and context switches. Written by
`ace-save`, read by `ace`/`ace-afk` on resume. All of it lives under `.ace/` in the repo
root, gitignored (`/.ace/`) — runtime scratch, never committed.

## Layout

```
.ace/
  save.md            current truth, overwritten wholesale each save (≤60 lines)
  save.ledger.md     single in-flight item buffer: status + provenance per item
  connect.log        ace-connect inbox (control mode) — tab-separated, append-only
  afk.log            ace-afk unattended handoff report
```

Files are named by the skill that owns them (`save`, `connect`, `afk`); the two-role
`ace-save` pair distinguishes by suffix (`.md` state vs `.ledger.md` history).

## Two roles, split on purpose

- **`save.md` — current truth.** Overwritten every save; no history, no
  corrections-of-corrections. A dead item is absent, not struck through. A settled ruling
  appears here only as a one-line pointer to its home in `docs/`.
- **`save.ledger.md` — item history.** The only home of item statuses. A single file (not
  per-topic): one in-flight buffer across all open walks. Every item carries a **status**
  (open · presented · proposed · self-resolved · SETTLED · KILLED · deferred ·
  needs-disambiguation · phantom) and a **provenance** (`user:verbatim` · `user:paraphrased`
  · `agent:inferred`).

The two split because their write disciplines differ: `save.md` is rewritten wholesale,
the ledger accumulates. Keeping them separate stops the current-truth snapshot from
carrying history.

## Lifecycle — the ledger is a staging buffer, not an archive

```
open item          → ledger (agent:inferred)
ruled, verbatim    → ledger SETTLED (briefly, quoting the user's words)
durable design     → spec/       (default)  + trimmed from ledger
would-defend ruling→ decisions/              + trimmed from ledger
current truth       → save.md keeps a one-line pointer
```

A SETTLED item's durable form graduates out via the `docs/README.md` gate. Most settled
items are design outcomes and land in `spec/`; only a ruling you'd defend if reopened earns
a dated `decisions/` doc. Once graduated, the ledger line is trimmed and `save.md` keeps a
pointer. The ledger stays short because settled items leave — not because they're rare.

See [`../decisions/2026-07-17-ace-trail-provenance-doctrine.md`](../decisions/2026-07-17-ace-trail-provenance-doctrine.md)
for the rulings behind this shape.
