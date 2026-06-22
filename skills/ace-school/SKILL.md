---
name: ace-school
description: >
  ACE school management — proposing skill changes, creating PRs to the school
  repo, and understanding school structure. TRIGGER when: user wants to propose
  changes to skills, create a school PR, run `ace diff`, or asks about school
  structure/workflow. DO NOT TRIGGER for: normal coding tasks or project-specific
  work.
---

# ACE School Management

Print `## ace-school` as the first line.

## What is an ACE school?

A school is a git repo containing skills, conventions, and session prompts shared across
projects. Structure:

- `school.toml` — school metadata (schema below)
- `skills/<name>/SKILL.md` — one directory per skill
- `CLAUDE.md`, `docs/` — house rules and durable record

Projects subscribe via `ace setup`, which clones the school into ACE's data dir (find it
with `ace paths school`; typically `~/.local/share/ace/…`, **not** the cache) and symlinks
`skills/` into the project.

## `school.toml` schema

| Field | Type | Notes |
|-------|------|-------|
| `name` | string | School display name (required) |
| `backend` | string | Default backend; built-in or a `[[backends]]` name |
| `session_prompt` | string | Text prepended to every subscriber session |
| `env` | map | Env vars exported into each session shell |
| `[[mcp]]` | array | MCP servers: `name`, `url`, `headers`, `instructions` |
| `[[projects]]` | array | Project metadata: `name`, `repo`, `description`, `env` |
| `[[imports]]` | array | Upstream schools to inherit from (see below) |
| `[[backends]]` | array | Custom backend decls: `name`, `kind`, `cmd`, `env` |

All fields but `name` are optional and dropped from output when empty.

## Imports & inheritance

A school composes others via `[[imports]]`. Each decl:

| Field | Notes |
|-------|-------|
| `source` | `owner/repo` or URL of the upstream school |
| `skills` | patterns to pull; `"*"` takes the whole school |
| `skill` | backcompat singular alias for `skills`; folded in on load, never re-emitted |
| `exclude_skills` | patterns to subtract; also suppresses collision warnings |
| `include_experimental` / `include_system` | admit those tiers (default off) |
| `include_internal` | admit `internal: true` skills via glob (explicit names bypass) |

At least one of `skills`/`skill` must be set. Across decls, **first-wins**: an earlier
decl claims an identity; a later decl matching the same one warns as a collision (silence
it by listing the pattern in the winner's `exclude_skills`).

Imported skills are **copied**, not symlinked, from the import cache
(`~/.cache/ace/imports/`) into the school's `skills/`; re-fetch with `ace school pull`.
(Contrast: a subscribing *project* gets symlinks to its school's `skills/` — a different
mechanism.)

## Skills have no alias

A skill's only invocation handle is its **directory identity** (path/basename) — e.g.
`ace-afk` or `ace/ace-afk`. The frontmatter `name:` is display-only; ACE never matches on
it, and the parser reads only `name` and `description` (any other frontmatter key is
ignored). `/foo` resolves to `skills/foo/`, full stop. A second invocation name means a
second directory, not a frontmatter field.

## `ace` CLI — school-relevant commands

| Command | Purpose |
|---------|---------|
| `ace setup <school>` | Subscribe a project: clone school + wire it in |
| `ace diff` | Show uncommitted changes in the school clone |
| `ace paths [key]` | Resolved paths (`school`, `cache`, `project`, …) |
| `ace import <owner/repo>` | Import skills from another school (`--skill`, `--all`) |
| `ace school init` | Scaffold a new school |
| `ace school pull` | Re-fetch imports (alias: `update`) |
| `ace school skills` | List a school's skills |
| `ace school validate` | Check school config (alias: `check`) |
| `ace skills` | List/curate active skills (alias: `ls`; `--all`, `--names`) |
| `ace explain <skill>` | Show how a skill resolves (provenance + trace) |
| `ace config` | Print/get/set config keys |
| `ace mcp` | Manage MCP server registrations |
| `ace fmt` | Pretty-print/clean ace.toml & school.toml (alias: `format`) |

Run clone-scoped commands from `cd $(ace paths school)`.

## Editing skills

Skill files in the project are symlinks into the school cache. Edits go directly to the
cache — this is intentional. The school cache is a real git working copy.

## Proposing changes

When skill edits need to go upstream:

1. Run `ace diff` to review changes.
2. Summarize findings — combine the diff output with your own context about what was
   changed and why during this session. Present the summary to the user and wait for
   explicit approval before proceeding.
3. `cd $(ace paths school)` to enter the school cache directory.
4. `git checkout -b ace/{short-description}` — create a feature branch.
5. Stage and commit with a descriptive message.
6. `git push -u origin {branch}` — push to the school remote.
7. Create a PR to the school repo. Use GitHub MCP if available.
8. Do **NOT** reset the cache to main — that destroys uncommitted work across all
   branches.

## Good school PR guidelines

- **One skill or one coherent theme per PR.** Don't mix unrelated skill changes.
- **Title**: imperative, scoped (e.g. "Clarify audit checklist in ace-audit").
- **Body**: what changed, why, which sessions revealed the need.
- **Keep skills generic** — no project-specific content. Skills must work across all
  projects that subscribe to the school.
- **Watch for conflicts** — skill instructions can interact with project `CLAUDE.md` and
  with each other. If a skill contradicts another skill or common project conventions,
  call it out in the PR description.
- **Honor existing conventions** — if issue-creator, PR-creator, or similar skills are
  available in the session, follow their format and guidelines when creating issues or
  PRs.
- **Honor the school's record-keeping** — if the school keeps a decisions log,
  notes/research dir, or similar durable record, read prior entries for context
  before proposing changes and add a new entry per the school's conventions when
  the PR resolves ambiguity or sets a precedent. Don't assume any specific
  directory exists — check what the school actually has.

## Writing good skill content

Anthropic's `skill-creator` skill is the authoritative reference for skill mechanics
(frontmatter, file layout, progressive disclosure, eval loops). The lessons below are
school-specific — things that recur in reviews of PRs to this repo.

0. **Check the school's house rules first.** Before authoring or editing any skill,
   read the school repo's `CLAUDE.md` and any durable record-keeping the school
   maintains (decisions log, notes, research dir — whatever exists) for house-style
   overrides on top of `skill-creator`. Each school may override skill-creator
   differently (tone, structure, imperative-vs-why phrasing, etc.). House rules
   win over skill-creator defaults.

1. **Generic by default.** Strip named repos, clients, deploy targets, and vendor names.
   Use placeholders (`site-web`, `site-cms`, `acme-*`). Project-specific context belongs
   in a downstream `CLAUDE.md`, not in a skill that ships to every subscriber.

2. **Keep concrete examples — just rename them.** LLMs anchor better on examples than on
   pure abstract rules. Don't delete a code block to "make it generic"; swap the names.
   A renamed example is more useful than a rule without an example.

3. **Project-specific numbers as examples, not rules.** "Debounce 30s per project
   convention" is a rule that rots across subscribers; "debounce it — e.g. 30s" is a
   starting point they can adjust. Likewise, specific CI vendors (Buildkite, GitHub
   Actions) should read as "your CI".

4. **Write pushy descriptions.** Claude tends to under-trigger skills. Alongside the
   TRIGGER / DO NOT TRIGGER blocks, include a nudge like "Use this skill whenever X is
   involved, even if the user does not explicitly name it." It matters more than it looks.

5. **Progressive disclosure.** Keep `SKILL.md` under ~500 lines. Push depth into
   `references/*.md` with a quick-map table in `SKILL.md` (task → reference file) so the
   model knows where to look without loading everything upfront.
