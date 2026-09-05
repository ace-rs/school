# docs

File durable artifacts by this gate. Walk it from top to bottom and stop at the first
matching predicate. Nothing defaults to `scratch/`.

## Where does this go?

1. Third-party facts kept for lookup about a framework, external API, or CLI? →
   [`vendor/`](vendor/).
2. A task-oriented how-to for the product or repository? → [`guides/`](guides/).
3. The system's design, intended behavior, or exact config, CLI, API, or schema? →
   [`spec/`](spec/).
4. Genuinely unsettled exploration that matches none of the above? →
   [`scratch/`](scratch/).

## Everything settled amends `spec/`

Put every settled instruction, agreement, library choice, convention, and preference in
[`spec/`](spec/). Write the rule at the length it was given. Do not add a reason or an
alternative the user did not state. A one-sentence rule such as "use RESTful routes" is
complete. Do not create a separate ruling artifact.

**Read the relevant spec before working, and comply.** Raise a wrong spec with the user
and amend it. Do not reopen, annotate, or route around a spec because it differs from a
common default or personal preference.

Record agreed but unimplemented behavior in `spec/` and mark the affected section as
intended or target. Remove abandoned behavior from the spec.

Files in `vendor/`, `guides/`, and `spec/` are living documents updated in place.
Files in `scratch/` are dated and disposable under that folder's lifecycle rules.

**Read a folder's `README.md` before writing there.** It defines the folder's filing
test, filename format, and lifecycle. The repository's always-loaded instructions point
here as the docs index.
