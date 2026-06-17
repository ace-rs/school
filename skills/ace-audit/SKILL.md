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

## Audit procedure

1. **Load coding skills for the languages in the diff.** `git diff --name-only` to see
   files. Load each language's coding skill, plus any framework or infrastructure coding
   skills relevant to the changed files.

2. **Check for design-level violations before patching.** If the loaded skills surface
   structural issues — a missing transaction/consistency boundary, a stringly-typed field
   that should be an enum, a helper reaching across module boundaries — surface a redesign
   question to the user. LLM rewrite cost is near-zero; sunk-cost reasoning doesn't apply.

3. **Run the `ace/workflow.md` Audit step.** Audit, categorize, fix, re-audit until clean.
   Commit using the repository's existing commit conventions and message format.
