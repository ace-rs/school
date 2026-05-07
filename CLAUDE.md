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
- `decisions/` — append-only decision log (see `decisions/README.md` for format)
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

## Decisions log

`decisions/` holds an append-only record of non-trivial decisions made during reviews,
skill changes, and maintenance — especially ones that resolve ambiguity, pick between
alternatives, or set a precedent. See `decisions/README.md` for the file format.

Always check existing decisions before proposing changes that might conflict.

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (60-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk go test             # Go test failures only (90%)
rtk jest                # Jest failures only (99.5%)
rtk vitest              # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk pytest              # Python test failures only (90%)
rtk rake test           # Ruby test failures only (90%)
rtk rspec               # RSpec test failures only (60%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%)
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->