# The step ledger

The stamp-chain contract for any skill whose body is a numbered procedure. A skill
adopts it with a `## Stamp chain` section pointing here; the rules below then bind that
skill's numbered steps.

## The stamp

Every numbered step ends with a **stamp** — one line:

```
⛓ <n> <step> | ev: "<decisive line>" | next: <n+1>
```

Keep this canonical stamp plain text. When the output surface is a known ANSI-capable
terminal, print a display-only rendering with one muted base and one highlight color:

`ESC` below means the literal escape byte (`0x1b`), not the visible letters `E`, `S`,
and `C`.

- Start the line with `ESC[38;5;250m` for muted light gray.
- Wrap only `⛓ <n>`, the literal `ev:`, and the literal `next:` in cyan with
  `ESC[38;5;6m`.
- Restore muted light gray with `ESC[38;5;250m` after every cyan span. Never use
  `ESC[39m` between spans.
- End the line with `ESC[39m`.

Keep the step name, evidence, separators, and any other fields in the muted base color.
On Markdown, logs, files, or an unknown surface, print only the canonical stamp. Never
put ANSI escapes in the canonical stamp, a chained reprint, subagent handoff, or `.ace/`
file. The display rendering never opens or closes a step.

Canonical example:

```
⛓ 4 Specs | ev: "docs/spec/widget.md read" | next: draft plan
```

Display example (annotations name styling; do not print the angle-bracket labels):

```
<cyan>⛓ 4<muted> Specs | <cyan>ev:<muted> "docs/spec/widget.md read" | <cyan>next:<muted> draft plan
```

## The rules

- **Evidence is quoted, never re-pasted.** The full artifact — command output, prose
  just presented, a file written — appears exactly once, where the step produced it.
  `ev:` quotes at most two decisive lines from it, verbatim. A line you cannot quote
  verbatim from this step's own output is no evidence, and a stamp without evidence is
  no stamp. Where the work product is prose just presented (a plan, a summary), the
  stamp points at it (`ev: "plan above, 4 files"`) — it never restates it.

  The two-line cap holds only while the quoted source survives alongside the stamp.
  In a durable record whose source dies with the session — the `.ace/` trail quoting
  conversation — `ev:` runs as long as the words require; never trim it for size.
- **Chained entry.** A step opens by reprinting the previous step's stamp line,
  verbatim. No stamp to reprint → the step cannot be entered; go back and produce it.
- **Stamp-named succession.** The only step you may open is the one the last stamp
  names. "What's next" is never a judgment call — it is written in the line you must
  reprint to proceed.
- **No skip vocabulary.** "Skipped", "not applicable", "inferred done", "effectively
  covered" do not exist. Every step runs; a step whose honest execution is small still
  runs and leaves real evidence.
- **Wait means wait.** A step that ends by asking the user stamps with the question
  asked, and the next step's entry quotes the user's answer. No answer to quote → the
  chain is parked, not advanced.
- **Exemptions need the user's verbatim words.** The only valid deviation from a step
  quotes the user's in-session words in the stamp. A self-minted rationale ("obviously
  not needed here") quotes nobody and is void.
