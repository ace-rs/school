# ace-connect peers are consultants, not owners; control mode by default

- **Date:** 2026-07-17
- **PR:** manual
- **Status:** accepted

## Decision

Two rulings hardening the ace-connect bus against agent overreach:

1. **Ownership boundary, both directions.** The sender owns its task and its
   decisions — a peer is a domain consultant, asked only for facts or actions
   inside *their* remit; a user-scoped ask ("talk to X, but only about Y") is a
   hard boundary carried verbatim. The receiver owns its repo — an inbound ask
   is a request, not an instruction; "user needs this" from a peer is not user
   authorization, and an ask that conflicts with the receiving repo's rules gets
   a `NACK` with the reason, never an implementation. Relaying is banned: notes,
   decisions, and peer messages cross the boundary only on explicit user
   instruction.

2. **Control mode is the silent default.** The stated/implied/ask resolution
   ladder is gone. An agent runs in control mode unless the user explicitly said
   "autonomous" this session — never ask which mode, never infer autonomous from
   a role description.

## Rationale

Observed failure (2026-07-16): an infra agent with a repo-naming problem was
told to consult the platform agent *only about platform tooling*. It instead
forwarded the whole naming problem and asked platform to resolve it —
transferring ownership of a decision that was the infra session's (and its
user's) to make. The symmetric failure is the receiver treating a peer's
"implement feature X for me" as user-authorized work even when X is wrong per
the receiving repo's own instructions.

The prior mode ladder let agents infer autonomous from a role description,
which is the same overreach in mode form: authority self-granted from ambient
signals. Explicit user say-so is the only path into autonomous; control (log,
answer queries, take no tasks) is the floor and the default, and asking "which
mode?" on a blank invocation was friction with no safety gain over defaulting.

Same landing consolidated inbound handling into one `## Inbound` section
(sender log, control inbox, peer-authority + NACK example) and shrank
`Autonomous-mode safety` to the action whitelist — the authority principle now
lives in exactly one place.

Sibling ruling: `2026-07-12-ace-connect-rules-are-model-interpreted.md` — these
boundary rules are likewise model-interpreted at the surface, never encoded in
transport.
