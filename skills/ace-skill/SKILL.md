---
name: ace-skill
description: >
  Create or revise agent skills (SKILL.md files). TRIGGER when the user wants to create,
  revise, or restructure a skill, clarify a procedure, or tune a description's triggering
  — even if they don't name the skill. DO NOT TRIGGER for editing non-skill docs or prose,
  or for running a skill that exists.
argument-hint: "[skill name or path, and what to do to it]"
---

# ace-skill

Print `## ace-skill` as the first line.

## Structure

Build every skill from three parts:

1. **A menu** — an index before the operational detail listing the operations the skill
   offers, so the reading agent picks a lane instead of skimming the whole file. One brief
   framing section may precede it. A single-operation skill's "menu" is one sentence
   naming that operation.
2. **Numbered phases** — each operation is a readable procedure grouped around meaningful
   outcomes and the evidence that proves each phase completed.
3. **A completion contract** — evidence that proves the procedure ran and explicit Wait
   gates where the user's words are required. Point to `ace/ledger.md` when its shared
   evidence rules fit; use a more specific artifact or gate when they do not.

## Menu

| Operation           | Steps | Use when                                          |
|---------------------|-------|---------------------------------------------------|
| Create a skill      | C1–C6 | no existing skill covers the job                  |
| Revise a skill      | R1–R5 | an existing skill needs new or changed content    |
| Clarify a procedure | E1–E5 | steps lack evidence, branches, or explicit gates  |
| Tune a description  | D1–D5 | a skill under- or over-triggers                   |

## Procedure evidence

Read `ace/ledger.md` and follow its contract. Run the chosen operation in order. Keep the
review result and any required user authorization as evidence; do not print per-step
markers.

## Create a skill

- **C1. Scope.** State what the skill does, its trigger and non-trigger cases, and
  who reads it: a weaker model, in fresh context, possibly under a different harness,
  unable to ask follow-ups. Search for an existing skill that already does it, then one
  that nearly does and could be revised; name what you found. Only when both come back
  empty does a new skill get made.
- **C2. Write frontmatter.** The directory name is the skill's only invocation handle;
  pick it as carefully as an API name. Write the `description` with explicit TRIGGER and
  DO NOT TRIGGER guidance and concrete phrases a user would type, within D2's budget.
- **C3. Write body.** Put the framing before the menu only when it teaches the operating
  model. Put the menu before all operational detail. State the completion contract next,
  then write the numbered operations. Follow the house style checklist while drafting.
- **C4. Wire reachability.** A file the reader is never told to open is dead text:
  every supporting file the skill ships must be explicitly pointed at from the body,
  and every roster that names the school's skill set updates in the same change. Run
  the school's link step (`ace link`) so harnesses pick the skill up.
- **C5. Review.** Walk the house style checklist against the finished skill and fix every
  failure. Present the result and wait for approval. This is a Wait; the approval opens
  C6.
- **C6. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## Revise a skill

- **R1. Read whole.** Read the full `SKILL.md`, its supporting files, and the school's
  house rules. Never revise from memory.
- **R2. Bound scope.** Keep the revision bounded to the requested concern. Restructure
  freely inside that scope when the existing shape would not be chosen today. State the
  current rule only; delete the convention it replaces.
- **R3. Apply.** Match the skill's voice. Preserve or improve its menu, steps, completion
  evidence, and explicit Wait gates.
- **R4. Review.** Walk the house style checklist, fix every failure, present the result,
  and wait for approval. This is a Wait; the approval opens R5.
- **R5. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## Clarify a procedure

- **E1. Find procedure.** Find the numbered steps or the implicit sequence in prose.
  Number an implicit sequence and group related actions into readable phases.
- **E2. Bind.** Add a completion-evidence block pointing at `ace/ledger.md`, or a more
  specific evidence artifact or gate. Name every Wait gate
  whose next step requires the user's words.
- **E3. Clarify branches.** State when each conditional branch applies and what evidence
  completes each phase. Keep required user gates explicit.
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
- Numbered phases are concise, bolded, and organized around clear completion criteria.
- Steps have completion evidence and explicit Wait gates; branches state their condition.
