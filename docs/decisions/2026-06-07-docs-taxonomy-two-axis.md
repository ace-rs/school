# docs taxonomy: two-axis hybrid (permanence + type)

- **Date:** 2026-06-07
- **PR:** manual
- **Status:** superseded by [2026-07-09-docs-taxonomy-single-axis-gradient](2026-07-09-docs-taxonomy-single-axis-gradient.md)

## Decision

ace-docs scaffolds five folders in two clusters: **usage** (`guides/`,
`reference/`) sorted by document *type*, and the **design record** (`spec/`,
`decisions/`, `notes/`) sorted by *permanence*. `spec/` broadens to cover
architecture / how-it-works. No `llms.txt`; `CLAUDE.md`/`AGENTS.md` is the agent
index. No `human/` vs `llm/` split.

## Rationale

Each cluster sorts on the axis that actually predicts how you *handle* the file
— permanence for the design record (rewrite freely / freeze-and-date / update in
place), type for usage (a how-to and a lookup table are written and read
differently). Forcing one axis across both is what makes `reference/` feel wrong
next to `notes/`.

Why not the obvious alternatives:

- **Permanence-only** (the prior three-folder shape): structurally missing the
  type/audience axis. Usage and reference aren't permanence variants. Both
  human-doc theory and agent-doc practice classify by type/audience, not
  permanence.
- **Full Diátaxis four-quadrant** (tutorials/how-to/reference/explanation): too
  heavy for a general scaffold — standalone tutorials are rare in repos (empty
  dirs), and it discards the permanence insight that is *canonically correct*
  for ADRs (immutable, supersede-don't-edit). Adopt the type axis, not the rigid
  buckets — explicit Diátaxis adoption is ~4% and quadrants blur in practice.
  `explanation` collapses into `spec/`.
- **Audience split** (`human/` vs `llm/`): duplicates content and rots.
  Convergent practice is single-source docs serving both readers, with
  `CLAUDE.md`/`AGENTS.md` as the agent entry point — Karpathy's "schema
  document" governing an LLM-maintained markdown wiki, which is exactly `docs/` +
  `CLAUDE.md` as already built here.
- **`llms.txt`**: the web standard's real-world adoption is contested; the
  durable part is the *pattern* (a curated markdown index), already served by
  `docs/README.md` + the `CLAUDE.md` pointer.

Full research and citations lived in a scratch note since purged as consumed.
