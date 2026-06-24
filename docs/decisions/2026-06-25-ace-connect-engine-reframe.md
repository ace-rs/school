# ace-connect is an engine you start, not a listener you optionally run

- **Date:** 2026-06-25
- **PR:** manual (commits f1fceab, d45b486)
- **Status:** accepted

## Decision

ace-connect is framed as an **engine each agent must start before it can do
anything** — send, receive, or discover. The receive script is `start.sh` (was
`listen.sh`), and the skill's one rule is "start before you do anything."
Corollaries: mode is resolved by signal (stated → infer-from-role → ask, control
as the floor) rather than always-asked; and we deliberately do **not** design the
skill to accommodate a future native `ace connect` command.

## Rationale

- **"Listen" framed binding as optional; that was the bug.** "Listener" reads as
  a receiver-side chore you do *if* you expect mail. But sending depends on it
  too: the peer replies to your `from=`, and that reply needs a live socket. The
  decision to receive isn't yours to skip — the *peer* decides whether to reply.
  Cold-sending (asked to "tell X" before binding) produced a `from=` nobody could
  reply to, and replies bounced silently. "Start the engine" makes binding the
  unskippable ignition, killing the whole bug class rather than the one instance.
  `send.sh` also now warns when the sender has no live engine, as a backstop.

- **Why not keep "listen" and just add a precondition rule?** A procedural "always
  bind first" rule is the kind of step agents skip — the description even triggers
  on "tell/send to X", which let an agent enter at the send step. Changing the
  *mental model* (engine) fixes it at the concept layer; a rule bolted onto the
  old framing does not.

- **Mode: infer-else-ask, not always-ask.** Log mining showed the user almost
  always states mode inline ("autonomous mode, …") or implies it by role ("answer
  but don't edit" → control). Always-asking re-prompts for what was already said;
  silently defaulting guesses a consequential, start-time-baked setting. Resolve
  by signal, ask only when truly blank. Because the user reliably *says*
  "autonomous" when they want it, its absence is itself signal — so control is the
  floor.

- **Why not design for native `ace connect`?** The obvious instinct is to leave a
  transport seam so a future native `ace connect` can slot in. We reject that: if
  native lands it almost certainly *subsumes* the skill wholesale rather than
  slotting into seams, so any forward-compat abstraction is dead weight in both
  outcomes (never ships → unused; ships → skill deleted). Keep it concrete and
  shell-shaped. A future agent seeing the shell scripts may assume we should have
  abstracted — this entry says we considered it and chose not to.

## Notes

- Trigger utterances were aligned to the user's real words from the log (`start`,
  `listen for`, `wait for`, `answer queries`); the author-coined "tell/send to X"
  was dropped. `"listen for messages"` survives only as a trigger phrase the user
  actually types — not as internal mechanism naming.
- Wire format + dialect moved to `references/dialect.md` so the format no longer
  reprints on every Monitor notification.
