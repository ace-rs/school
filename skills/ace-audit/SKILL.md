---
name: ace-audit
description: >
  Recovery tool. Re-enters the audit step in `ace/workflow.md` when a diff landed
  without passing through it. TRIGGER when: user invokes `/ace-audit` or asks to review,
  audit, or check work against skill compliance.
---

# ACE Audit

Recovery tool. The audit lives in `ace/workflow.md` as the `Audit` step. Use this when
a diff didn't pass through /ace — ad-hoc edits, late skill loads, drifted work.

## Recovery procedure

1. **Load coding skills for the languages in the diff.** `git diff --name-only` to see
   files. Load each language's coding skill. Framework skills (`prod9-fx`, `p9-infra`)
   when relevant.

2. **Check for design-level violations before patching.** If the loaded skills surface
   structural issues — missing unit-of-work pattern, nullable fields that should be enums,
   cross-module shared helpers — surface a redesign question to the user. LLM rewrite cost
   is near-zero; sunk-cost reasoning doesn't apply.

3. **Run the `ace/workflow.md` Audit step.** Audit, categorize, fix, re-audit until clean.
   Commit using the repository's existing commit conventions and message format.
