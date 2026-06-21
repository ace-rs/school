# ace-docs gains a `www/` review-site mode

- **Date:** 2026-06-21
- **PR:** manual (commits 1eaae63..0dccd4d)
- **Status:** accepted

## Decision

`ace-docs` gets a second mode alongside scaffolding: build a human-facing `www/` review
site **synthesized from** `docs/`. Folded into the one skill (not a sibling), with a
shared `docs/` preamble and two parallel sections. Shape:

- **Derived, one-way.** `docs/` is source of truth; `www/` is a downstream rewrite,
  regenerated on drift. Each page carries a provenance header (`<!-- derived from: … @
  <commit> -->`); never edit a page as source.
- **Committed artifact.** `www/` lives in git — the deploy step reads it from committed
  history (`git subtree split --prefix www HEAD` → `gh-pages`), so an uncommitted site
  can't ship. A school's `www/` does **not** propagate to importers (`[[imports]]` pulls
  skills, not top-level folders), so committing it here is safe.
- **Zero build.** Authored HTML fragments + htmx + one stylesheet; nothing compiles.
- **Synthesize, don't mirror.** `docs/` sorts for maintainers (permanence/type); `www/`
  sorts for readers (topic/journey). A 1:1 markdown port is a failure.
- **Design language:** the flat `/visualise` aesthetic (warm, auto light/dark), with Space
  Grotesk/Mono and a single accent. Accent is **brand-overridable**: electric cyan by
  default, but adopt the project's brand color if it has one. A small component vocabulary
  (note/panel/compare/stats/steps/tags/tree/figure) lives in the skill's
  `references/components.md`.

## Rationale

Non-obvious calls and why they went the way they did:

- **No `hx-push-url`.** Nav uses relative `hx-get` with the URL left unchanged. Pushing
  the fragment path rebases the next relative link, so the second nav 404s — and it breaks
  under a gh-pages project base (`/<repo>/`). The cost is a single-URL site (no deep links
  / back-button), acceptable for a review surface.
- **Committed, not throwaway.** First instinct was a "dogfood then revert" rule; that
  contradicted the subtree-push deploy in the same skill, which requires the site in
  history. Derived ≠ ephemeral.
- **`/visualise` language, not ace-terminal.** An ace-rs/www terminal styling was tried
  and reverted — too heavy/branded for a neutral docs scaffold that ships to every
  downstream school. Kept only the fonts and electric cyan from that pass. The accent is a
  token an agent sets per project, so brand fit is one variable.
- **Folded into ace-docs, not a sibling skill.** The site is "another face of docs"; one
  skill keeps structure and presentation evolving together, with the body split into two
  parallel modes for readability.
