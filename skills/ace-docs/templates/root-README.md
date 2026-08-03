# docs

Durable artifacts. **File by the gate below** — walk it top to bottom and stop at the
first yes. The bottom (`scratch/`) charges a toll, so nothing lands there by default.

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
convention or preference that was fixed — all of it is an edit to [`spec/`](spec/). Write
it as it was given: the rule, at the length it was given, with no reason supplied and no
note of what it was chosen over. "This project uses RESTful routes" is one sentence and
the whole entry. There is no separate ruling artifact and no fifth folder.

**The spec is authoritative — read it before you work, and comply.** It owes your priors
no justification. That a rule departs from mainstream practice or from what you expected
is not grounds to escalate or re-open it. If a spec is wrong, raise it and amend the spec.

**Spec may outrun code.** Something agreed but not yet implemented belongs in `spec/` now,
with the affected section flagged intended/target. Never leave the spec teaching a design
that has been abandoned, and never strand a settled rule in a resume or handoff note.

Permanence falls out of the folder, not a separate judgment: `guides/`, `vendor/`, and
`spec/` are living and edited in place; `scratch/` is disposable and dated.

**Before writing into a folder, read that folder's `README.md` first.** It states the
folder's filing test, filename format, and lifecycle rules, and they are binding.

`CLAUDE.md` / `AGENTS.md` points here as the index.
