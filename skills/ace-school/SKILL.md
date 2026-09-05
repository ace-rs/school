---
name: ace-school
description: >
  Inspect an ACE school, review its changes, or prepare a school PR. TRIGGER on school
  structure, `ace diff`, dirty school state, failed `ace school pull`, skill-change
  proposals, or an explicit school-PR request. DO NOT TRIGGER for project work that does
  not change or diagnose a school.
---

# ace-school

Print `## ace-school` as the first line.

Use a school checkout the user names explicitly. Otherwise resolve it with
`ace paths school`. Carry that selected checkout through the operation.

## Menu

| Operation               | Steps  | Use when                                     |
|-------------------------|--------|----------------------------------------------|
| Inspect or diagnose     | I1–I3  | structure question or school failure         |
| Review school changes   | R1–R3  | review request or `ace diff`                 |
| Create a school PR      | P1–P6  | explicit request to publish a proposal       |
| Clean a merged proposal | C1–C3  | explicit request to clean a merged proposal  |

Use only the selected operation. A review or diagnostic request ends with its report; it
does not authorize a branch, commit, push, PR, cleanup, or other write.

## Procedure evidence

Read `ace/ledger.md` in the `ace` skill's directory. Keep the selected checkout, relevant
diff or diagnostic output, user authorization, remote selection, PR result, and final
checkout state as evidence. Do not print per-step markers.

## Inspect or diagnose

- **I1. Select the checkout.** Run `ace paths school`. Use its result unless the user
  explicitly named another school checkout; record any difference. Inspect
  `git status --short` and `git remote -v` in the selected checkout. Do not substitute a
  project-facing skill symlink, subscription clone, or cache path.
- **I2. Inspect the named surface.** For a structure question, read `school.toml` and the
  relevant school docs. For a dirty checkout, run `ace diff`, record the checkout it
  resolves, and inspect `git diff` in the selected checkout. For a failed pull, inspect
  the dirty state, import declarations, and upstream discovery shape before assigning a
  cause.
- **I3. Report the result.** State the checkout, evidence, conclusion, and the first
  unresolved prerequisite. Stop without changing state.

## Review school changes

- **R1. Select and read.** Run `ace paths school`. Use an explicitly named school checkout
  instead when provided, and record the difference. Read the selected checkout's
  instructions and durable record, then inspect its working-tree state.
- **R2. Review.** Run `ace diff` and record the checkout it resolves. In the selected
  checkout, inspect staged and unstaged changes. Check the actual changes against the
  stated task, skill interactions, genericity, supporting rosters, and authoring rules.
- **R3. Report and stop.** Report every finding, reviewed path, and decisive diff
  evidence. Clean and failing reviews both complete this assessment. Do not continue
  into P1 without an explicit request to create a school PR.

## Create a school PR

- **P1. Prepare the target and change.** Resolve the checkout and read its instructions,
  durable record, branch convention, and PR instructions. Use an explicitly named school
  checkout instead of the `ace paths school` result and record the difference. For skill
  edits, load `ace-skill` and complete its matching authoring operation. Amend the
  school's durable record when the change settles or changes a convention. Run
  `git remote -v` in the selected checkout and resolve the repository-designated remote.
  Resolve the local base branch, its target base ref such as
  `{remote-name}/{base-branch}`, and the proposal branch. Report and wait if any target is
  ambiguous.
- **P2. Verify the concrete proposal.** Run `ace diff` and record the checkout it
  resolves. In the selected checkout, inspect `git diff`, `git diff --cached`,
  `git log --oneline {base-ref}..HEAD`, and `git diff {base-ref}...HEAD`. Run the
  proposal's required checks. Stop only when the staged diff, unstaged diff, and intended
  commit range contain no proposed change. Confirm that the changed paths belong to one
  skill or coherent theme and every required roster and record is current. Follow the
  repository's branch convention. Use the current branch when it is suitable; plan
  `ace/{short-description}` only when a new branch is required. Report unrelated commits
  and stop; do not rewrite the graph. Present the exact paths, findings, remote, base
  branch, base ref, proposal branch, commit plan, PR title, full draft body, and
  validation evidence.
- **P3. Authorize publication.** Ask for explicit authorization to push the named branch
  to the named remote and create the presented PR. This is a Wait. If the user already
  authorized those exact outward actions and P2 did not change their scope, quote that
  authorization and continue without asking again.
- **P4. Publish the proposal.** Open by quoting the authorization. Enter the selected
  checkout and confirm the P2 change set is unchanged. Create the planned branch only
  when required. Stage only the presented paths, commit logical slices using the
  school's convention, and never discard unrelated state. Confirm that the branch has
  every intended commit, no unrelated commit, a clean tree, and passing required checks.
  Push with `git push -u {remote-name} {branch}`. Create the PR through the configured
  hosting workflow with the presented title and body. Follow any loaded PR-creator,
  issue-creator, hosting-format skill, or repository PR instructions.
- **P5. Report and choose checkout.** Present the PR title, URL, remote, base, branch,
  commit hashes, validation result, and current checkout state. Ask the user to retain the
  clean proposal branch until merge or return to the clean base branch. Wait for the
  choice. This is a Wait.
- **P6. Apply the checkout choice.** Open by quoting the choice. Keep the proposal branch
  and verify it is clean, or check out the resolved base branch and verify it is clean.
  Report the final branch and status.

## Clean a merged proposal

- **C1. Confirm the target.** Confirm that the user explicitly requested cleanup. Resolve
  the checkout, remote, proposal branch, intended base branch, and PR. Verify through the
  configured hosting workflow that the PR merged, then inspect the working tree before
  any checkout. Stop if the PR remains open, the base is ambiguous, or the tree is dirty.
- **C2. Update the base.** Check out the resolved base branch and run
  `git pull --ff-only {remote-name} {base-branch}`. Stop on a non-fast-forward result.
- **C3. Remove the merged branch.** Delete only the verified merged local branch with
  `git branch -d {branch}`. Report the merge evidence, updated commit, deleted branch,
  and clean checkout state.

## Completion contract

- I1–I3 complete with the resolved checkout, diagnostic evidence, finding, and no write.
- R1–R3 complete with reviewed paths, every finding, decisive diff evidence, and no write.
- P1–P6 complete with the exact authorization quote, PR URL, remote, branch, commits,
  validation result, and final checkout state.
- C1–C3 complete with the cleanup request, merge evidence, updated base commit, deleted
  branch, and clean checkout state.
- A missing prerequisite returns to the earliest step that can establish it. An unresolved
  prerequisite completes only with a report naming the evidence and required decision.

## School reference

A school is a git repository containing shared skills, conventions, and session prompts:

- `school.toml` — school metadata.
- `skills/<name>/SKILL.md` — one directory per skill.
- `CLAUDE.md`, `AGENTS.md`, or an equivalent — always-loaded house rules.
- `docs/` — a durable record when the school uses one.

Projects subscribe through `ace setup`. Unless the user names a school checkout,
`ace paths school` returns the one to use. A normal subscription stores it under the ACE
data directory and symlinks its skills into the project. When `ace.toml` sets
`school = "."`, the current project is that checkout. Do not substitute an import cache
or another guessed path.

### `school.toml` schema

| Field            | Type   | Notes                                                  |
|------------------|--------|--------------------------------------------------------|
| `name`           | string | school display name; required                          |
| `backend`        | string | built-in backend or a `[[backends]]` name              |
| `session_prompt` | string | text prepended to each subscriber session              |
| `env`            | map    | environment variables exported into session shells     |
| `[[mcp]]`        | array  | servers: `name`, `url`, `headers`, `instructions`      |
| `[[projects]]`   | array  | project metadata: `name`, `repo`, `description`, `env` |
| `[[imports]]`    | array  | upstream schools to inherit from                       |
| `[[backends]]`   | array  | custom backends: `name`, `kind`, `cmd`, `env`          |

All fields except `name` are optional and omitted when empty.

### Imports and inheritance

Each `[[imports]]` declaration uses these fields:

| Field                  | Meaning                                                      |
|------------------------|--------------------------------------------------------------|
| `source`               | upstream `owner/repo` or URL                                 |
| `skills`               | patterns to import; `"*"` selects the whole school           |
| `skill`                | accepted singular input for `skills`; never re-emitted       |
| `exclude_skills`       | patterns to subtract and silence matching collision warnings |
| `include_experimental` | admit the experimental tier; default off                     |
| `include_system`       | admit the system tier; default off                           |
| `include_internal`     | admit internal skills by glob; explicit names bypass it      |

At least one of `skills` or `skill` is required. Imports are first-wins: an earlier
declaration claims an identity, and a later match warns unless the winner excludes it.
`ace school pull` copies imports from the import cache into the school's `skills/` tree.
It does not update skills vendored by hand.

Before writing an import, inspect the upstream layout. Discovery checks in order:

1. `<root>/SKILL.md`; when present, the repository is one skill named after the root.
2. Recursive `SKILL.md` files under `skills/` and its `.curated/`, `.experimental/`, and
   `.system/` tiers.
3. Only when step 2 finds nothing, recursive skills under `.claude/skills/`,
   `.codex/skills/`, `.opencode/skills/`, `.cursor/skills/`, `.windsurf/skills/`,
   `.kiro/skills/`, and `.agents/skills/`.

A nested `skills/language/coding/SKILL.md` has identity `language/coding`. Discovery does
not walk arbitrary root directories. A declaration that matches nothing warns rather
than fails. When the upstream layout exposes no skill, vendor the directory with its
license and attribution, adapt its frontmatter, record its source, and maintain it by
hand only when the request authorizes that import or edit. A diagnostic request reports
the unsupported layout and stops. The complete discovery rule lives in
`docs/spec/skills/model.md` in the ACE source.

### Skills have no alias

A skill's invocation handle is its directory identity. Frontmatter `name:` is display
only; the parser reads only `name` and `description`, and ignores other metadata keys.
ACE resolves `/foo` to `skills/foo/`. Another invocation name requires another real skill
directory, not an alias field or forwarding stub.

### School commands

| Command                   | Purpose                                                |
|---------------------------|--------------------------------------------------------|
| `ace setup <school>`      | subscribe a project and wire the school in             |
| `ace diff`                | show uncommitted school-checkout changes               |
| `ace paths [key]`         | print resolved school, cache, and project paths        |
| `ace import <owner/repo>` | import skills with `--skill` or `--all`                |
| `ace school init`         | scaffold a school                                      |
| `ace school pull`         | refresh imports; alias `update`                        |
| `ace school skills`       | list a school's skills                                 |
| `ace school validate`     | check school config; alias `check`                     |
| `ace skills`              | list or curate active skills                           |
| `ace explain <skill>`     | show a skill's provenance and resolution trace         |
| `ace config`              | print, get, or set config keys                         |
| `ace mcp`                 | manage MCP server registrations                        |
| `ace fmt`                 | format `ace.toml` and `school.toml`                    |

Run checkout-local commands from the selected checkout. When an ACE command resolves a
different checkout, record that path and do not treat its output as evidence about the
selected checkout.
