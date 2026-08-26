---
name: ace-audit
description: >
  Re-enters the audit step in `ace/workflow.md` — as recovery when a diff landed
  without passing through it, or standalone to re-audit a large body of already-landed
  work and maximize quality. TRIGGER when: user invokes `/ace-audit` or asks to review,
  audit, or check work against skill compliance. DO NOT TRIGGER for the normal in-`/ace`
  audit step (the workflow runs it), routine coding, or when there's no landed diff or
  body of work to review.
argument-hint: "[scope for a standalone pass, e.g. paths or a commit range]"
---

# ACE Audit

Print `## ace-audit` as the first line.

The audit lives in `ace/workflow.md` as the `Audit` step. Two ways in:

- **Recovery** — a diff didn't pass through `/ace` (ad-hoc edits, late skill loads,
  drifted work) and needs the audit it skipped.
- **Standalone quality pass** — deliberately re-audit a large body of work that
  already landed, to catch issues and maximize quality even though nothing slipped.

## Stamp chain

The numbered steps below run as a stamp chain. Read `ace/ledger.md` — in the `ace`
skill's directory, sibling to this one — and follow its contract: close every step with
its one-line stamp, open the next by reprinting it, no skips, exemptions only in the
user's verbatim words.

## Audit procedure

1. **Find files.** Recovery: `git diff
   --name-only` (add `--cached` for staged work) names the files. Standalone, on a
   clean tree: take the scope from `$ARGUMENTS`; with no `$ARGUMENTS`, use the
   unpushed range (`git log @{u}..HEAD --name-only`); with neither, ask the user to
   name the body of work.

2. **Load governing skills.** Branch on what the files are:

   - **Code** — load each language's coding skill, plus any framework or infrastructure
     skill relevant to the changed files.
   - **Skills (`skills/<name>/SKILL.md`)** — load `ace-skill` if the session has it;
     its house style checklist is the review gate.
   - **Docs, config, or anything else** — audit against the repo's own instructions file
     (`CLAUDE.md` / `AGENTS.md`) and the conventions it points at.

   Never skip this step because no language skill fits; every diff has a governing
   surface.

3. **Resolve design.** Check the loaded skills
   for structural violations — a missing transaction boundary, a stringly-typed field
   that should be an enum, a helper reaching across module boundaries. Apply the design
   those governing surfaces require. Ask one narrow question only when they leave
   materially different valid designs with no rule ranking them. After the answer,
   resolve the choice and continue.

4. **Audit full scope.** Run the `ace/workflow.md` Audit step and categorize
   every finding. When the pass finds a Violation, fix every Violation, rerun the
   affected checks, and stamp `next: 3 Resolve design`. Restart at step 3 without
   handing off a findings report or rescanning only the patched files. Only a fresh
   full-scope pass with zero Violations closes the loop.

5. **Commit.** Commit using the repository's existing conventions and message format.
