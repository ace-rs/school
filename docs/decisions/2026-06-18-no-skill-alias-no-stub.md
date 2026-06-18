# Skills get no alias; no stub-skill workaround

- **Date:** 2026-06-18
- **PR:** manual (commit 87b6f6b)
- **Status:** accepted

## Decision

A skill's only invocation handle is its directory identity (path/basename). ACE exposes no
alias mechanism, and we will **not** manufacture one with a thin stub skill (a second
directory that forwards to the real skill) to give a skill a second slash name.

Surfaced while drafting `ace-afk`: the parked question was whether `/ace-afk` could carry
a "nightshift" alias natively or via a stub. Resolved — neither. `ace-afk` is the handle;
"nightshift" lives only as a description trigger word, which already routes the model to
the skill without any alias.

## Rationale

- **The source only matches on identity.** `skill_meta.rs` parses just `name` and
  `description`; the frontmatter `name:` is display-only and never consulted when
  resolving an invocation (`skills/mod.rs:151-152`, ACE decision
  `2026-06-01-skill-name-is-path.md`). An `alias:` field would be silently ignored. So a
  native alias is not "unsupported pending work" — it is a source-level design choice we
  inherit.

- **A stub skill is the banned kind of indirection.** Adding `skills/nightshift/` whose
  only job is to point at `ace-afk` splits one skill across two directories, doubles the
  maintenance surface, and hides the real skill behind a redirect — magic at the layer
  that should stay traceable. Description-based triggering already covers the
  evocative-word case with zero indirection.

- **Second name ⇒ second real skill, or nothing.** If a distinct invocation ever
  genuinely warrants its own directory, it should be a real skill with its own body, not a
  forwarder.

Documented in `skills/ace-school/SKILL.md` § "Skills have no alias".
