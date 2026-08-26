# The step ledger

The stamp-chain contract for any skill whose body is a numbered procedure. A skill
adopts it with a `## Stamp chain` section pointing here; the rules below then bind that
skill's numbered steps.

## The stamp

Every numbered step ends with a **stamp** — one line:

```
⛓ <n> <step> | ev: "<decisive line>" | next: <n+1> <step>
```

Keep this canonical stamp plain text. Every procedure defines stamp names through its
numbered steps. The step number plus its bolded prefix is the stamp identity. `next:` uses
that full identity for the following step. An explicit branch uses the full identity of
its stated destination. The final step uses `next: done` unless the procedure names a
loop destination. `ev:` quotes the decisive result of the action named by the prefix.

Keep each prefix concise and single-action. A prefix that needs `and`, or cannot be made
concise, contains more than one action; split the step.

On a Markdown conversation surface, emit the canonical stamp once inside a plain fenced
block. On logs, files, handoffs, terminals, and unknown surfaces, emit the canonical line
as plain text. Never emit ANSI escapes. Put one blank line before and after every stamp;
never attach it directly to prose, tool output, or the next step's text.

Emit exactly one representation:

```
⛓ 4 Specs | ev: "docs/spec/widget.md read" | next: 5 Draft plan
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
- **Chained entry.** Open a step by reprinting the previous step's stamp verbatim. If
  that stamp was already emitted immediately before the step boundary, reuse that
  emission as the entry token instead of printing a second copy. No stamp to reprint or
  reuse → the step cannot be entered; go back and produce it.
- **Stamp-named succession.** The only step you may open is the one the last stamp
  names. "What's next" is never a judgment call — it is written in the line you must
  reprint or reuse to proceed.
- **No skip vocabulary.** "Skipped", "not applicable", "inferred done", "effectively
  covered" do not exist. Every step runs; a step whose honest execution is small still
  runs and leaves real evidence.
- **Wait means wait.** A step that ends by asking the user stamps with the question
  asked, and the next step's entry quotes the user's answer. No answer to quote → the
  chain is parked, not advanced.
- **Exemptions need the user's verbatim words.** The only valid deviation from a step
  quotes the user's in-session words in the stamp. A self-minted rationale ("obviously
  not needed here") quotes nobody and is void.
