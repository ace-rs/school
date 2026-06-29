# Dev sessions for this upstream school run on prod9/school, not self-host

- **Date:** 2026-06-29
- **Commits:** 386a699 (the switch), 3644393 (CLAUDE.md correction)
- **Status:** accepted

## Decision

This repo is the **upstream** base school (`gh:ace-rs/school`, "ACE Home") that downstream
schools import. Its own `ace.toml` sets `school = "prod9/school"` — so an editing session here
loads its `ace-*` toolchain from the maintainer's personal **prod9/school** clone, not from
this repo. Editing a `skills/<name>/SKILL.md` here does **not** change the skill the harness
has loaded for the session; to test an edit, read the local `SKILL.md` and follow its steps
directly. The prod9 copy is an older mirror and lags upstream.

## Rationale

- **Against the obvious default (self-host).** The scaffold first set `school = "."` (8452981)
  and CLAUDE.md described that. The obvious model for a school repo is to dogfood its own
  skills. We deliberately switched away (386a699): running an editing session *on* the same
  in-flux skills you're editing is fragile — a half-saved `ace-save` or `workflow` edit would
  break the very session driving the work. The stable prod9 toolchain insulates the session
  from edits-in-progress.

- **Cost of leaving it undocumented.** CLAUDE.md was not updated at 386a699, so it kept
  claiming self-host. A later session trusted the doc, edited local skills, self-invoked one,
  and got the stale prod9 copy — burning real time diagnosing why edits "didn't take."
  3644393 fixes the doc; this entry records the *why* so it isn't rediscovered.

- **Testing local edits.** Since the harness won't load this repo's in-flux skill, the test
  path is: read the local `SKILL.md` and execute its steps by hand. No self-host toggle is
  needed for a one-off test.

## Notes

- **Harness skill hot-reload:** Claude Code (and codex/opencode, per maintainer testing)
  auto-reload skills on filesystem change mid-session — no restart. This is why `ace-init` now
  runs `ace link` after writing the skills config (the new symlinks appear live). A harness
  without auto-reload needs a relaunch; the skill says so.
- **Two repos, divergent histories — not a rename:** `gh:ace-rs/school` (this upstream
  checkout) and `github.com:prod9/school` (the editing school, cached at
  `~/.local/share/ace/prod9/school`).
