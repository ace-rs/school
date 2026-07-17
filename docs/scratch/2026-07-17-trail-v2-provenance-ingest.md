<!-- not spec/decision because: session breadcrumb; the rulings below still need to be
promoted to ../decisions/ and the work committed -->

# Trail v2 / provenance ingest — session state (2026-07-17)

## What landed (uncommitted)

Ingested the prod9 "trail v2" skill edit-set into this repo, then reworked it. Four files
modified, **not committed** (commit autonomy suspended by corrections this session — needs
explicit clear):

- `skills/ace/workflow.md` — Orientation gains: resume reads `STATE.md`/`*.ledger.md`,
  present-then-position, ledger statuses bind. Provenance woven in: on resume, trust the
  citation not the label — a SETTLED/KILLED item with no quoted user phrase is read as
  `agent:inferred`.
- `skills/ace-save/SKILL.md` — trail format (STATE + ledger; **LOG.md mandate dropped**,
  narrative left unopinionated, cascade untouched). Ledger items carry a **provenance**
  axis alongside status. Forget-proof: default is `agent:inferred`; SETTLED/KILLED must
  embed the user's verbatim words inline or it's malformed and reads as inferred.
- `skills/ace-connect/SKILL.md` — peer "ruled vs proposed" rule (cite the artifact or label
  `proposal — not ruled`). **Still in the old vocabulary** — see outstanding.
- `skills/ace-afk/workflow-afk.md` — standing rule: solo forks are `agent:inferred` and
  provisional; a solo decision doc lands in `docs/scratch/`, never `docs/decisions/`. afk
  goes far, but can't launder its own calls into the user's mouth.

prod9 cache reverted clean; its `editnote.md` deleted (source plan persists at prod9/platform
`docs/scratch/2026-07-17-trail-fix-plan.md`).

## Outstanding

1. **ace-connect vocab alignment** — rewrite `proposal — not ruled` onto the same
   `agent:inferred` / `user:verbatim` axis so the doctrine reads as one thing across skills.
   Last open task; user asked "which do you want" — afk was answered and written, this wasn't.
2. **Commit** — four edits pending an explicit clear of the suspended autonomy. School PR
   workflow (one skill/theme per commit) via ace-school when cleared.
3. **Promote rulings to `../decisions/`** (see below) once the doctrine fully lands.

## Also uncommitted this session — docs purge (separate track, complete)

Cleaned consumed `scratch/` research per the folder's own disposable-lifecycle policy
(`scratch/README.md`) — no new ruling, just cleanup. Staged + edits, **not committed**:

- `git rm` of 4 consumed scratch docs: `2026-05-09-wire-language-research`,
  `2026-05-10-dialect-eval`, `2026-06-07-llm-era-docs-taxonomy`,
  `2026-07-03-codex-plugin-cc-investigation` — each fully settled into a live design
  (dialect.md / taxonomy ADRs / reactive-only codex track).
- De-dangled the two inbound links to purged files (unstaged edits): the superseded
  two-axis ADR (`docs/decisions/2026-06-07-docs-taxonomy-two-axis.md`) and the kept
  `docs/scratch/2026-07-07-codex-app-server-bridge-redesign.md`.

Kept: `2026-07-07` (self-flagged protocol facts) + this breadcrumb. Landable as its own
commit, independent of the trail-v2 edits above.

## Rulings worth a decision doc (not yet filed)

- **Provenance is forget-proof by default, not by discipline.** Against the obvious "agent
  honestly labels its own inferences" default: that relies on the agent remembering. Instead
  the *default* is `agent:inferred` and "settled" is the burden of proof (needs embedded
  verbatim words). Forgetting then fails safe — it can't manufacture a human ruling.
- **Cross-skill doctrine unifies by vocabulary, not location.** Skills load independently
  (progressive disclosure), so a "see workflow.md" reference dangles when ace-connect/ace-save
  load standalone. Each skill stays self-contained; what's shared is the enum vocabulary, not
  a central file.
