# Polish commit stays separate from feature commit

- **Date:** 2026-04-21
- **PR:** #33
- **Status:** revised (2026-04-28: step reference renamed after workflow renumbering)

## Decision

Post-audit polish commits must stay separate from the feature commit they polish, and must
not be `--amend`-ed into the original. The rule lives in `general-coding/SKILL.md` (Git
section). `ace/workflow.md` and `ace-audit/SKILL.md` defer to it rather than redefining.

## Rationale

Came up reviewing PR #33 (ace-audit skill). The audit workflow produces a specific shape of
history: feature lands, reviewer finds issues, fixes go in. Amending the feature commit hides
what originally landed versus what was corrected — future readers can't distinguish "this was
the feature as designed" from "this was a fix we caught in review." The review trail is only
useful when those stay separately addressable.

The rule is cross-project (applies to any repo subscribing to this school), so it belongs in
`general-coding`, not `ace/workflow.md`. Workflow.md and ace-audit reference the convention
rather than restating it.

Placement choices considered:
- **`general-coding` Git section (chosen):** cross-project scope, canonical home for commit
  conventions alongside existing rules (force-push, destructive rewrites, verify-before-commit).
- **`ace/workflow.md` Commit step:** rejected — the rule applies outside /ace flow too (e.g. any
  review-then-polish cycle, with or without ace-audit).
- **`ace-audit` only:** rejected — ace-audit is a recovery tool; it shouldn't own the
  canonical rule. Referencing general-coding is enough.
