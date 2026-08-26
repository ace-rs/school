# ACE Home

The baseline school for [ACE](https://ace-rs.dev) — the foundation every
other school inherits from.

> ACE is a thin coding harness on top of Claude Code, Codex, OpenCode, and
> friends. It wires shared skills, conventions, MCP servers, and session
> prompts into every project so your AI sessions all start from the same
> ground. **Schools** are how that shared ground is distributed.

For installation, the latest releases, and the full feature catalogue, see
[ace-rs.dev](https://ace-rs.dev) — everything below assumes the `ace` CLI is
already on your path. This README focuses on what ACE Home specifically ships
and how to use it.

## What is a school?

A school is a git repo that bundles everything an ACE-managed coding session
needs to behave consistently across projects. A school can ship:

- **Skills** — progressively-disclosed instruction bundles the AI loads on
  trigger.
- **Session prompt** — text prepended to every session.
- **MCP servers** — remote endpoints (URL, headers, auth hints) wired into
  every subscriber.
- **Backend declarations** — pre-rolled invocations of `claude`, `codex`,
  `opencode`, etc., selectable via `ace -b <name>`.
- **Imports** — other schools to inherit from. Schools compose; a downstream
  school can pull skills, MCP entries, and backends from one or more
  upstreams.
- **Conventions** — house-style rules and durable docs the AI reads during
  work.

ACE Home is the *baseline*: it ships the small set of skills required to make
ACE itself useful, including `ace-skill` for authoring skills in house style —
menu-first structure, numbered steps, and an enforcement mechanism that makes
agents actually follow them.
Anything team- or project-specific belongs in your school, not here — import this one and
layer your own skills on top.

## What lives here

Ten skills, all loaded by default for any school that imports this one:

| Skill         | What it does                                             |
| ------------- | -------------------------------------------------------- |
| `ace`         | Start or resume the ACE workflow at session boundaries   |
| `ace-afk`     | Unattended autonomous mode inside a safety envelope      |
| `ace-audit`   | Audit landed work — recovery or standalone quality pass  |
| `ace-connect` | Local agent-to-agent bridge over unix sockets            |
| `ace-docs`    | Scaffold a `docs/` tree routed by a single gate          |
| `ace-init`    | One-time onboarding of a repo into ACE                   |
| `ace-realign` | Repeat a rule you keep breaking until it sticks          |
| `ace-save`    | Persist session state before `/clear` or context switch  |
| `ace-school`  | Manage school edits and PRs                              |
| `ace-skill`   | Author or revise a skill in house style                  |

You don't have to take all ten. Skill selection is managed by the `ace` CLI
— `ace skills include <pat>` / `ace skills exclude <pat>`, or the `skills`
array in `ace.toml` — so a project can narrow the set without forking the
school. Declaring a skill of the same name in your own school shadows the one
here. See [ace-rs.dev](https://ace-rs.dev) for the full CLI reference.

Top-level docs:

- [`ACE.md`](ACE.md) — what each `ace-*` skill is for, by the problem it solves
- [`CLAUDE.md`](CLAUDE.md) — house style when editing this school itself

## Quick start

In an existing project:

```sh
ace setup ace-rs/school
ace
```

`ace setup` clones the school into a local cache, symlinks `skills/` into
the project, and writes `ace.toml`. `ace` launches the configured backend
(Claude Code by default) with the school's skills, session prompt, and
MCP servers wired in.

To start your own team school that inherits from this one:

```sh
ace school init --name your-school
ace setup .                       # self-import: load this school's skills while editing
```

`ace setup .` is convenient but couples the editing session to the skills being
edited — a half-saved skill can break the session doing the editing. Once your
school has skills you actively rewrite, point `school` at a stable clone
instead and test edits by reading the local `SKILL.md` directly.

Then add an import to `school.toml`:

```toml
[[imports]]
skill = "*"
source = "ace-rs/school"
```

`ace school pull` to fetch. Push that repo to a remote and point your
projects at it (`ace setup <your-org>/<your-school>`).

## Switching backends

ACE supports multiple backends. The built-ins are `claude` (Claude Code) and
`codex` (OpenAI Codex CLI); custom backends live in `school.toml` under
`[[backends]]` and can wrap anything that takes the same general shape
(OpenCode, droid, etc.).

The reason to switch through `ace` rather than launching the tool directly:
your school comes with you. Skills, MCP servers, session prompt, and
conventions are wired in by ACE, not by the backend, so the same set is live
whichever one you run. That makes the choice a per-task one — reach for a
different model when it suits the work, or when one is rate-limited — with no
per-tool configuration to keep in sync and nothing to re-teach on arrival.

Switch for one invocation:

```sh
ace --backend codex           # or: ace -b codex
ace --codex                   # shortcut for the built-in
```

Persist the choice for this project:

```sh
ace config set backend codex
```

Or edit `ace.toml` directly:

```toml
backend = "codex"
```

`ace.toml` lives at the project root. Per-user defaults go in
`~/.config/ace/ace.toml`. The lookup order is
**user → project → school's school.toml**, so anything you set per-project
overrides the user default.

To see custom backends a school declares:

```sh
ace config | grep -A3 '\[\[backends\]\]'
```

## Contributing

ACE Home stays small and broadly applicable, so a skill PR here has to be
generic enough to benefit every ACE user. See
[`skills/ace-school/SKILL.md`](skills/ace-school/SKILL.md) for the full
school-PR workflow and its `ace-skill` authoring handoff.
