# Pending: ace-school 90-col reflow — 2026-06-18

`skills/ace-school/SKILL.md` carries pre-existing prose lines over the 90-col house limit,
untouched by the 2026-06-18 drift expansion (commit 87b6f6b) — left out of scope to keep
that diff focused on content, not reflow.

Offending lines at time of writing (re-check, line numbers drift): 95, 103, 104, 111, 118,
120, 121, 124, 145. All prose (table rows are exempt — unwrappable).

Quick re-scan: `awk 'length>90' skills/ace-school/SKILL.md`. Reflow as a standalone
formatting-only commit; don't bundle with content changes.
