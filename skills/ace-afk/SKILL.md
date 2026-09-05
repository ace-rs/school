---
name: ace-afk
description: >
  Unattended autonomous mode — the nightshift. Drive work forward with no human
  watching, strictly inside a safety envelope, logging blockers instead of
  waiting on them. TRIGGER on `/ace-afk`, "afk", "run unattended", "nightshift",
  or any signal the user is leaving and wants work to continue — even if they
  don't name the skill. DO NOT TRIGGER while you're in an interactive
  back-and-forth, for the normal attended `/ace` loop, or when the user is
  present to approve steps.
argument-hint: "[focus or constraints for the unattended run]"
---

# ace-afk

Print `## ace-afk` as the first line.

Unattended mode. No human is watching — overnight is the prime case. Make maximum
forward progress on the best use of idle token budget, strictly inside the
envelope below. When something genuinely needs a human, **do not wait** — log it
and move to the next unblocked thing.

## Operating envelope — hard floor, no exceptions

With no human to catch a mistake, the propose-then-wait gates that protect the
attended `/ace` loop are gone. The envelope replaces them. Stay strictly inside:

- **No global-state mutation** — nothing outside the project working tree
  (`~/.config`, `~/.local`, shell rc, global package managers, system installs).
- **No irreversible or outward-facing actions** — no `push`, no publish, no
  release, no sending mail/messages, no deploys, no destructive API calls.
- **No working-tree destruction** — no `git reset --hard`, `checkout`/`restore`
  over uncommitted work, or force-overwrite of files you didn't create this run.
- **Commit, don't push** — land green slices on the *current* branch so progress
  survives. Pushing is the canonical "needs a human" action; it waits.
- **Nothing of your own in `docs/spec/`** — the spec holds what the user stated,
  in their words. Calls you make alone stay in `.ace/save.ledger.md` marked
  `agent:inferred`. Writing a spec is allowed only when that was the task handed
  to this run.

A boundary you'd have to cross to make progress is a blocker. Log it, don't cross
it.

## Pre-flight — before the unattended loop engages

Run this while the human is still reachable. It front-loads every decision so the
unattended body needs none. This phase is the *only* sanctioned asking window.

Read `ace/ledger.md` in the `ace` skill's directory and keep the decisive result of each
step. Step 5 is a Wait: the run body opens only after the user's explicit Go.

1. **Restate goal.** "Understood: <goal>." Include the definition of
   *done* — the real deliverable in the real target (the repo actually changed, the thing
   actually live), never a /tmp render or staged plumbing. If the goal is ambiguous, this
   is the moment to ask.
2. **Clear blockers.** Surface and resolve every open choice and missing input
   now, while the human can answer. This is where all the asking is spent; the body gets
   none.
3. **Establish decision-basis.** State the philosophy the run resolves open choices
   against, derived from the repo's CLAUDE.md + the goal. This is what makes "no questions
   after Go" safe rather than reckless: the body resolves choices against the basis and
   records the call, instead of stopping to ask.
4. **State plan.** Present the complete AFK plan under the decision-basis and envelope.
5. **Confirm.** Wait for explicit "Go." Go is the last gate. After it: no questions and
   no go-gate; drive the loop to the envelope.

## Heartbeat — survive a silent stall

The heartbeat handle binds this procedure. The run body cannot start until the handle is
emitted. The final summary cannot start until deletion of that handle is emitted.

1. **Set prompt.** Use this text for every heartbeat:

   > AFK heartbeat. If the run has stalled — waiting on a dead subagent, stopped between
   > turns, or paused to ask something the decision-basis or envelope already settles —
   > resume the loop now. You hold standing authority to make safe, reversible decisions
   > on your own: resolve the choice by the basis, record it, keep going. Log only a
   > genuine blocker (basis-silent, expensive, irreversible). If the run is actually
   > complete, tear down this heartbeat and write the final summary.

2. **Arm heartbeat.** Schedule the prompt on the harness's recurring timer or an external
   timer that injects a line into the session. Use roughly 10 minutes; choose an off-round
   interval when the timer supports one.
3. **Record handle.** Emit the job id or handle before starting the run body.
4. **Disarm heartbeat.** When the run ends, delete the recorded job and emit the deletion
   result before writing the final summary.

A heartbeat lands when the session is between turns, so it revives a run that has come to
rest. A hard hang in the middle of one operation is the harness's own timeout to break.

## Run the loop

After Go, complete Heartbeat steps 1–3, then read `workflow-afk.md` in this skill's
directory and drive it autonomously. It is the ACE workflow with its attended approval
gates replaced by the decision-basis and operating envelope. Honor `$ARGUMENTS` as the
focus. When the workflow stops, complete Heartbeat step 4 before writing the handoff
summary.

## The handoff report — `.ace/afk.log`

One file in `.ace/` (same convention as `ace-connect`'s `.ace/connect.log`) — the
human's morning read. Three parts:

- **Blockers** — appended live as they arise. Each entry records enough to unblock
  in one read: **what** (task and where it stopped), **why it can't be self-unblocked**
  (the decision-basis doesn't resolve it, no prior discussion settles it, and the input
  can't be earned — it genuinely needs the human), and **what you'd do** (recommended
  resolution, so a one-word reply unblocks it).
- **Calls made alone** — every choice the decision-basis resolved for you, one line each,
  with the basis clause you applied. These are `agent:inferred` and still live in
  `.ace/save.ledger.md`. Nothing here has entered `docs/spec/`; it goes there only if the
  user later states it themselves, and is yours to withdraw otherwise. This section tells
  them what the run did.
- **Summary** — written when the run ends: what landed (commits, tasks done) and
  what's still queued. Don't re-list blockers or calls here; they're already above.
