# Route decided-but-not-yet-applied rulings to the spec, not just notes

- **Date:** 2026-07-07
- **PR:** #1
- **Status:** accepted

## Decision

A decision that changes or retires existing behavior updates `spec/` (the living source of
truth) at decision time — even before the code lands — and is promoted to `decisions/` (the
frozen why). A ruling must never live only in a resume/handoff note. Added as a
"Decided-but-not-yet-applied" subsection to the `ace-docs` design-record routing guidance.

## Rationale

A settled decision (retire a component still present in code) got re-litigated 3–4 times
because it lived only in transient resume notes, while spec + code — the trustworthy
sources — still taught the superseded design. Resume notes are superseded by the next
resume, so the ruling evaporated at each handoff; anyone reconstructing the design from
spec/code rediscovered the old answer as current. The design record already sorts by
permanence, but had no rule for the tier handoff when a decision outruns the code. The spec
holds the up-to-date *what*; the ADR holds the frozen *why* — a decision record is not
where you look for current state.
