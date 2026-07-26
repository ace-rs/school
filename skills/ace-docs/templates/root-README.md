# docs

Durable artifacts. **File by the gate below** — walk it top to bottom and stop at the first
yes. The bottom (`scratch/`) charges a toll, so nothing lands there by default.

## Where does this go?

1. Third-party facts you keep to look up (a framework, an external API/CLI)? →
   [`vendor/`](vendor/) — link-first, mark provenance.
2. A how-to — using the product *or* operating the repo? → [`guides/`](guides/) — script
   repeatable operations; the guide holds the judgment.
3. How our system is built or meant to work, including its own config/CLI surface? →
   [`spec/`](spec/).
4. None of the above — genuinely unsettled exploration → [`scratch/`](scratch/). Open with
   a one-line "not spec because ___."

## Everything settled amends `spec/`

An instruction you were given, an approach that was agreed, a library that was picked, a
convention or preference that was fixed — all of it is an edit to [`spec/`](spec/). Make
the edit, state the current rule, move on. There is no separate ruling artifact and no
fifth folder; if it feels like a decision, it's a spec amendment.

**The spec is authoritative — read it before you work, and comply.** It owes your priors no
justification. That a rule departs from mainstream practice or from what you expected is
not grounds to escalate or re-open it. If you think it's wrong, raise it and amend the spec.

Each folder's README states its one test precisely. `CLAUDE.md` / `AGENTS.md` points here
as the index.
