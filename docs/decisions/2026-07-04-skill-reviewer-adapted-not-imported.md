# skill-reviewer is adapted first-party, not imported; find-skills dropped

- **Date:** 2026-07-04
- **PR:** manual
- **Status:** accepted

## Decision

Drop `find-skills` (imported from `vercel-labs/skills`) from the baseline. Add
`skill-reviewer` as a first-party skill, authored here in house style and adapted from
Anthropic's plugin-dev `skill-reviewer` agent — **not** wired through `[[imports]]`.

## Rationale

- **find-skills earned no keep.** It shipped from a different provider than `skill-creator`
  and was never used. A skill-discovery skill is out of charter for a baseline whose job is
  a small, always-loaded harness set.

- **skill-reviewer cannot be imported.** `ace` resolves an `[[imports]]` entry by cloning
  the source repo and locating `**/skills/<name>/SKILL.md`. Anthropic publishes
  `skill-reviewer` only as `plugins/plugin-dev/agents/skill-reviewer.md` in
  `anthropics/claude-code` — an agent definition, not a `skills/<name>/SKILL.md`. No
  `[[imports]]` entry can resolve it; adding one would break `ace school pull`. It is also
  absent from `anthropics/skills`, so "the same provider as skill-creator" has nothing to
  offer.

- **Adapted, not vendored verbatim.** The Anthropic agent advises third-person
  descriptions (`This skill should be used when…`), which contradicts this ecosystem's
  `TRIGGER` / `DO NOT TRIGGER` convention. Shipping it as-is would have the reviewer grade
  skills against a style the school does not use. The house version reviews against local
  convention and weights the description as the trigger lever.

- **Provenance stays honest.** `skill-creator` is genuinely imported and documented as
  such; `skill-reviewer` is credited to the Anthropic agent it derives from but is
  maintained in this repo. Docs must not claim it is `[[imports]]`-vendored.

Future note: do not "fix" this by adding an `[[imports]]` for `skill-reviewer` — it will
not resolve.
