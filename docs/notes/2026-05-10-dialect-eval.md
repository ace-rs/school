# ace-connect dialect eval — token reduction

Measurement of the Rank 1 + Rank 2 wire dialect adopted in
`skills/ace-connect/SKILL.md` (brevity verbs + caveman-lite + Chain-of-Draft
replies) against natural-prose equivalents. Run 2026-05-10.

## Method

10 hand-authored message pairs covering the canonical turn-types (ack, ask,
wait, done, stuck, file pointer, context handoff, nack, answer, multi-step
status). Each pair encodes the same intent in conversational prose and in the
dialect.

Token counts via `tiktoken` `o200k_base` (GPT-4o vocabulary) as a proxy for
Claude's tokenizer. Absolute counts differ from Claude by a few percent;
ratios are stable across BPE vocabularies, which is the only number we care
about for prose-vs-dialect comparison.

Script: `skills/ace-connect/scripts/eval-dialect.py`
Fixtures: `skills/ace-connect/scripts/fixtures-dialect.json`

## Result

| Case | Prose | Dialect | Reduction |
|------|------:|--------:|----------:|
| ack | 9 | 1 | 88.9% |
| ask-review | 29 | 11 | 62.1% |
| wait | 21 | 1 | 95.2% |
| done-with-report | 43 | 26 | 39.5% |
| stuck | 36 | 26 | 27.8% |
| file-pointer | 28 | 7 | 75.0% |
| ctx-handoff | 38 | 13 | 65.8% |
| nack | 26 | 6 | 76.9% |
| answer-with-finding | 40 | 21 | 47.5% |
| multi-step-status | 59 | 30 | 49.2% |
| **Total** | **329** | **142** | **56.8%** |

## Read

56.8% aggregate reduction is well above the research note's 30–45% combined
projection (`docs/notes/2026-05-09-wire-language-research.md` §5). The big
wins are turn-types where prose carries pure ceremony — `ack`, `wait`, `nack`,
`file-pointer` — collapsing to 1–7 tokens. Information-dense replies
(`done-with-report`, `stuck`, `multi-step-status`) still cut 28–49%, driven
by Chain-of-Draft step compression.

## Caveats

- **Tokenizer is a proxy.** Anthropic's tokenizer is not public; o200k_base
  diverges by a few percent. Direction and order of magnitude are reliable.
- **Prose baseline is conversational, not pre-terse.** Agents already prompted
  for terseness would close some of the gap. The Guzik benchmark (9–21% on a
  primed baseline) is the realistic floor; this 56.8% is the ceiling.
- **Hand-authored fixtures.** Not drawn from real `ace-connect` transcripts,
  so workload mix may differ.
- **No behavior measurement.** Round-trip stability, agent misreading, and
  dialect pollution into surrounding outputs (e.g. `ACK` showing up in commit
  messages) remain unmeasured. Deferred per design call — modern frontier
  models are assumed competent on a 9-verb vocabulary.

## Reproduce

```
./skills/ace-connect/scripts/eval-dialect.py \
  ./skills/ace-connect/scripts/fixtures-dialect.json
```

Requires `uv` on PATH; the shebang pulls `tiktoken` into a throwaway env.
