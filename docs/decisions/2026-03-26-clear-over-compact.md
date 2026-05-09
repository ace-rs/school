# Prefer /clear over /compact

- **Date:** 2026-03-26
- **PR:** manual
- **Status:** accepted

## Decision

Always `/ace-save` then `/clear`; never `/compact`.

## Rationale

`/compact` consumes significant tokens for lossy context summarization. With `/ace-save`
persisting state to durable storage (scratch files, issue tracker, CLAUDE.md, git), the
summary is redundant. `/clear` gives a full context reset at zero token cost. Built-in
tasks/memory don't survive `/clear`, so ace-save always writes to durable locations.

Hook-based enforcement was investigated (Claude Code `PreCompact`) but rejected: it can't
block the compact, can't invoke slash commands, is Claude Code-only (no OpenCode/Codex/Droid
support), and would require `.claude/settings.json` distribution which ACE doesn't manage.
Doc-level guidance is the portable solution.
