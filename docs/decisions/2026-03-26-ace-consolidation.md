# Consolidate ace-recall/ace-go/ace-wrap into ace/ace-save
- **Date:** 2026-03-26
- **PR:** manual
- **Status:** accepted

## Decision
Replace three skills (ace-recall, ace-go, ace-wrap) with two (ace, ace-save)
and a shared workflow.md file.

## Rationale
The three-skill loop (recall → go → compact → recall) loaded ~228 lines of
skill text per session cycle. Most was duplicated workflow rules. Consolidation
reduces to ~85 lines (~63% reduction), eliminates forced per-task compaction,
and moves shared rules (storage cascade, edit protocol, self-audit, commit
discipline) into `skills/ace/workflow.md` loaded once via Read tool.

- `ace-recall` + `ace-go` → `ace` (start/resume work, implement, audit, commit)
- `ace-wrap` → `ace-save` (persist state before compaction or session exit)
- `workflow.md` — shared rules both skills reference
