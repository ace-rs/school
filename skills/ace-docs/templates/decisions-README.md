# Decisions log — exception only

This folder is not a routing destination. Every settled rule remains an amendment to
`../spec/`. A decision record holds the user's reason for a rule, or the option they
rejected, when their words are too long for the spec entry itself.

## When an entry is warranted

Require both conditions:

1. The user settled the rule and gave a reason or rejected an option in their own words.
2. Those words do not fit in the spec entry in a sentence or two.

When either condition fails, amend `../spec/` only, following its "Recording a settled
rule" steps. A stated preference, chosen library, format, name, or default does not
qualify, and a reason that fits in the entry stays in the entry.

**Read the relevant spec before working, and comply.** Raise a wrong spec with the user
and amend it. Do not use a decision record to route around the spec.

Route unsettled research, surveys, drafts, and transcripts to `../scratch/` when that
folder exists. Otherwise report the missing destination and stop; do not keep it here.

## Format

Use one file per decision: `YYYY-MM-DD-slug.md`.

```markdown
# Short title

- **Date:** YYYY-MM-DD
- **PR:** #N or `manual`
- **Status:** accepted | superseded | revised

## Decision

State the current rule in one sentence, as the user gave it.

## Reason

The user's reason, or the option they rejected, in their words.
```

Amend `../spec/` in the same change and link this file from the entry. Readers learn the
current rule from the spec.

## Statuses

- **accepted** — the decision is active.
- **superseded** — a newer linked decision replaces it.
- **revised** — the entry incorporates new context.
