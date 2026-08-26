---
name: ace-skill
description: >
  Create or revise agent skills (SKILL.md files). TRIGGER when the user wants to create,
  revise, or restructure a skill, retrofit step enforcement, or tune a description's
  triggering — even if they don't name the skill. DO NOT TRIGGER for editing non-skill
  docs or prose, or for running a skill that exists.
argument-hint: "[skill name or path, and what to do to it]"
---

# ace-skill

Print `## ace-skill` as the first line.

## Why skills are shaped this way

Models under-comply with prose instructions: they skim, skip numbered steps, and mint
their own exemptions. A skill that merely describes good behavior does not produce it.
Every skill is therefore built from three parts:

1. **A menu** — an index before the operational detail listing the operations the skill
   offers, so the reading agent picks a lane instead of skimming the whole file. One brief
   framing section may precede it. A single-operation skill's "menu" is one sentence
   naming that operation.
2. **Numbered steps** — each operation is a numbered procedure: one concrete action per
   step, plus the evidence that proves the step ran.
3. **An enforcement mechanism** — something that binds the steps. Default: the stamp
   chain in `ace/ledger.md` (in the `ace` skill's directory, sibling to this one),
   adopted with a short `## Stamp chain` block pointing there. Where a chain doesn't fit,
   pick another binding device: a print-first marker line, a verbatim block the agent
   must fill in, a gate that only opens by quoting the user's words. "The agent will
   just do it" is not a mechanism.

## Menu

| Operation            | Steps | Use when                                          |
|----------------------|-------|---------------------------------------------------|
| Create a skill       | C1–C6 | no existing skill covers the job                  |
| Revise a skill       | R1–R5 | an existing skill needs new or changed content    |
| Retrofit enforcement | E1–E5 | a skill has steps but nothing binding them        |
| Tune a description   | D1–D5 | a skill under- or over-triggers                   |

## Stamp chain

The chosen operation's steps run as a stamp chain. Read `ace/ledger.md` and follow its
contract. The numbered prefix names the stamp, the following prefix supplies `next:`, and
the action's decisive result supplies `ev:`. Close every step with one emitted stamp;
reprint the prior stamp to enter the named next step, reusing an immediately preceding
emission instead of duplicating it. No skips; exemptions require the user's verbatim words.

## Create a skill

- **C1. Scope.** State what the skill does, its trigger and non-trigger cases, and
  who reads it: a weaker model, in fresh context, possibly under a different harness,
  unable to ask follow-ups. Search for an existing skill that already does it, then one
  that nearly does and could be revised; name what you found. Only when both come back
  empty does a new skill get made.
- **C2. Write frontmatter.** The directory name is the skill's only invocation handle; pick
  it as carefully as an API name. Write the `description` with explicit TRIGGER and DO
  NOT TRIGGER guidance and concrete phrases a user would type, within D2's budget.
- **C3. Write body.** Put the framing before the menu only when it teaches the operating
  model. Put the menu before all operational detail. State shared enforcement next, then
  write the numbered operations. Follow the house style checklist while drafting.
- **C4. Wire reachability.** A file the reader is never told to open is dead text:
  every supporting file the skill ships must be explicitly pointed at from the body,
  and every roster that names the school's skill set updates in the same change. Run
  the school's link step (`ace link`) so harnesses pick the skill up.
- **C5. Review.** Walk the house style checklist against the finished skill and fix every
  failure. Present the result and wait for approval. This is a Wait; the approval opens C6.
- **C6. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## Revise a skill

- **R1. Read whole.** Read the full `SKILL.md`, its supporting files, and the school's
  house rules. Never revise from memory.
- **R2. Bound scope.** Keep the revision bounded to the requested concern. Restructure
  freely inside that scope when the existing shape would not be chosen today. State the
  current rule only; delete the convention it replaces.
- **R3. Apply.** Match the skill's voice. Preserve or improve its menu, steps, and binding
  mechanism; stripping the enforcement is a regression.
- **R4. Review.** Walk the house style checklist, fix every failure, present the result,
  and wait for approval. This is a Wait; the approval opens R5.
- **R5. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## Retrofit enforcement

- **E1. Find procedure.** Find the numbered steps or the implicit sequence hiding in
  prose. Number an implicit sequence.
- **E2. Bind.** Add a `## Stamp chain` block pointing at `ace/ledger.md`, or the
  better-fitting device from "Why skills are shaped this way". Name any Wait gates
  whose steps need the user's words to cross.
- **E3. Remove escape hatches.** Delete skip vocabulary ("if needed", "optionally",
  "skip if obvious") and any language that lets the reader self-exempt; a genuinely
  optional branch becomes an explicit branch condition instead.
- **E4. Review.** Walk the house style checklist, fix every failure, present the result,
  and wait for approval. This is a Wait; the approval opens E5.
- **E5. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## Tune a description

- **D1. Collect cases.** List the phrasings that should trigger the skill and the
  near-misses that should not: adjacent domains, shared keywords, and competing skills.
- **D2. Rewrite within budget.** Every description is resident in context all session,
  for every subscriber, whether the skill fires or not — spend words only where they
  change the trigger decision. Agents under-trigger, so keep the push: concrete
  natural-language phrases, an explicit negative boundary, and at most one short nudge
  clause ("even if they don't name it"). Explicit invocation syntax belongs only when it
  changes the trigger decision for the supported harnesses. Cut restatements of the name,
  duplicate examples, and descriptions of what the body does.
- **D3. Check failure modes.** Walk D1's lists against the rewrite: every should-trigger
  phrase is caught and every near-miss excluded.
- **D4. Review.** Walk the house style checklist, fix every failure, present the result,
  and wait for approval. This is a Wait; the approval opens D5.
- **D5. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## House style checklist

The review step in every operation. Every line must pass:

- Imperative rules, not why-clauses; at most one framing sentence where a rule is
  genuinely non-obvious.
- Written for a weaker model in fresh context: short sentences, concrete nouns,
  explicit file paths and commands, branch conditions stated outright.
- No self-talk: nothing about how the text came to be, no reference to a conversation
  or a prior version. The text stands alone or it fails.
- Generic: placeholder names in examples; project-specific numbers as examples ("e.g.
  30s"), never as rules.
- Reachability: every shipped supporting file is explicitly pointed at from text that
  loads; a rule that must govern ongoing sessions ships as a placeable block — exact
  text, fenced, with its destination path — for the target repo's own loaded surface
  (`CLAUDE.md` / `AGENTS.md`), because a skill body is absent from every session where
  the skill didn't trigger.
- A brief rationale may precede the menu; the menu precedes operational detail.
- Numbered prefixes are concise, bolded, and single-action; split any prefix that needs
  `and`.
- Steps have a binding mechanism; no skip vocabulary anywhere.
