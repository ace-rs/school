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
- `ace.toml` — sets `school = "prod9/school"`, so the dev session runs on a stable personal
  editing school rather than this repo's own in-flux skills
- `skills/<name>/SKILL.md` — each skill is a directory with a `SKILL.md` frontmatter file
  describing when it triggers
- [`ACE.md`](ACE.md) — overview of the `ace-*` workflow skills
- `docs/` — durable artifacts about the project (see `docs/README.md`): filed by a
  routing gate across `guides/`, `vendor/`, `spec/`, `decisions/`, `scratch/`
- `.claude/skills/` etc. — symlinks ACE manages; never edit manually (see `.gitignore`)

## Editing rules specific to this repo

- The session's loaded skills come from the `prod9/school` editing school (per `ace.toml`),
  **not** this repo — so editing a `skills/<name>/SKILL.md` here does not change the skill the
  harness already has loaded. To test an edit, read the local `SKILL.md` and follow it
  directly; the `prod9` copy is an older mirror and won't reflect upstream changes.
- Skills must stay **generic**. No project-specific content. Anything authored here will
  ship to every downstream school that imports this one.
- One skill (or one coherent theme) per commit / PR. See `skills/ace-school/SKILL.md` for
  the full PR workflow.
- **Commit prefix is the skill name, not `skills:`.** Almost every edit here touches a
  skill, so `skills:` carries no information — prefix with the skill being changed:
  `ace-connect: fix the opencode bridge`, `ace-audit: tighten the checklist`. Edits
  spanning several skills use a shared theme prefix; non-skill edits scope to their area
  (`docs:`, `meta:` for repo-level files like this one).

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

`docs/` — file by the routing gate in `docs/README.md`, first match wins: a ruling →
`decisions/`; third-party lookup → `vendor/`; a how-to → `guides/`; our own
design/surface → `spec/`; unsettled exploration → `scratch/` (residual, opened with a
"not spec/decision because ___" line). Nothing defaults to `scratch/`. See the per-dir
READMEs for each folder's test and format.

## Command-output compaction — lowfat

Noisy command output is compacted by [lowfat](https://github.com/zdk/lowfat), wired as a
user-scope rewrite hook — no manual prefix, it rewrites transparently and passes through
when no filter matches. Nothing to wire per-repo here: this school is markdown and config,
with no build/test toolchain to filter. Use the `lowfat-pantry` skill to manage filters.