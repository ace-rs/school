---
name: ace-audit
description: >
  Recovery tool. Re-enters `ace/workflow.md` step 6 when a diff landed without passing
  through it. TRIGGER when: user invokes `/ace-audit` or asks to review, audit, or check
  work against skill compliance.
---

# ACE Audit

Recovery tool. The audit lives in `ace/workflow.md` step 6. Use this when a diff didn't
pass through /ace — ad-hoc edits, late skill loads, drifted work.

## Recovery procedure

1. **Load coding skills for the languages in the diff.** `git diff --name-only` to see
   files. Load each language's coding skill + `general-coding`. Framework skills
   (`prod9-fx`, `p9-infra`) when relevant.

2. **Check for design-level violations before patching.** If the loaded skills surface
   structural issues — missing unit-of-work pattern, nullable fields that should be enums,
   cross-module shared helpers — surface a redesign question to the user. LLM rewrite cost
   is near-zero; sunk-cost reasoning doesn't apply.

3. **Run `ace/workflow.md` step 6.** Audit, categorize, fix, re-audit until clean. Commit
   per `general-coding` commit conventions.
