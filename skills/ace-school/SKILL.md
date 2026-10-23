---
name: ace-school
description: >
  Inspect an ACE school, review its changes, or route and propose a skill change to the
  school that owns it. TRIGGER on school structure, `ace diff`, dirty school state, failed
  `ace school pull`, a request to change or fix a school skill, skill-change proposals, a
  school-PR request, or a hand-off from `ace-skill`. DO NOT TRIGGER for project work that
  does not change or diagnose a school.
---

# ace-school

Print `## ace-school` as the first line.

## Terms

- **Authored school:** the session's current directory is a school repository. It has
  `school.toml` and `skills/`.
- **Linked school:** the school ACE links into the current project. `ace paths school`
  prints its clone. ACE manages that clone and keeps pulling it: never edit, branch,
  commit, or stash in it.
- **Owning school:** the school whose `skills/` authors the skill, as opposed to a school
  that imports it through `[[imports]]`.
- **Proposal worktree:** one git worktree per proposal, at
  `~/.local/share/ace/.worktrees/<owner>/<repo>/<desc>`.

For what ACE can do, run `ace llm-help`. For exact flags, run `ace <command> --help`.
When `ace llm-help` is not available in the installed ACE, use `ace --help` and
`ace <command> --help`.

## Menu

| Operation               | Steps  | Use when                                            |
|-------------------------|--------|-----------------------------------------------------|
| Inspect or diagnose     | I1–I3  | structure question or school failure                |
| Review school changes   | R1–R3  | review request or `ace diff`                        |
| Route a skill change    | T1–T4  | a skill should change, or `ace-skill` hands off     |
| Publish a proposal      | P1–P5  | explicit request to push a proposal and open a PR   |
| Clean a merged proposal | C1–C3  | explicit request to clean a merged proposal         |

Use only the selected operation. A review or diagnostic request ends with its report; it
does not authorize a branch, commit, push, PR, cleanup, or other write.

## Procedure evidence

Read `ace/ledger.md` in the `ace` skill's directory. Keep the selected checkout, the
import chain, relevant diff or diagnostic output, user authorization, PR result, and
final checkout state as evidence. Do not print per-step markers.

## Inspect or diagnose

- **I1. Select the checkout.** In an authored school, use the current directory.
  Otherwise use the linked school's clone from `ace paths school`. Use a checkout the
  user names explicitly instead, and record the difference. Inspect
  `git status --short` and `git remote -v` in the selected checkout.
- **I2. Inspect the named surface.** For a structure question, read `school.toml` and the
  relevant school docs. For a dirty linked clone, run `ace diff`. It reports only the
  linked clone, never an authored school. For a failed pull, inspect the dirty state and
  the `[[imports]]` declarations before assigning a cause.
- **I3. Report the result.** State the checkout, evidence, conclusion, and the first
  unresolved prerequisite. For edits found in the linked clone, recommend moving them
  into a proposal worktree. Stop without changing state.

## Review school changes

- **R1. Select and read.** Select the checkout as in I1, or the proposal worktree under
  review. Read its instructions and durable record, then inspect its working-tree state.
- **R2. Review.** Inspect staged and unstaged changes with `git diff` and
  `git diff --cached` in the selected checkout. Check the changes against the stated
  task, skill interactions, genericity, supporting rosters, and authoring rules.
- **R3. Report and stop.** Report every finding, reviewed path, and decisive diff
  evidence. Clean and failing reviews both complete this assessment. Do not continue
  into P1 without an explicit request to publish.

## Route a skill change

- **T1. Pick the target school.** In an authored school, a request to change a skill
  targets that school's `skills/` by default. A report about how a skill loaded in this
  session behaved targets the linked school, unless `ace.toml` sets `school = "."`. When
  the request fits both, ask the user which school they mean. This is a Wait.
- **T2. Trace the owning school.** Read the target school's `school.toml`. When an
  `[[imports]]` entry's `skills` patterns match the skill and its `exclude_skills` do not,
  the skill comes from that entry's `source`. Run `ace pull <owner>/<repo>` for the
  source, read its `school.toml` from its clone under `~/.local/share/ace/<owner>/<repo>`,
  and repeat until a school authors the skill. Record the chain, for example
  `C → B → A`.
- **T3. Choose the fix.** Compare the skill in the owning school with the copy the user
  saw.

  | Finding                                     | Action                                                                                    |
  |---------------------------------------------|-------------------------------------------------------------------------------------------|
  | owner already has the fix; a copy is stale  | No proposal. Report which school's maintainers must run `ace school pull`. Stop.          |
  | owner lacks the fix                         | Propose to the owning school. This is the default.                                        |
  | user asks to propose to an importing school | Warn that this skips the owner and that school's next `ace school pull` overwrites it. Wait for confirmation. |
  | chain or owner is unclear                   | Ask the user. This is a Wait.                                                             |

  An importing school never carries its own version of an imported skill.
- **T4. Open the checkout.**
  - **The owning school is the authored school:** edit in place under that repository's
    own branch and commit rules. Load `ace-skill`, author there, and stop. Skip P1–P5.
  - **Any other owning school:** create a proposal worktree from ACE's clone of it, then
    load `ace-skill` and author inside the worktree.

  ```sh
  ace pull <owner>/<repo>                    # the linked school: ace pull
  clone=~/.local/share/ace/<owner>/<repo>    # the linked school: $(ace paths school)
  wt=~/.local/share/ace/.worktrees/<owner>/<repo>/<desc>
  git -C "$clone" fetch origin
  git -C "$clone" worktree add -b ace/<desc> "$wt" origin/HEAD
  ```

  Project skill links keep pointing at the clone. To exercise an edit, read the
  worktree's `SKILL.md` and follow it directly. The change reaches projects only after
  merge and the next pull.

## Publish a proposal

- **P1. Verify the proposal.** In the proposal worktree, inspect `git status`,
  `git log --oneline origin/HEAD..HEAD`, and `git diff origin/HEAD...HEAD`. Run the
  owning school's required checks. Confirm that the changed paths belong to one skill or
  coherent theme and every required roster and record is current. Report unrelated
  commits and stop; do not rewrite the graph.
- **P2. Present the publication.** Present the changed paths, findings, branch, base,
  commit list, PR title, full draft body, and validation evidence. Follow the owning
  school's PR instructions.
- **P3. Authorize publication.** Ask for explicit authorization to push the named branch
  and create the presented PR. This is a Wait. When the user already authorized those
  exact outward actions and P1 did not change their scope, quote that authorization and
  continue.
- **P4. Publish.** Open by quoting the authorization. Confirm the P1 change set is
  unchanged. Push with `git -C "$wt" push -u origin ace/<desc>`. Create the PR through
  the hosting workflow the session instructions name, with the presented title and body.
- **P5. Report.** Present the PR title, URL, branch, commit hashes, validation result,
  and the worktree path. Keep the worktree until the PR merges.

## Clean a merged proposal

- **C1. Confirm the target.** Confirm that the user explicitly requested cleanup. Verify
  through the hosting workflow that the PR merged. Inspect the worktree; stop if it holds
  uncommitted or unpushed work.
- **C2. Remove the worktree.** Run `git -C "$clone" worktree remove "$wt"` and
  `git -C "$clone" branch -d ace/<desc>`. Stop if Git refuses either step.
- **C3. Refresh.** Run `ace pull` so the linked clone picks up the merge. Report the merge
  evidence, the removed worktree and branch, and the clone's state.

## Completion contract

- I1–I3 complete with the resolved checkout, diagnostic evidence, finding, and no write.
- R1–R3 complete with reviewed paths, every finding, decisive diff evidence, and no write.
- T1–T4 complete with the target school, the import chain, the chosen fix, and the open
  checkout, or with the report that only a stale copy needs pulling.
- P1–P5 complete with the exact authorization quote, PR URL, branch, commits, validation
  result, and worktree path.
- C1–C3 complete with the cleanup request, merge evidence, removed worktree and branch,
  and refreshed clone.
- A missing prerequisite returns to the earliest step that can establish it. An unresolved
  prerequisite completes only with a report naming the evidence and required decision.

## School reference

A school is a git repository containing shared skills, conventions, and session prompts:

- `school.toml` — school metadata.
- `skills/<name>/SKILL.md` — one directory per skill.
- `CLAUDE.md`, `AGENTS.md`, or an equivalent — always-loaded house rules.
- `docs/` — a durable record when the school uses one.

Projects subscribe through `ace setup`. ACE clones the linked school under
`~/.local/share/ace/<owner>/<repo>` and links each of its skills into the project. When
`ace.toml` sets `school = "."`, the current repository is both the authored school and
the linked school.

### Imports track latest

`[[imports]]` copies skills from a `source` school. `ace school pull` overwrites each
imported copy with the source's latest version. ACE pins no versions, and an importing
school never carries its own version of an imported skill.

To replace an imported skill, list it in that import's `exclude_skills`, then author the
replacement in the school's own `skills/`.

### Skills have no alias

A skill's invocation handle is its directory identity. Frontmatter `name:` is display
only; the parser reads only `name` and `description`, and ignores other metadata keys.
ACE resolves `/foo` to `skills/foo/`. Another invocation name requires another real skill
directory, not an alias field or forwarding stub.
