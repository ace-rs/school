---
name: skill-reviewer
description: >
  Review an existing skill for quality and triggering accuracy, then propose concrete
  fixes. TRIGGER on `/skill-reviewer`, "review my skill", "check this skill", "is this
  skill's description good", "will this skill trigger", "audit this SKILL.md", or right
  after a skill is created or edited. DO NOT TRIGGER for authoring a skill from scratch or
  running skill evals (that is skill-creator), for reviewing non-skill code or prose, or
  for general code review.
---

# Skill Reviewer

Review one skill and return ranked, actionable fixes. The description is the highest-value
target — it is the only text evaluated when the model decides whether to load the skill.

## Read first

- Locate the `SKILL.md`; ask for the path if ambiguous.
- Read the frontmatter and the full body.
- List supporting dirs (`references/`, `scripts/`, `assets/`, `agents/`) and skim them.
- Read two or three sibling skills in the same repo to learn the local convention — match
  it, do not impose a generic one.

## Description — weight this most

The description is `name` plus one block, and it is the whole trigger surface. Check:

- **Concrete trigger cues.** Verbatim phrases a user would actually type, plus the
  `/slash-command` form. Vague paraphrase ("when working with X") does not fire reliably.
- **Explicit negative boundary.** A clause that fences off the nearest neighbor skills, so
  overlapping skills do not both fire or both stay silent.
- **Disambiguation.** If another skill covers adjacent ground, name it and draw the line.
- **Length.** Enough to carry triggers and boundaries; not padded with body content.

Follow the repo's own description convention. If siblings use `TRIGGER` / `DO NOT TRIGGER`,
use that — do not rewrite toward a different house style.

## Structure

- Valid YAML frontmatter between `---`, with `name` and `description`.
- `name` matches the directory — that path is the invocation handle; frontmatter `name` is
  display-only.
- Body present and substantive.

## Body quality

- **Terse imperatives**, not why-clauses. State the rule; add reasoning only when the rule
  is genuinely non-obvious, kept to one framing sentence.
- **Lean.** Push detail (long references, schemas, examples, scripts) out of `SKILL.md`
  into supporting dirs; the core stays scannable.
- **No self-talk** — no first-person process narration, no hedging.
- **Generic where the repo requires it.** In a shared or base school, flag any project-,
  team-, or tool-specific content that would leak to downstream schools.

## Output

Report findings ranked most-severe first. For each:

- One-line statement of the defect.
- Severity: blocker / major / minor.
- A concrete fix — for descriptions, a before/after rewrite.

Lead with the description findings. End with the single highest-leverage change.
