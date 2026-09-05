# Guides

Store task-oriented instructions that take a human or agent through one real task from
start to finish. Include product use and repository operations. Answer "how do I do X?"

Route third-party command or API reference to `../vendor/` when that folder exists.
Otherwise report the missing destination and stop. Route the project's own config, CLI,
API, architecture, and design to `../spec/`.

For repeated operations, put deterministic steps in `scripts/*.sh`. Keep the invocation,
preconditions, decisions, and verification in the guide.

## Format

Use one file per task: `<slug>.md`. Keep each guide to one job, link to exhaustive
reference, and update the guide in place.
