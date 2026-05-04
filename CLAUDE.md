# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is **ACE Home** — an [ACE](https://github.com/prod9/ace) school repo. It is
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
