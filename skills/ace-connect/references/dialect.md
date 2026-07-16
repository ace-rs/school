# ace-connect — wire format & dialect

Read this before you send or interpret a message. Both peers write and read the
same dialect; no negotiation. It is always on.

## Wire format

One line, tab-separated:

```
from=<your-slug>\tto=<peer-slug>\tbody=<text>
```

Keep the whole line under ~500 characters; some receivers (notably Claude
Code's notification surface) silently truncate beyond that. For anything that
won't fit — code, diffs, logs, long prose — write a tmp file
(`/tmp/<purpose>-<slug>.<ext>`) and reference the path in `body`. Don't clean up
tmp files; let the OS handle it.

## Brevity verbs

Open every body with one of these:

| Verb    | Meaning                                  |
|---------|------------------------------------------|
| `ACK`   | received                                 |
| `WAIT`  | working, no progress yet                 |
| `DONE`  | task complete                            |
| `ASK`   | need input                               |
| `STUCK` | blocked                                  |
| `FILE`  | payload at path                          |
| `CTX`   | background / one-liner setup             |
| `NACK`  | reject                                   |

The list is extensible. If a new verb fits the same pattern (uppercase, short,
imperative), use it — the receiver will infer meaning from context. Add it to
the table when it stabilizes.

### Scoping an `ASK`

An `ASK` names the specific fact or action you need from the peer's domain —
never the underlying problem you're solving. Your problem and its decision
stay with you (see SKILL.md "Boundary").

```
✅ ASK: does repo-create tooling allow dots in names?
❌ ASK: we have repo naming problem, resolve
```

## Caveman rules

Drop articles, hedges, pleasantries, sign-offs. Preserve paths, identifiers,
version numbers, code, URLs, error strings verbatim — they are load-bearing.

## Reply style (Chain-of-Draft)

When the body reports rather than asks (`DONE`, `STUCK`, answers to `ASK`), use
dash-prefixed steps, ≤5 words each. Asks stay imperative one-liners.

## Examples

```
ASK alice: review /tmp/x.sql, focus indexes
WAIT
DONE alice:
- ran tests, 3 fail
- root cause: stale fixture
- patch: /tmp/fix.diff
STUCK:
- migration 0042 fails
- error: duplicate key on user_id
- need: confirm dedupe strategy
FILE /tmp/dump-school.txt
```
