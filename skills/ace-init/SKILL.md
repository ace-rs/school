---
name: ace-init
description: >
  One-time onboarding of a repo into ACE so coding sessions fit the project. TRIGGER on
  `/ace-init`, or when the user asks to initialize, onboard, or set up ACE in this repo —
  typically just after `ace setup`. Use it whenever a repo is first being ACE-shaped, even
  if "ace-init" is never said. DO NOT TRIGGER at session start or between tasks (that is
  the `ace` skill), for routine coding, or when the repo is already onboarded.
argument-hint: "[optional focus, e.g. 'skills only' or 'docs too']"
---

# ace-init

Print `## ace-init` as the first line.

Onboard this repository into ACE: study what it is, configure ACE to fit it, and leave
durable orientation behind. A one-time onboarding — run on adoption, or again after a
material shift — and the cold-start counterpart to the `ace` workflow skill, which drives
the recurring per-task loop. ace-init configures and orients; it does not do feature work.
Hand off to `/ace` for that.

It runs in two phases — **lay down the structure** (Phase 1: cheap, expected) then an
optional **full spec run** (Phase 2: token-heavy, approval-gated).

Assumes `ace setup` already ran. If the repo has no ACE config, point the user at
`ace setup` first.

**Propose-then-wait, in one batch.** The study is read-only — run it directly. Collect
everything Phase 1 would write in `.ace/init-plan.md`, get approval on the whole, then
apply it in one pass — never file-by-file. The plan is gitignored working state and is
deleted after the approved batch lands. The Phase 2 spec run is separately gated; never
start it unprompted.

`$ARGUMENTS` narrows focus if provided (e.g. "skills only").

## Procedure evidence

Read `ace/ledger.md` in the `ace` skill's directory. Run each phase in order and retain
its review result. Phase 1 step 6 and Phase 2 step 1 are Waits; continue only after the
user approves.

## Phase 1 — Lay down the structure

### 1. **Open plan**

Create `.ace/init-plan.md`. Verify whether `/.ace/` is gitignored; when it is not, record
the `.gitignore` addition in the plan instead of editing the tracked file before approval.
Record every Phase 1 finding and proposed write in the plan until step 8 removes it.

### 2. **Study repo**

Build a picture of what this is and what the user is building. Cover:

- **Stack** — languages, frameworks, package managers, build and test commands.
- **Shape** — entry points, top-level layout, module boundaries, where code lives.
- **Domain** — what the project does, who it's for, the core nouns and verbs.
- **Conventions** — existing instructions file(s), README, lint/format config, CI,
  commit-message style, branching.
- **Activity** — `git log --oneline -20` and `git status` for what's in flight.

Keep it a skim — the deep pass is Phase 2. Record findings in `.ace/init-plan.md` as you
go; later steps add to it.

### 3. **Plan instructions**

The harness instructions file is where an agent reads "what is this repo" every session —
`CLAUDE.md`, `AGENTS.md`, or the harness's equivalent. From the step-2 study, plan to
write or refresh:

- A tight "what this repo is" overview.
- Conventions worth pinning — build/test commands, house style, branching.
- A pointer to `docs/` if it exists or gets scaffolded (step 5).
- Which skills are active and why (see step 4).

Record, but do not install, this default block in `.ace/init-plan.md`:

```markdown
## Git checkpoints

Commit coherent, completed slices autonomously after completing the checks required for
that work. Do not ask for permission to make a local commit. A local commit does not
authorize pushing, publishing, merging, releasing, deploying, or any other change to
shared or external state; each requires separate user authorization.
```

Label it **Proposed future commit autonomy policy**. Explain in the plan that approval
would let future agents create local commits without asking after completing the checks
for their work, but would grant no authority to push, publish, or take another outward
action. State that the user may revise or omit the block before approving Phase 1.

Place ACE additions near existing "where things go" guidance, not scattered. If no
instructions file exists, the plan records which to create. Add all of this to the plan.

### 4. **Plan skills**

A school ships every skill it bundles by default. Trim to what this repo needs.

**Discover what's on offer first.** Run `ace skills --all` — the full inventory the school
and its imports provide, excluded ones included. Plan the selection from that list, not
from the skills loaded in this session. For any candidate whose purpose isn't obvious from
its name, read its frontmatter `description` under the resolved school clone (the `school`
row of `ace paths`) before ruling it in or out.

**Where to write it** — pick the layer by audience:

| File             | Scope                 | Use for                 |
|------------------|-----------------------|-------------------------|
| `ace.toml`       | shared, committed     | the team-wide skill set |
| `ace.local.toml` | personal, uncommitted | your overrides on top   |

Two ways to set it, equivalent in effect:

- Edit the `skills = [...]` array directly — globs like `ace-*` work.
- `ace skills include <pat>` / `ace skills exclude <pat>` — always-add / always-remove
  patterns layered on the array.

Record the chosen set in the plan with a one-line rationale per add or drop, mapped to the
study (e.g. "drop `frontend-design` — no UI here"). `ace skills` lists what's active;
`ace config` shows the resolved set.

### 5. **Plan docs**

From the study, decide whether durable docs are warranted — architecture, a domain model,
or non-obvious design history worth persisting. If so, the plan notes that `docs/` should
be scaffolded via `ace-docs` (which owns the tree shape and routing) with a project
overview in `docs/spec/` as the seed doc. Don't scaffold here — defer it to `ace-docs` at
the point that first doc is written (the Phase 2 spec run, or whenever a doc is needed),
so a tree that never gets filled is never created. If there's little to document, note
"no docs" in the plan.

That overview is the high-level cut; the detailed specs come in Phase 2.

### 6. **Confirm plan**

Once the scan is done, finalize the plan file and present it as a whole — findings plus
every proposed change. Call out the proposed `Git checkpoints` policy separately. State
that it lets future agents create local commits without asking but does not authorize
pushing, publishing, or any other outward action. Tell the user they may revise or remove
it before approval. Wait for approval of the complete batch.

### 7. **Apply plan**

Open by quoting the approval. Edit the instructions file and write the skills config in
one batch. Write only the `Git checkpoints` policy wording the user approved. If the user
removed or rejected the proposed block, do not add it; preserve the repository's existing
policy unless the approved plan explicitly changes it. Then run `ace link` so the selected
skills are symlinked into the harness's skill folder. On harnesses that auto-reload skills
from the filesystem, they go live in the running session immediately. On other harnesses,
tell the user to relaunch. If durable docs are warranted, report the `ace-docs` scaffold
and Phase 2 spec run as follow-ups; start neither here.

### 8. **Remove plan**

Delete `.ace/init-plan.md` after all approved writes and `ace link` complete. Report the
files changed and the link result.

## Phase 2 — Full spec run

A spec run distills what the code already does into durable explainers. It needs a deep
scan, not Phase 1's skim. Run it only when the project lacks specs and would benefit.

### 1. **Scope run**

List the spec-able units and order them by dependency, change frequency, risk, and current
understanding. A large codebase needs several specs and may need several sessions. Present
the ordered scope and wait for explicit approval. Typical units:

- **Subsystem / service** — e.g. `auth`, `billing`, `ingest-pipeline`; one spec each.
- **Domain model** — the core entities, their invariants and lifecycles.
- **Key flow** — checkout, onboarding, a nightly job — end-to-end across modules.
- **Integration boundary** — each external API, queue, or webhook contract.

### 2. **Prepare docs**

Open by quoting the approved scope. Read the existing `docs/` gate; when none exists, run
`ace-docs` before writing the first unit. Route system behavior, intent, and the project's
exact surface to `docs/spec/`; route third-party lookup to `docs/vendor/`.

### 3. **Study unit**

Deep-read the implementation for the next approved unit. Capture behavior, contracts,
data shapes, invariants, errors, edge cases, and non-obvious intent.

### 4. **Reconcile claims**

Check every proposed claim against the implementation. Flag divergences between intended
and implemented behavior instead of papering over them.

### 5. **Write spec**

Run the unit through the normal `ace` planning phases, then write it through the
`ace-docs` gate. Everything settled amends `docs/spec/`; never scaffold a decisions log.

### 6. **Review unit**

Verify the document against the implementation and the approved scope. Fix every mismatch.

### 7. **Continue run**

Return to step 3 for the next approved unit. When the approved scope is exhausted, report
the specs written and stop. A smaller approved scope may end after one seed spec.

## Close

The instructions file and `ace.toml` are committable artifacts; fold them into the repo's
normal commit flow. Then point the user at `/ace` to start the per-task workflow. ace-init
is re-runnable when the project's shape shifts materially.
