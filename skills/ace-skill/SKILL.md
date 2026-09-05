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

Give every skill three parts:

1. **A menu** before operational detail. List each operation and when to use it. One brief
   framing section may precede the menu. For a single operation, use one sentence.
2. **Numbered phases** that are concise, bolded, and grouped around meaningful outcomes.
3. **A completion contract** with evidence, explicit branch conditions, and Wait gates
   where the user's words are required. Point to `ace/ledger.md` when its rules fit.

## Menu

| Operation           | Steps | Use when                                         |
|---------------------|-------|--------------------------------------------------|
| Create a skill      | C1–C3 | no existing skill covers the job                 |
| Revise a skill      | R1–R2 | changes span areas or affect other content       |
| Clarify a procedure | E1–E3 | only steps, branches, evidence, or gates change  |
| Tune a description  | D1–D3 | only the frontmatter description changes         |

Every operation ends with F1–F2. For an existing skill, use the most specific matching
operation. Use **Revise a skill** when a request combines description, procedure, or
other content changes.

Run P1–P2, the chosen operation, then F1–F2. Follow `ace/ledger.md`. Keep the review
result and required user authorization as evidence. Do not print per-step markers.

## Prepare

- **P1. Read the rules.** Read the target school's loaded instructions, any skill-writing
  rules they point to, and `ace/ledger.md`.
- **P2. Read or search.** For an existing skill, read its entire `SKILL.md` and all its
  supporting instruction files. For a new skill, search for one that already covers the
  job, then one that nearly does and could be revised. Name what the search found. If one
  is suitable, switch to the matching existing-skill operation and read it in full. Create
  a skill only when neither search finds a suitable home.

## Create a skill

- **C1. Scope.** State what the skill does, its trigger and non-trigger cases, and who
  reads it: a weaker model in fresh context, possibly under a different harness, unable
  to ask follow-ups.
- **C2. Write frontmatter.** The directory name is the skill's only invocation handle;
  pick it as carefully as an API name. Write the `description` with explicit TRIGGER and
  DO NOT TRIGGER guidance and concrete phrases a user would type, within D2's budget.
- **C3. Write and connect.** Apply **Structure**. Point to every supporting file from text
  the reader will load. Update every roster that names the school's skills, then run the
  school's link step (`ace link`).

## Revise a skill

- **R1. Bound scope.** Keep the revision bounded to the requested concern. Restructure
  freely inside that scope when the existing shape would not be chosen today. State the
  current rule only; delete the convention it replaces.
- **R2. Apply.** Match the skill's voice. Preserve or improve its menu, steps, completion
  evidence, and explicit Wait gates.

## Clarify a procedure

- **E1. Find procedure.** Find the numbered steps or the implicit sequence in prose.
  Number an implicit sequence and group related actions into readable phases.
- **E2. Define completion.** Add a completion-evidence block pointing at
  `ace/ledger.md`, or name a more specific artifact or gate. Mark every Wait whose next
  step requires the user's words.
- **E3. Clarify branches.** State when each conditional branch applies and what evidence
  completes each phase. Keep required user gates explicit.

## Tune a description

- **D1. Collect cases.** List the phrasings that should trigger the skill and the
  near-misses that should not: adjacent domains, shared keywords, and competing skills.
- **D2. Rewrite within budget.** Descriptions stay in context for the full session. Keep
  concrete user phrases, an explicit negative boundary, and at most one short nudge such
  as "even if they don't name it." Include invocation syntax only when it changes the
  trigger decision. Cut name restatements, duplicate examples, and body summaries.
- **D3. Check failure modes.** Check the rewrite against D1's lists: every should-trigger
  phrase is caught and every near-miss excluded.

## Finish

- **F1. Review.** Fix every house style failure. Read the draft as its target reader for a
  normal request, a missing prerequisite, and any applicable instruction conflict. For
  each case, identify the loaded text, selected branch, required action, and completion
  evidence. Fix ambiguity and unreachable text. Treat these as textual checks, not
  evidence of model behavior. Present the result and wait for approval. This is a Wait;
  the approval opens F2.
- **F2. Commit.** Open by quoting the user's approval. Commit the reviewed files using the
  repository's convention. End with the commit hash and subject as evidence.

## House style checklist

Use this checklist during F1. Fix every failure:

- The skill follows the three requirements under **Structure**.
- Imperative rules, not why-clauses; at most one framing sentence where a rule is
  genuinely non-obvious.
- Written for a weaker model in fresh context: short sentences, concrete nouns,
  explicit file paths and commands.
- No self-talk: omit the authoring process, conversation, and prior versions. Make every
  sentence stand alone.
- Generic: placeholder names in examples; project-specific numbers as examples ("e.g.
  30s"), never as rules.
- Reachability: point to every supporting file from text the reader will load. For a rule
  that must govern ongoing sessions, provide its exact text in a fenced block and instruct
  the agent to copy it into the target repo's `CLAUDE.md` or `AGENTS.md`.
