# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is **ACE Home** — an [ACE](https://github.com/ace-rs/ace) school repo. It is
intended to become the *base* school that other ACE schools inherit from via `[[imports]]`
in their `school.toml`.

A school is a git repo that bundles everything an ACE-managed coding session
needs to behave consistently across projects. Projects subscribe via
`ace setup <school>`; ACE clones the school into a cache and wires it into
each project. There is no build, no tests, no runtime — the contents are
markdown and config that downstream AI sessions read.

A school can ship:

- **Skills** (`skills/<name>/SKILL.md`) — progressively-disclosed instruction
  bundles the AI loads on trigger. Symlinked into each project so edits flow
  back to the school clone.
- **Session prompt** (`school.toml: session_prompt`) — text prepended to every
  session in subscriber projects.
- **Environment variables** (`school.toml: env`) — exported into each session
  shell.
- **MCP server registrations** (`[[mcp]]`) — remote MCP endpoints (URL,
  headers, auth hints) made available to every subscriber.
- **Backend declarations** (`[[backends]]`) — custom invocations of `claude`,
  `codex`, or other backends, selectable via `ace -b <name>`.
- **Imports** (`[[imports]]`) — other schools to inherit from. A school is
  composable: a downstream school can pull skills, MCP entries, and backend
  declarations from one or more upstreams. Wildcards (`skill = "*"`) are
  supported for whole-school inheritance.
- **Conventions and durable docs** (`CLAUDE.md`, `docs/`) — house-style rules
  and project-history artifacts the AI consults during work.

`ace.toml` (per-project) and `~/.config/ace/ace.toml` (per-user) layer on top
of the school's `school.toml` to choose backend, trust mode, session prompt
overrides, MCP allow-list, and which skills to include or exclude.

## Repo layout

- `school.toml` — school metadata (name, session prompt, env vars, MCP servers, imports)
- `ace.toml` — points this project at itself (`school = "."`) so the school can be
  developed using its own skills
- `skills/<name>/SKILL.md` — each skill is a directory with a `SKILL.md` frontmatter file
  describing when it triggers
- [`ACE.md`](ACE.md) — overview of the `ace-*` workflow skills
- [`RTK.md`](RTK.md) — RTK command catalogue (token-optimized shell wrapper)
- `docs/` — durable artifacts about the project (see `docs/README.md` for the
  three sub-homes: `docs/spec/`, `docs/decisions/`, `docs/notes/`)
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

All under `docs/` — three peers, mutually exclusive. Pick by artifact shape:

- `docs/spec/` — forward-looking design specs, RFCs, interface contracts.
  *What we intend to build.*
- `docs/decisions/` — rulings that resolve ambiguity or set a precedent
  future PRs should follow. *What we decided.* Check before proposing
  changes that might conflict.
- `docs/notes/` — research, surveys, drafts, transcripts, exploratory
  write-ups. *What we explored.*

Default for "this might be useful later" is `docs/notes/`. Move to
`docs/decisions/` only if you can name what was decided in one line; to
`docs/spec/` only if it describes intended-to-build behavior.

See `docs/README.md` and the per-dir READMEs for format details.

## RTK — token-optimized command wrapper

This repo uses [RTK](https://github.com/rtk-ai/rtk) ("Rust Token Killer") to compact
noisy command output. **Always prefix shell commands with `rtk`** — `rtk git status`,
`rtk cargo build`, `rtk gh pr view`, etc. RTK falls back to passthrough when no filter
matches, so it's always safe to use.

See [`RTK.md`](RTK.md) for the full command catalogue and savings table.
Project-local filters live in [`.rtk/filters.toml`](.rtk/filters.toml).