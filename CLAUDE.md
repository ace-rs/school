# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

## What this repo is

**ACE Home** — the base [ACE](https://github.com/ace-rs/ace) school that other schools
inherit from via `[[imports]]` in their `school.toml`. [`README.md`](README.md) explains
what a school is and everything one can ship; [`ACE.md`](ACE.md) covers the `ace-*`
workflow skills. Read those rather than restating them here.

There is no build, no tests, no runtime. The contents are markdown and config that
downstream AI sessions read.

## Repo layout

- `school.toml` — school metadata (name, session prompt, env vars, MCP servers, imports)
- `ace.toml` — this project's ACE config (skill selection)
- `skills/<name>/SKILL.md` — one directory per skill; frontmatter declares its triggers
- `.docs/` — the durable design record. **Local only, gitignored.** Read it and write to
  it, but never assume a fresh clone has it. Start at `.docs/README.md` for the routing
  gate, and read `.docs/spec/working-in-this-repo.md` first — it holds the editing rules
  that don't ship publicly.
- `.claude/skills/` etc. — symlinks ACE manages; never edit manually (see `.gitignore`)

## This repo is public

Everything tracked here is world-readable and ships to every downstream school. Nothing
here is secret — the point is proportion: a base school others adopt shouldn't read like
one maintainer's working directory. So keep tracked files pointed outward. Internal wikis
and trackers, machine-specific paths, and real project or org names used as examples all
belong in `.docs/` (gitignored) or nowhere. Prefer placeholder names in examples.

## Editing rules specific to this repo

- Skills must stay **generic**. No project-specific content. Anything authored here will
  ship to every downstream school that imports this one.
- One skill (or one coherent theme) per commit / PR. See `skills/ace-school/SKILL.md` for
  the full PR workflow.
- **Commit prefix is the skill name, not `skills:`.** Almost every edit here touches a
  skill, so `skills:` carries no information — prefix with the skill being changed:
  `ace-connect: fix the opencode bridge`, `ace-audit: tighten the checklist`. Edits
  spanning several skills use a shared theme prefix; non-skill edits scope to their area
  (`docs:`, `meta:` for repo-level files like this one).
- State the current rule only. When a convention replaces an older one, rewrite the rule
  and delete what it replaced — the reasoning belongs in `.docs/decisions/`, not inline
  as "we used to X, now Y."

## Common commands

- `ace config` — print effective configuration
- `ace paths` — resolved filesystem paths for school clone, data dir, etc.
- `ace diff` — review pending skill edits
- `ace import <owner/repo>` — pull in another school as an import
- `ace school pull` — re-fetch imports

## When adding a new skill

1. Create `skills/<name>/SKILL.md` with frontmatter: `name`, `description` (must include
   clear TRIGGER and DO NOT TRIGGER guidance — see existing skills as the pattern).
2. Keep the description tight — it's what the model sees when deciding whether to load
   the skill.
3. Body of `SKILL.md` is the actual instructions loaded on trigger.

## Skill writing house style

Load the `skill-creator` skill first for its workflow guidance when authoring or
revising any skill under `skills/`.

House style overrides skill-creator on one point: **prefer terse imperative rules over
why-clauses.** skill-creator advises explaining the *why* behind each rule; in practice
why-clauses rarely change model behavior — agents skim them. Stick to imperatives, with
reasoning kept to a single framing sentence only when the rule is genuinely non-obvious.

## Durable artifacts

`.docs/` — file by the routing gate in `.docs/README.md`, first match wins: third-party
lookup → `vendor/`; a how-to → `guides/`; our own design/surface → `spec/`; unsettled
exploration → `scratch/` (residual, opened with a "not spec because ___" line). Nothing
defaults to `scratch/`. Everything settled — instructions, conventions, preferences,
rulings — amends `spec/`; the spec is authoritative, so read it before working and comply.
`decisions/` is a pre-existing escape hatch, not a destination. See the per-dir READMEs
for each folder's test and format.
