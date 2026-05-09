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

## What is an ACE school?

A school is a git repo containing skills, conventions, and session prompts shared across
projects. Structure:

- `school.toml` — school metadata, session prompt, imports, services, MCP servers
- `skills/` — skill directories, each with a `SKILL.md`

Projects subscribe via `ace setup`, which clones the school into a local cache
(`~/.cache/ace/…`) and symlinks `skills/` into the project.

## Editing skills

Skill files in the project are symlinks into the school cache. Edits go directly to the cache —
this is intentional. The school cache is a real git working copy.

## Proposing changes

When skill edits need to go upstream:

1. Run `ace diff` to review changes.
2. Summarize findings — combine the diff output with your own context about what was changed
   and why during this session. Present the summary to the user and wait for explicit approval
   before proceeding.
3. `cd $(ace paths school)` to enter the school cache directory.
4. `git checkout -b ace/{short-description}` — create a feature branch.
5. Stage and commit with a descriptive message.
6. `git push -u origin {branch}` — push to the school remote.
7. Create a PR to the school repo. Use GitHub MCP if available.
8. Do **NOT** reset the cache to main — that destroys uncommitted work across all branches.

## Good school PR guidelines

- **One skill or one coherent theme per PR.** Don't mix unrelated skill changes.
- **Title**: imperative, scoped (e.g. "Add self-audit checklist to general-coding").
- **Body**: what changed, why, which sessions revealed the need.
- **Keep skills generic** — no project-specific content. Skills must work across all projects
  that subscribe to the school.
- **Watch for conflicts** — skill instructions can interact with project `CLAUDE.md` and with
  each other. If a skill contradicts another skill or common project conventions, call it out
  in the PR description.
- **Honor existing conventions** — if issue-creator, PR-creator, or similar skills are
  available in the session, follow their format and guidelines when creating issues or PRs.
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
   Use placeholders (`site-web`, `site-cms`, `acme-*`). Project-specific context belongs in
   a downstream `CLAUDE.md`, not in a skill that ships to every subscriber.

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
