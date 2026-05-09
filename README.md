# ACE Home

The baseline school for [ACE](https://ace-rs.dev) — the foundation every
other school inherits from.

> ACE is a thin coding harness on top of Claude Code, Codex, OpenCode, and
> friends. It wires shared skills, conventions, MCP servers, and session
> prompts into every project so your AI sessions all start from the same
> ground. **Schools** are how that shared ground is distributed.

For docs, the latest releases, and the full feature catalogue, see
[ace-rs.dev](https://ace-rs.dev). This README focuses on what ACE Home
specifically ships and how to use it.

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
ACE itself useful, plus the official Anthropic `skill-creator` for anyone
authoring their own skills. Anything team- or project-specific belongs in
your school, not here. See [`docs/spec/baseline-school.md`](docs/spec/baseline-school.md)
for the full charter.

## What lives here

Seven skills, all loaded by default for any school that imports this one:

| Skill            | What it does                                                     |
| ---------------- | ---------------------------------------------------------------- |
| `ace`            | Start or resume the ACE workflow at session boundaries           |
| `ace-audit`      | Recover when a diff landed without passing through audit         |
| `ace-connect`    | Local agent-to-agent bridge over unix sockets                    |
| `ace-realign`    | Re-anchor drifted attention; trace the prompt-chain cause        |
| `ace-save`       | Persist session state before `/clear` or context switch          |
| `ace-school`     | Manage school edits and PRs                                      |
| `skill-creator`  | Anthropic's authoritative skill-authoring skill                  |

Top-level docs:

- [`ACE.md`](ACE.md) — overview of the `ace-*` workflow skills, in order
- [`RTK.md`](RTK.md) — RTK ("Rust Token Killer") command catalogue for
  compacting noisy tool output
- [`CLAUDE.md`](CLAUDE.md) — house style when editing this school itself
- [`docs/`](docs/) — durable artifacts (specs, decisions, notes)

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

ACE Home stays small and broadly applicable. Skill PRs should be generic
enough to benefit every ACE user. Team- or domain-specific skills belong in
your own school — import them from there instead. See
[`skills/ace-school/SKILL.md`](skills/ace-school/SKILL.md) for the full
school-PR workflow and house-style notes.
