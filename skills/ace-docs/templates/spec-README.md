# Spec & architecture

Store the project's current design, intended behavior, architecture, interface contracts,
and exact config, CLI, API, and schema. Update each file in place as the system changes.

Put every settled instruction, agreement, library choice, convention, and preference
here, written as the user gave it, by the steps under "Recording a settled rule".

**Read the relevant spec before working, and comply.** Raise a wrong spec with the user
and amend it. Do not reopen, annotate, or route around a spec because it differs from a
common default or personal preference.

Route third-party lookup to `../vendor/` when that folder exists. Route unsettled
research, surveys, and drafts to `../scratch/` when that folder exists. If the matching
folder is absent, report the missing destination and stop; do not file the artifact here.

## Recording a settled rule

Run these steps when the user's words settle something: a stated rule, an accepted
proposal, a ruling on an item. An agent derivation never enters here; it stays in the
session ledger, `.ace/save.ledger.md`, as `agent:inferred` until the user takes it up in
their own words.

- **R1. Capture the words.** Copy the user's statement verbatim, with any reason or
  rejected option they gave anywhere in the conversation. A ruling settles only the
  question it answered: words said on a tangent, and conclusions you draw from the
  ruling, are your own derivations. Do not widen the rule, split it into further rules,
  add reasons of your own, or name alternatives the user did not reject.
- **R2. Choose the audience.** A fact every project using a skill needs → a pending
  school change in `.ace/save.ledger.md`. A rule for this repository's team → continue to
  R3. A rule about how the agent behaves for this user everywhere → a user-level
  instructions file, only with the user's explicit authority. A fact about this
  codebase only → the repository's `CLAUDE.md` or `AGENTS.md`.
- **R3. Check the reader.** Would a later reader, holding the spec and the code but not
  this conversation, take the rule for an oversight and fix it? Ordinary preferences and
  departures from convention do not fail this test; a rule that skips a check, removes a
  safeguard, or accepts a loss usually does.
  - Passes → R4 with what R1 captured.
  - Fails, and R1 captured the user's reason → R4.
  - Fails, no reason → ask the user for one in a single line. This is a Wait. Write
    whatever they answer in their words; if they give none, write the rule bare. Never
    add "deliberate" or any marker the user did not say.
- **R4. Size the entry.** Put the rule, and any reason or rejected option from R1 or R3,
  in the spec entry when it fits in a sentence or two, in the user's words. When the
  reason needs more, write the rule in the spec entry and the rest in a decision record
  linked from it; opening `../decisions/` for the first time follows `ace-docs` D1–D5.
- **R5. Find the file.** Read the index below. Amend the file whose subject matches; add
  a file and its index row only when none does.
- **R6. Write now or carry it.** Write the entry now when the current task authorizes
  edits under this docs root. Otherwise record it in `.ace/save.ledger.md` as `SETTLED`
  with the verbatim words and the R2–R4 outcome, in the format `ace-save/trail.md`
  gives; it is written here at the next graduation.
- **R7. Verify.** The entry holds the user's words and nothing they did not say; a rule
  that failed R3 carries its reason or a link to it; the index matches the folder.

## Index

Keep one row per spec file. Update this table in the same change when adding, renaming, or
retiring a file. Read it before adding a spec; amend the existing file when its subject
already has a row.

| File        | Covers                             | Status      |
|-------------|------------------------------------|-------------|
| `<slug>.md` | one line on what this file governs | implemented |

## Format

Use one file per subject: `<slug>.md`. Start it with a status: `draft`, `accepted`,
`implemented`, or `superseded`.
