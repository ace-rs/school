---
name: ace-school
description: >
  ACE school management — proposing skill changes and creating PRs to the school
  repo. TRIGGER when: user wants to propose changes to skills, create a school PR,
  run `ace diff`, or asks about school structure/workflow — also when `ace school
  pull` fails or the school checkout is dirty. DO NOT TRIGGER for: normal coding tasks
  or project-specific work.
---

# ACE School Management

Print `## ace-school` as the first line.

## What is an ACE school?

A school is a git repo containing skills, conventions, and session prompts shared across
projects. Structure:

- `school.toml` — school metadata (schema below)
- `skills/<name>/SKILL.md` — one directory per skill
- `CLAUDE.md`, `docs/` — house rules and durable record

Projects subscribe via `ace setup`. Run `ace paths school` to locate the authoritative
school repository. A normal subscription stores that checkout in ACE's data dir
(typically `~/.local/share/ace/…`, **not** the cache) and symlinks its `skills/` into the
project.

If `ace.toml` sets `school = "."`, `ace paths school` resolves to the current project.
That checkout is authoritative. Do not edit or synchronize
`~/.local/share/ace/<name>/` or `~/.cache/ace/` unless the user explicitly names those
paths.

## `school.toml` schema

| Field            | Type   | Notes                                                   |
|------------------|--------|---------------------------------------------------------|
| `name`           | string | School display name (required)                          |
| `backend`        | string | Default backend; built-in or a `[[backends]]` name      |
| `session_prompt` | string | Text prepended to every subscriber session              |
| `env`            | map    | Env vars exported into each session shell               |
| `[[mcp]]`        | array  | MCP servers: `name`, `url`, `headers`, `instructions`   |
| `[[projects]]`   | array  | Project metadata: `name`, `repo`, `description`, `env`  |
| `[[imports]]`    | array  | Upstream schools to inherit from (see below)            |
| `[[backends]]`   | array  | Custom backend decls: `name`, `kind`, `cmd`, `env`      |

All fields but `name` are optional and dropped from output when empty.

## Imports & inheritance

A school composes others via `[[imports]]`. Each decl:

| Field                  | Notes                                                         |
|------------------------|---------------------------------------------------------------|
| `source`               | `owner/repo` or URL of the upstream school                    |
| `skills`               | patterns to pull; `"*"` takes the whole school                |
| `skill`                | backcompat singular alias for `skills`; never re-emitted      |
| `exclude_skills`       | patterns to subtract; also silences collision warnings        |
| `include_experimental` | admit the experimental tier (default off)                     |
| `include_system`       | admit the system tier (default off)                           |
| `include_internal`     | admit `internal: true` skills via glob; explicit names bypass |

At least one of `skills`/`skill` must be set. Across decls, **first-wins**: an earlier
decl claims an identity; a later decl matching the same one warns as a collision (silence
it by listing the pattern in the winner's `exclude_skills`).

Imported skills are **copied**, not symlinked, from the import cache
(`~/.cache/ace/imports/`) into the school's `skills/`; re-fetch with `ace school pull`.
(Contrast: a subscribing *project* gets symlinks to its school's `skills/` — a different
mechanism.)

### Check the upstream layout before writing a decl

A `skills` pattern matches only what discovery yields from the source repo. Discovery
runs two stages against the repo root and nothing else:

1. **Single skill.** `<root>/SKILL.md` exists → the repo is one skill, named after the
   root basename. Discovery stops.
2. **Skill dirs**, walked recursively, `SKILL.md` at any depth: `skills/`, plus the
   tier dirs `skills/.curated/`, `skills/.experimental/`, `skills/.system/` (the
   latter two are what `include_experimental` / `include_system` admit). Only when
   all four yield nothing does it fall back to a backend dir: `.claude/skills/`,
   `.codex/skills/`, `.opencode/skills/`, `.cursor/skills/`, `.windsurf/skills/`,
   `.kiro/skills/`, `.agents/skills/`.

A nested `skills/typescript/coding/SKILL.md` yields identity `typescript/coding` —
that full path is what the pattern must match.

There is no whole-repo walk. A repo that keeps each skill as its own directory at the
root — no root `SKILL.md`, no `skills/` — yields zero skills; no pattern reaches it.
A decl that matches nothing is a **warning, not an error**, so an import that pulls
nothing means the source layout is wrong, not the skill name. Do not retry other
import paths — **vendor instead**: copy the skill directory into this school's
`skills/`, keep its license file and attribution, rewrite the frontmatter to house
style, and record where it came from. A vendored skill is maintained by hand —
`ace school pull` does not update it, so check upstream revisions manually.

Full discovery rule: `docs/spec/skills/model.md` § Discovery Cascade in `ace-rs/ace`.

## Skills have no alias

A skill's only invocation handle is its **directory identity** (path/basename) — e.g.
`ace-afk` or `ace/ace-afk`. The frontmatter `name:` is display-only; ACE never matches on
it, and the parser reads only `name` and `description` (any other frontmatter key is
ignored). `/foo` resolves to `skills/foo/`, full stop. A second invocation name means a
second directory, not a frontmatter field.

## `ace` CLI — school-relevant commands

| Command                   | Purpose                                                 |
|---------------------------|---------------------------------------------------------|
| `ace setup <school>`      | Subscribe a project: clone school + wire it in          |
| `ace diff`                | Show uncommitted changes in the school checkout         |
| `ace paths [key]`         | Resolved paths (`school`, `cache`, `project`, …)        |
| `ace import <owner/repo>` | Import skills from another school (`--skill`, `--all`)  |
| `ace school init`         | Scaffold a new school                                   |
| `ace school pull`         | Re-fetch imports (alias: `update`)                      |
| `ace school skills`       | List a school's skills                                  |
| `ace school validate`     | Check school config (alias: `check`)                    |
| `ace skills`              | List/curate active skills (`ls`; `--all`, `--names`)    |
| `ace explain <skill>`     | Show how a skill resolves (provenance + trace)          |
| `ace config`              | Print/get/set config keys                               |
| `ace mcp`                 | Manage MCP server registrations                         |
| `ace fmt`                 | Pretty-print/clean ace.toml & school.toml (`format`)    |

Run school-repository commands from `cd "$(ace paths school)"`.

## Editing skills

`ace paths school` selects the checkout to edit. If it resolves to the current project,
edit that project's `skills/<name>/SKILL.md` directly. Otherwise, project skill files
are symlinks into the resolved checkout, so an edit through one lands there. The
resolved checkout is a real git working copy, branchable and committable.

Keep the resolved checkout clean. A data-dir checkout is shared by every project on the
machine that subscribes to that school, and an uncommitted change there blocks
`ace school pull` for all of them. Finish a skill-editing session with the changes either
proposed upstream (steps below) or reverted. Never park uncommitted changes in the
checkout.

## Stamp chain

The numbered steps in each operation run as a stamp chain. Read `ace/ledger.md` — in the
`ace` skill's directory, sibling to this one — and follow its contract. Proposal step 2
waits for approval; step 10 waits for a checkout selection. The next step quotes the
user's words at either gate.

## Menu

| Operation             | Steps   | Use when                              |
|-----------------------|---------|---------------------------------------|
| Propose changes       | 1–11    | local school edits should become a PR |
| Clean merged proposal | 1–3     | that PR has merged                    |

## Proposing changes

1. **Review diff.** Run `ace diff` to review changes.
2. **Confirm proposal.** Summarize findings — combine the diff output with your own
   context about what changed and why during this session. Present the summary to the user
   and wait for explicit approval before proceeding.
3. **Enter checkout.** Open by quoting the approval. Run
   `cd "$(ace paths school)"` to enter the authoritative school checkout.
4. **Create branch.** Run `git checkout -b ace/{short-description}`.
5. **Commit proposal.** Stage and commit everything that belongs to the proposal.
   Put session context that does not belong in the PR into the project's durable record.
   Do not reset the checkout; cleanliness comes from committing, not discarding work.
6. **Verify branch.** Confirm the proposal branch contains every intended commit and
   the working tree is clean.
7. **Push branch.** Run `git push -u origin {branch}` once the branch is complete.
8. **Create PR.** Create the PR through the repository's configured hosting workflow.
9. **Report PR.** Present the PR title, URL, branch, and current checkout state.
10. **Choose checkout.** Ask whether to retain the proposal branch so subscribing
    projects keep using the fixed skill until merge, or return the checkout to pristine
    main. This is a Wait.
11. **Set checkout.** Open by quoting the user's choice. Retain the proposal branch
    and confirm it is clean, or run `git checkout main` and confirm main is clean.

## Cleaning a merged proposal

1. **Confirm merge.** Verify that the proposal PR merged.
2. **Update main.** Check out main and pull the merged commit.
3. **Delete branch.** Delete the merged local feature branch.

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
- **Honor the school's record-keeping** — if the school keeps a durable record
  (spec dir, notes/research dir, or similar), read prior entries for context before
  proposing changes, and amend it per the school's conventions when the PR resolves
  ambiguity or sets a precedent. Don't assume any specific directory exists — check
  what the school actually has.

## Authoring skills

Load `ace-skill`, read the school's instructions and durable design record, and follow the
operation that matches the change. The school's rules override the base method.
