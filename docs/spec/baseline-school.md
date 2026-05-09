# Baseline school

- **Status:** accepted
- **Slug:** baseline-school

## Purpose

ACE Home is the *baseline* school every ACE setup imports by default. Its job
is to make a freshly-installed ACE useful out of the box — without forcing
opinions that only fit one team or domain.

Concretely, this school exists to ship:

- The official Anthropic `skill-creator` skill (vendored via `[[imports]]`),
  so anyone authoring or revising skills has the canonical workflow loaded
  the moment they need it.
- A small set of `ace-*` helper skills that drive the harness itself:
  workflow orchestration, session checkpoints, recovery, alignment fixes,
  school-PR mechanics, and local agent-to-agent messaging.
- Documentation a new ACE user can read end-to-end in fifteen minutes
  (`README.md`, `ACE.md`, `RTK.md`).

That's the whole charter.

## Out of scope

This school deliberately does **not** ship:

- Language- or framework-specific coding conventions (Rust, Go, Python,
  Typst, frontend, etc.).
- Project-, team-, or org-specific rules (deploy targets, vendor names,
  numeric thresholds, branch policies).
- Opinionated tool choices beyond the harness layer (CI vendor, package
  manager, formatter).

Those belong in **your** school, which imports this one and adds whatever
your team actually needs. That layering is the point: ACE Home stays small
and broadly applicable; downstream schools carry the opinions.

## What ships

`skills/`:

- `ace/` — start/resume the ACE workflow at session boundaries
- `ace-audit/` — recover when a diff landed without passing through audit
- `ace-connect/` — local agent-to-agent bridge over unix sockets
- `ace-realign/` — protocol for re-anchoring drifted attention
- `ace-save/` — persist session state before `/clear` or context switch
- `ace-school/` — manage school edits and PRs
- `skill-creator/` — Anthropic's authoritative skill-authoring skill

Top-level docs: `README.md` (entry point), `ACE.md` (workflow overview),
`RTK.md` (token-optimized shell wrapper guide), `CLAUDE.md` (house style
when editing this school itself).

## Composition

Downstream schools inherit from ACE Home via:

```toml
# downstream school.toml
[[imports]]
skill = "*"
source = "ace-rs/school"
```

A wildcard import pulls every skill ACE Home ships. Downstream schools can
exclude individual skills via `ace.toml: exclude_skills` per-project, or
shadow them by declaring a skill of the same name locally.
