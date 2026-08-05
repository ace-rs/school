# The step ledger

The stamp-chain contract for any skill whose body is a numbered procedure. A skill
adopts it with a `## Ledger` section pointing here; the rules below then bind that
skill's numbered steps.

## The stamp

Every numbered step ends with a **stamp** — one line:

```
⛓ <n> <step> | ev: "<decisive line>" | next: <n+1>
```

## The rules

- **Evidence is quoted, never re-pasted.** The full artifact — command output, prose
  just presented, a file written — appears exactly once, where the step produced it.
  `ev:` quotes at most two decisive lines from it, verbatim. A line you cannot quote
  verbatim from this step's own output is no evidence, and a stamp without evidence is
  no stamp. Where the work product is prose just presented (a plan, a summary), the
  stamp points at it (`ev: "plan above, 4 files"`) — it never restates it.
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
