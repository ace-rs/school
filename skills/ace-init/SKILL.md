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
everything Phase 1 would write into a single plan file, get approval on the whole, then
apply it in one pass — never file-by-file. The Phase 2 spec run is separately gated; never
start it unprompted.

`$ARGUMENTS` narrows focus if provided (e.g. "skills only").

## Phase 1 — Lay down the structure

### 1. Study the repo

Build a picture of what this is and what the user is building. Cover:

- **Stack** — languages, frameworks, package managers, build and test commands.
- **Shape** — entry points, top-level layout, module boundaries, where code lives.
- **Domain** — what the project does, who it's for, the core nouns and verbs.
- **Conventions** — existing instructions file(s), README, lint/format config, CI,
  commit-message style, branching.
- **Activity** — `git log --oneline -20` and `git status` for what's in flight.

Keep it a skim — the deep pass is Phase 2. Record findings in the plan file as you go;
later steps add to it.

### 2. Plan the instructions file

The harness instructions file is where an agent reads "what is this repo" every session —
`CLAUDE.md`, `AGENTS.md`, or the harness's equivalent. From the step-1 study, plan to
write or refresh:

- A tight "what this repo is" overview.
- Conventions worth pinning — build/test commands, house style, branching.
- A pointer to `docs/` if it exists or gets scaffolded (step 4).
- Which skills are active and why (see step 3).

Place ACE additions near existing "where things go" guidance, not scattered. If no
instructions file exists, the plan records which to create. Add all of this to the plan.

### 3. Plan the skills selection

A school ships every skill it bundles by default. Trim to what this repo needs.

**Where to write it** — pick the layer by audience:

| File             | Scope                 | Use for                 |
|------------------|-----------------------|-------------------------|
| `ace.toml`       | shared, committed     | the team-wide skill set |
| `ace.local.toml` | personal, uncommitted | your overrides on top   |

Three ways to set it, equivalent in effect:

- Edit the `skills = [...]` array directly — globs like `ace-*` work.
- `ace skills include <pat>` / `ace skills exclude <pat>` — always-add / always-remove
  patterns layered on the array.
- `ace learn` — let ACE study the repo and narrow the filter for you. It also edits the
  instructions file, so it overlaps steps 1–2; reach for it as the quick mechanical pass.

Record the chosen set in the plan with a one-line rationale per add or drop, mapped to the
study (e.g. "drop `frontend-design` — no UI here"). `ace skills` lists what's active;
`ace config` shows the resolved set.

### 4. Plan durable docs

From the study, decide what's worth persisting — architecture, domain model, non-obvious
design history. If there's enough, the plan scaffolds `docs/` and adds a project overview
to `docs/spec/` — how the system fits together — plus the instructions-file pointer
(step 2). If there's little to document, note "no docs" in the plan — an empty docs tree
is noise.

That overview is the high-level cut; the detailed specs come in Phase 2.

### 5. Confirm and apply

Once the scan is done, finalize the plan file and present it as a whole — findings plus
every proposed change. On approval, apply it in one batch: edit the instructions file,
write the skills config, scaffold `docs/` and the overview. Report what landed and remove
the plan file. If a Phase 2 spec run is warranted, flag it in the plan as a recommended
follow-up; don't start it here.

## Phase 2 — Full spec run

A spec run distills what the code already does into durable explainers, so a later human
or agent reads the spec instead of deep-scanning the code again. It needs a deep scan, not
Phase 1's skim. Run it only when the project lacks specs and would benefit, and only on
explicit approval.
Suggest it; never start one unprompted.

On a large codebase this means *many* specs, not one — scope it rather than trying to spec
the whole system in a sitting.

**Decompose first.** List the spec-able units before writing any. Typical cuts:

- **Subsystem / service** — e.g. `auth`, `billing`, `ingest-pipeline`; one spec each.
- **Domain model** — the core entities, their invariants and lifecycles.
- **Key flow** — checkout, onboarding, a nightly job — end-to-end across modules.
- **Integration boundary** — each external API, queue, or webhook contract.

**Prioritize.** Spec the load-bearing and highest-risk units first — most depended on,
most changed, or least understood. A big system is multi-session — order so the first
session stands alone.

**Go deep per unit.** Capture what a skim can't: intended behavior and contracts, data
shapes and invariants, error and edge-case handling, and the *why* behind non-obvious
choices. Reverse-spec against the implementation. Reconcile each claim and flag
divergences (spec says X, code does Y) instead of papering over them.

**Route by permanence.** Per `ace-docs`: how-it-works and intent → `docs/spec/`; a
decision worth pinning → `docs/decisions/` as a dated ADR; exhaustive enumerations (every
config key, every endpoint) → `docs/reference/`.

Run each spec through the normal `ace` planning phases (`/ace` → Specs → Draft Plan);
scaffold `docs/` first (step 4). If a full run is too big for now, write the
highest-priority spec as a seed and stop.

## Close

The instructions file and `ace.toml` are committable artifacts; fold them into the repo's
normal commit flow. Then point the user at `/ace` to start the per-task workflow. ace-init
is re-runnable when the project's shape shifts materially.
