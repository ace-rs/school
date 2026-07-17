# The ACE trail carries provenance; settled items graduate to docs

- **Date:** 2026-07-17
- **PR:** manual
- **Status:** accepted

## Decision

Three rulings behind the trail-v2 rework of the save/resume trail (`ace-save`, `ace`,
`ace-afk`, `ace-connect`). The trail's on-disk shape is specified separately in
[`../spec/ace-trail.md`](../spec/ace-trail.md); this doc records the *why*.

1. **Provenance is forget-proof by default, not by discipline.** Every ledger item is
   stamped `user:verbatim | user:paraphrased | agent:inferred`, defaulting to
   `agent:inferred`. Settling is the burden of proof: `SETTLED`/`KILLED` must embed the
   user's verbatim words inline, or the item is malformed and reads as `agent:inferred`.

2. **Cross-skill doctrine unifies by vocabulary, not location.** The provenance enum is
   shared across skills, but no skill references another's file. `ace-connect`'s
   send/receive rule ("ruled" requires a citation, else `proposal`) is the same axis on the
   wire, not a pointer to the trail spec.

3. **Settled items graduate via the docs gate, defaulting to `spec/`.** The ledger is a
   staging buffer, not a resting place. On settle, an item's durable form moves out through
   `docs/README.md` — most land in `spec/` (current design truth); `decisions/` is reserved
   for a ruling you'd defend if reopened. The line is then trimmed from the ledger.

## Rationale

The obvious design — "the agent honestly labels its own inferences" — relies on the agent
*remembering* to down-rank a solo call. Inverting it (default `agent:inferred`, "settled"
must prove itself with embedded verbatim words) makes forgetting fail safe: a lapse leaves
an item as a derivation, and the agent cannot launder its own inference into the user's
mouth. On resume the reader trusts the citation, not the label — a `SETTLED` item with no
quoted phrase is treated as `agent:inferred`.

Skills load independently (progressive disclosure), so a "see `workflow.md`" cross-reference
dangles whenever `ace-connect` or `ace-save` loads standalone. What's shared is therefore the
enum vocabulary, not a central file — each skill stays self-contained.

Defaulting graduation to `spec/` follows the gate's own rule-1 bar ("a ruling you'd defend
if someone reopened it"): routine settled items don't clear it and correctly fall to
"how our system is built → `spec/`." Reserving `decisions/` for the defensible few keeps it
lean and `spec/` canonical as the living design.

Sibling: `2026-06-29-dev-session-runs-on-prod9-school.md` (the trail persists per-repo, not
in machine-local memory).
