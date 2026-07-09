# docs taxonomy: single-axis routing with gradient forcing

- **Date:** 2026-07-09
- **PR:** pending
- **Status:** accepted

Supersedes [2026-06-07-docs-taxonomy-two-axis](2026-06-07-docs-taxonomy-two-axis.md).

## Decision

ace-docs scaffolds **five** folders, routed on **one** axis — the question the artifact
answers — with placement forced by construction rather than by after-the-fact reasoning:

- `guides/` — a how-to, product-use *or* repo-operation (absorbs the separately-considered
  `runbooks/`); repeatable operations are scripted, the guide holds the judgment.
- `vendor/` — third-party lookup material only (replaces `reference/`); link-first, carries
  a `derived from <src> @ <date>` provenance marker.
- `spec/` — our system's design, how-it-works, **and our own exact surface** (our
  CLI/config/API — the "our-own reference" that used to be `reference/`).
- `decisions/` — dated rulings; frozen, supersede-don't-edit.
- `scratch/` — unsettled exploration only (renamed from `notes/`); the residual home.

Routing is a **gate**: walk it top to bottom, file at the first yes; `scratch/` sits at the
bottom behind a toll (each file opens with a one-line "not spec/decision because ___").
Placement is chosen at **plan time** (a line added to the `ace` workflow's Draft-plan step),
not when filing.

Permanence is **not** a sorting axis — it is a property that falls out of the answer
(`guides`/`vendor`/`spec` living, `decisions` frozen, `scratch` disposable).

## Rationale

The two-axis model's central claim — usage sorts by type, the design record by permanence —
double-counted. Permanence never *varies within* a folder, so it is derivable from the
folder, not an independent axis. Asking the router to reason on two axes when one is
redundant added decision load without discrimination, and under load everything fell to the
soft default (`notes/`). That is the observed failure: `notes/` (and secondarily
`reference/`) became drains.

Two forces produced the drain, and prose routing fought both with a signpost:

- **Name width.** `notes` is a category name — everything is arguably a note — so it matched
  everything. Fix by construction: name folders as **predicates** (`vendor` =
  is-this-third-party?, `decisions` = is-this-a-ruling?), and give the residual a name
  narrower than "notes" so fewer things match it for free → `scratch/`, which also signals
  lowest-status and repels durable work.
- **Friction gradient.** `notes/` was the lowest-energy choice (no template, no toll), so
  content flowed there. Invert it: the residual now *costs* a justification line, and every
  specific folder is a positively-defined first-match gate. Nothing is "the default."

Folder-shape calls:

- **`guides/` absorbs `runbooks/`.** A separate operations folder was considered (distinct
  on a *direction* axis: use-the-product vs run-the-repo) and then merged — both are how-to,
  and one fewer folder means one fewer choice-point. Cost: scripting-first drops from a
  folder-signaled default to a conditional inside `guides/`. Accepted.
- **Executor axis rejected.** An earlier cut distinguished runbooks as agent-executed vs
  human-read guides. Dropped — it would reintroduce the `human/`-vs-`llm/` content
  duplication the two-axis ADR already rejected. Docs are single-source for both readers.
- **`vendor/` replaces `reference/`; our-own reference → `spec/`.** In practice `reference/`
  was dominated by external material, and `vendor` names that predicate cleanly. Our own
  surface is just design — it lives in `spec/`. A repo genuinely heavy in its own API
  reference can add a `reference/` folder back (the scaffold is subset-based); the mild cost
  is a scan-shaped table living among read-shaped spec prose.

Why not the incremental patch (add `runbooks/`, sharpen the two drawers, keep the two-axis
framing): it left the redundant axis and the superset-named default standing — the actual
cause of the drain. A skill is prose and cannot *guarantee* placement (that needs a
write-time hook, explicitly out of scope here), but predicate names + a first-match gate +
a residual toll + plan-time placement steepen the gradient enough to fix the drain in
practice.
