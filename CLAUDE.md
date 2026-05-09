# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is **ACE Home** — an [ACE](https://github.com/ace-rs/ace) school repo. It is
intended to become the *base* school that other ACE schools inherit from via `[[imports]]`
in their `school.toml`.

A school is a git repo of shared skills, conventions, and session prompts. Projects
subscribe via `ace setup <school>`; ACE clones the school and symlinks `skills/` into
each project. There is no build, no tests, no runtime — the "code" here is markdown
that downstream AI sessions read.

## Repo layout

- `school.toml` — school metadata (name, session prompt, env vars, MCP servers, imports)
- `ace.toml` — points this project at itself (`school = "."`) so the school can be
  developed using its own skills
- `skills/<name>/SKILL.md` — each skill is a directory with a `SKILL.md` frontmatter file
  describing when it triggers
- [`ACE.md`](ACE.md) — overview of the `ace-*` workflow skills
- [`RTK.md`](RTK.md) — RTK command catalogue (token-optimized shell wrapper)
- `decisions/` — append-only decision log: rulings that resolve ambiguity or set
  a precedent (see `decisions/README.md` for format)
- `notes/` — durable non-decision artifacts: research, surveys, drafts,
  transcripts, exploratory write-ups (see `notes/README.md`)
- `.claude/skills/` etc. — symlinks ACE manages; never edit manually (see `.gitignore`)

## Editing rules specific to this repo

- Because `ace.toml` sets `school = "."`, the `skills/` directory IS the school clone —
  edits land directly in the repo (no symlink indirection like in downstream projects).
- Skills must stay **generic**. No project-specific content. Anything authored here will
  ship to every downstream school that imports this one.
- One skill (or one coherent theme) per commit / PR. See `skills/ace-school/SKILL.md` for
  the full PR workflow.

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

Two homes, mutually exclusive — pick the right one before writing.

- `decisions/` — **decisions only**: rulings during reviews, skill changes, or
  maintenance that resolve ambiguity, pick between alternatives, or set a
  precedent future PRs should follow. Check existing decisions before proposing
  changes that might conflict. Format: `decisions/README.md`.
- `notes/` — everything else worth keeping that isn't a decision: research,
  surveys, drafts, transcripts, exploratory write-ups, feature-request bodies,
  context for future calls. No required template. Format: `notes/README.md`.

Default for "this might be useful later" is `notes/`. Only use `decisions/` if
you can name what was decided in one line.

## RTK — token-optimized command wrapper

This repo uses [RTK](https://github.com/rtk-ai/rtk) ("Rust Token Killer") to compact
noisy command output. **Always prefix shell commands with `rtk`** — `rtk git status`,
`rtk cargo build`, `rtk gh pr view`, etc. RTK falls back to passthrough when no filter
matches, so it's always safe to use.

See [`RTK.md`](RTK.md) for the full command catalogue and savings table.
Project-local filters live in [`.rtk/filters.toml`](.rtk/filters.toml).