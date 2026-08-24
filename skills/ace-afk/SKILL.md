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
  in their words. Calls you make alone stay in `.ace/save.ledger.md` stamped
  `agent:inferred`. Writing a spec is allowed only when that was the task handed
  to this run.

A boundary you'd have to cross to make progress is a blocker. Log it, don't cross
it.

## Pre-flight — before the unattended loop engages

Run this while the human is still reachable. It front-loads every decision so the
unattended body needs none. This phase is the *only* sanctioned asking window.

The four steps run as a stamp chain: read `ace/ledger.md` — in the `ace` skill's
directory, sibling to this one — and follow its contract (one emitted stamp to close each
step; reprint the prior stamp to enter the named next step, reusing an immediately preceding
emission instead of duplicating it; no skips). Step 4 is a Wait: the run body opens only
with the user's "Go" quoted in its entry.

1. **Restate the understood end-goal.** "Understood: <goal>." Include the definition of
   *done* — the real deliverable in the real target (the repo actually changed, the thing
   actually live), never a /tmp render or staged plumbing. If the goal is ambiguous, this
   is the moment to ask.
2. **Clear blockers — go HARD.** Surface and resolve every open choice and missing input
   now, while the human can answer. This is where all the asking is spent; the body gets
   none. Apply **Earn the blocker** before flagging anything as needing the human.
3. **Establish the decision-basis.** State the philosophy the run resolves open choices
   against, derived from the repo's CLAUDE.md + the goal. This is what makes "no questions
   after Go" safe rather than reckless: the body resolves choices against the basis and
   records the call, instead of stopping to ask.
4. **State the AFK plan, then wait for explicit "Go."** Go is the last gate. After it: no
   questions, no go-gate — drive the loop to the envelope.

## Run the loop

After Go, read `workflow-afk.md` in this skill's directory and drive it autonomously to
the envelope below. It is the ace workflow with every propose/confirm gate already
removed — no stop-to-ask, no stop-to-plan. Honor `$ARGUMENTS` as the focus if given.

## Heartbeat — survive a silent stall

1. Right after Go, schedule a recurring prompt on whatever timer the harness provides —
   a cron / scheduled-prompt feature, a recurring self-message, or an external timer that
   injects a line into the session. Roughly every 10 minutes; pick an off-round interval
   if the harness offers one.
2. Note the job's id or handle. Step 4 needs it, and the run body's first stamp must
   quote it — a first stamp quoting no job id means the heartbeat never armed; go
   back and arm it.
3. Fire this text each time:

   > AFK heartbeat. If the run has stalled — waiting on a dead subagent, stopped between
   > turns, or paused to ask something the decision-basis or envelope already settles —
   > resume the loop now. You hold standing authority to make safe, reversible decisions
   > on your own: resolve the choice by the basis, record it, keep going. Log only a
   > genuine blocker (basis-silent, expensive, irreversible). If the run is actually
   > complete, tear down this heartbeat and write the final summary.

4. When the run ends, delete the job so it stops pinging a finished session.

A heartbeat lands when the session is between turns, so it revives a run that has come to
rest. A hard hang in the middle of one operation is the harness's own timeout to break.

## Long runs — protect context

An unattended run can go for hours; context is the scarce resource. On harnesses
that support it:

- **Turn auto-compact on.** A nightshift run will outlast a single context window;
  without it the run dies mid-work when context fills.
- **Delegate to subagents by default.** Push every edit, search, and research step to a
  subagent and keep only its summary. The main session runs the afk loop and must stay
  thin, or it compacts mid-run and loses the thread — so delegate even a single
  sequential task. Spawning for speed and parallelism is encouraged on top of this.

## Don't block — log it

When work genuinely needs a human — ambiguous spec, a judgment call you can't
safely default, or an envelope boundary — append a blocker to the handoff report
(below), then pick up the next unblocked work. Never stall the run on one blocked
item.

**Earn the blocker.** Before logging any blocker for a missing input — example, fixture,
dependency, test target — run this gate, and log only if both moves fail:

1. Obtain the real thing into the working tree or `/tmp` — a public sample, fixture, or
   dataset. The envelope still holds: no global package manager, no system install. If
   obtaining it would cross the envelope, that crossing *is* the blocker — log it.
2. Build a stand-in — a stub, a dummy, or minimal scaffolding.

**Keep making progress.** A finished goal or a clean checkpoint is where you pick up the
next thing, not where you stop and report-and-ask. While there's work you can start inside
the envelope and state rules — no unresolved choice, no unearnable blocker — start it
and keep going. Resolve discretionary choices by the decision-basis, record the call,
drive on.

## Stop conditions

Loop until out of unblocked work or out of token budget. When the run genuinely ends, tear
down the heartbeat (Heartbeat step 4), then write the run summary into the handoff report.

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
