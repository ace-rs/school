---
name: ace-audit
description: >
  Re-enters the audit step in `ace/workflow.md` — as recovery when a diff landed
  without passing through it, or standalone to re-audit a large body of already-landed
  work and maximize quality. TRIGGER when: user invokes `/ace-audit` or asks to review,
  audit, or check work against skill compliance. DO NOT TRIGGER for the normal in-`/ace`
  audit step (the workflow runs it), routine coding, or when there's no landed diff or
  body of work to review.
---

# ACE Audit

Print `## ace-audit` as the first line.

The audit lives in `ace/workflow.md` as the `Audit` step. Two ways in:

- **Recovery** — a diff didn't pass through `/ace` (ad-hoc edits, late skill loads,
  drifted work) and needs the audit it skipped.
- **Standalone quality pass** — deliberately re-audit a large body of work that
  already landed, to catch issues and maximize quality even though nothing slipped.

## Stamp chain

The numbered steps below run as a stamp chain. Read `ace/ledger.md` — in the `ace`
skill's directory, sibling to this one — and follow its contract: close every step with
its one-line stamp, open the next by reprinting it, no skips, exemptions only in the
user's verbatim words.

## Audit procedure

1. **Load the skills that govern what changed.** `git diff --name-only` to see the files,
   then branch on what they are:

   - **Code** — load each language's coding skill, plus any framework or infrastructure
     skill relevant to the changed files.
   - **Skills (`skills/<name>/SKILL.md`)** — load `ace-skill` if the session has it;
     its house style checklist is the review gate.
   - **Docs, config, or anything else** — audit against the repo's own instructions file
     (`CLAUDE.md` / `AGENTS.md`) and the conventions it points at.

   Never skip this step because no language skill fits; every diff has a governing
   surface.

2. **Check for design-level violations before patching.** If the loaded skills surface
   structural issues — a missing transaction/consistency boundary, a stringly-typed field
   that should be an enum, a helper reaching across module boundaries — surface a redesign
   question to the user. LLM rewrite cost is near-zero; sunk-cost reasoning doesn't apply.

3. **Run the `ace/workflow.md` Audit step.** Audit, categorize, fix, re-audit until clean.
   Commit using the repository's existing commit conventions and message format.
