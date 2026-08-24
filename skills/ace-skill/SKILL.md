---
name: ace-skill
description: >
  Author agent skills (SKILL.md files) the house way — a menu of operations up front,
  numbered steps per operation, and an enforcement mechanism (stamp-chain ledger by
  default) that makes readers actually follow the steps. TRIGGER when the user wants to
  create a skill, revise or restructure one, retrofit step enforcement onto one, or
  tighten a skill description's triggering — even if they don't name the skill. DO NOT
  TRIGGER for editing non-skill docs or prose, or for running a skill that exists.
argument-hint: "[skill name or path, and what to do to it]"
---

# ace-skill

Print `## ace-skill` as the first line.

## Why skills are shaped this way

Models under-comply with prose instructions: they skim, skip numbered steps, and mint
their own exemptions. A skill that merely describes good behavior does not produce it.
Every skill is therefore built from three parts:

1. **A menu** — an index at the top of the body listing the operations the skill
   offers, so the reading agent picks a lane instead of skimming the whole file. A
   single-operation skill's "menu" is one sentence naming that operation.
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
| Create a skill       | C1–C5 | no existing skill covers the job                  |
| Revise a skill       | R1–R4 | an existing skill needs new or changed content    |
| Retrofit enforcement | E1–E3 | a skill has steps but nothing binding them        |
| Tune a description   | D1–D3 | a skill under- or over-triggers                   |

## Stamp chain

The chosen operation's steps run as a stamp chain. Read `ace/ledger.md` and follow its
contract: close every step with one emitted stamp; reprint the prior stamp to enter the
named next step, reusing an immediately preceding emission instead of duplicating it;
no skips, exemptions only in the user's verbatim words.

## Create a skill

- **C1. Scope it.** State what the skill does, its trigger and non-trigger cases, and
  who reads it: a weaker model, in fresh context, possibly under a different harness,
  unable to ask follow-ups. Search for an existing skill that already does it, then one
  that nearly does and could be revised; name what you found. Only when both come back
  empty does a new skill get made. Stamp ev: the scope line and the search result;
  next: C2.
- **C2. Frontmatter.** The directory name is the skill's only invocation handle; pick
  it as carefully as an API name. Write the `description` with explicit TRIGGER and DO
  NOT TRIGGER guidance, concrete phrases a user would type, and the `/slash` form —
  within the budget rules of D2. Stamp ev: the description text; next: C3.
- **C3. Body.** Menu first, then numbered steps per operation, then the enforcement
  mechanism binding them. Follow the house style checklist below while drafting, not
  after. Stamp ev: points at the drafted body; next: C4.
- **C4. Wire reachability.** A file the reader is never told to open is dead text:
  every supporting file the skill ships must be explicitly pointed at from the body,
  and every roster that names the school's skill set updates in the same change. Run
  the school's link step (`ace link`) so harnesses pick the skill up. Stamp ev: rosters
  touched and the link command output line; next: C5.
- **C5. Review and land.** Walk the house style checklist against the finished skill;
  fix what fails. Present the result and wait for approval — this is a Wait. Commit
  per the repo's convention. Stamp ev: the user's approving words and the commit hash;
  next: done.

## Revise a skill

- **R1. Read it whole.** The full SKILL.md, its supporting files, and the school's
  house rules — never revise from memory of the skill. Stamp ev: the files read;
  next: R2.
- **R2. Plan the edit.** Smallest diff that lands the change; state the current rule
  only — when a convention replaces an older one, delete what it replaced. Stamp ev:
  points at the edit plan above; next: R3.
- **R3. Apply.** Match the skill's existing structure and voice; keep the menu, steps,
  and enforcement intact — a revision that strips the binding device is a regression.
  Stamp ev: the files edited; next: R4.
- **R4. Review and land.** As C5. Stamp ev: the user's approving words and the commit
  hash; next: done.

## Retrofit enforcement

- **E1. Find the procedure.** The numbered steps, or the implicit sequence hiding in
  prose — number it if it isn't. Stamp ev: the step list found; next: E2.
- **E2. Bind it.** Add a `## Stamp chain` block pointing at `ace/ledger.md`, or the
  better-fitting device from "Why skills are shaped this way". Name any Wait gates
  (steps that need the user's words to cross). Stamp ev: the block added; next: E3.
- **E3. Sweep for escape hatches.** Delete skip vocabulary ("if needed", "optionally",
  "skip if obvious") and any language that lets the reader self-exempt; a genuinely
  optional branch becomes an explicit branch condition instead. Stamp ev: the phrases
  removed; next: done.

## Tune a description

- **D1. Collect cases.** List the phrasings that should trigger the skill and the
  near-misses that shouldn't — adjacent domains, shared keywords, competing skills.
  Stamp ev: points at the two lists above; next: D2.
- **D2. Rewrite within budget.** Every description is resident in context all session,
  for every subscriber, whether the skill fires or not — spend words only where they
  change the trigger decision. Agents under-trigger, so keep the push: concrete
  verbatim phrases, the `/slash` form, an explicit negative boundary, and at most one
  short nudge clause ("even if they don't name it"). Cut restatements of the name,
  duplicate examples, and descriptions of what the body does. Stamp ev: the rewritten
  description; next: D3.
- **D3. Check both failure modes.** Walk D1's lists against the rewrite: every
  should-trigger phrase caught, every near-miss excluded. Stamp ev: one line per list,
  pass/fail; next: done.

## House style checklist

The C5/R4 review gate. Every line must pass:

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
- Steps have a binding mechanism; no skip vocabulary anywhere.
