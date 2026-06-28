---
name: ace-afk
description: >
  Unattended autonomous mode — the nightshift. Drive work forward with no human
  watching, strictly inside a safety envelope, logging blockers instead of
  waiting on them. TRIGGER on `/ace-afk`, "afk", "going afk", "stepping away",
  "run unattended", "work overnight", "nightshift", or "keep going while I'm
  gone". DO NOT TRIGGER while you're in an interactive back-and-forth, for the
  normal attended `/ace` loop, or when the user is present to approve steps.
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

A boundary you'd have to cross to make progress is a blocker. Log it, don't cross
it.

## Pre-flight — before the unattended loop engages

Run this while the human is still reachable. It front-loads every decision so the
unattended body needs none. This phase is the *only* sanctioned asking window.

1. **Restate the understood end-goal.** "Understood: <goal>." Include the definition of
   *done* — the real deliverable in the real target (the repo actually changed, the thing
   actually live), never a /tmp render or staged plumbing. If the goal is ambiguous, this is
   the moment to ask.
2. **Clear blockers — go HARD.** Surface and resolve every fork, missing input, and decision
   now, while the human can answer. This is where all the asking is spent; the body gets
   none. Apply **Earn the blocker** before flagging anything as needing the human.
3. **Establish the decision-basis.** State the philosophy the run resolves forks against,
   derived from the repo's CLAUDE.md + the goal. This is what makes "no questions after Go"
   safe rather than reckless: the body resolves forks against the basis and records the
   choice, instead of stopping to ask.
4. **State the AFK plan, then wait for explicit "Go."** Go is the last gate. After it: no
   questions, no go-gate — drive the loop to the envelope.

## Run the loop

After Go, read `workflow-afk.md` in this skill's directory and drive it autonomously to
the envelope below. It is the ace workflow with every propose/confirm gate already removed —
no stop-to-ask, no stop-to-plan. Honor `$ARGUMENTS` as the focus if given.

## Heartbeat — survive a silent stall

An unattended run can quietly come to rest before it's done: a subagent dies and leaves you
waiting on a reply that never comes, a turn ends without queuing the next, or you pause to ask
a question the decision-basis already answers. No human is watching to nudge you, so set up an
external nudge before you start.

Right after Go, schedule a recurring **heartbeat** using whatever timer the harness provides —
a cron / scheduled-prompt feature, a recurring self-message, or an external timer that injects
a line into the session. Fire it roughly every 10 minutes (pick an off-round interval if the
harness offers one). Each heartbeat re-enters the session with a prompt to this effect:

> AFK heartbeat. If the run has stalled — waiting on a dead subagent, stopped between turns, or
> paused to ask something the decision-basis or envelope already settles — resume the loop now.
> You hold standing authority to make safe, reversible decisions on your own: resolve the fork
> by the basis, record it, keep going. Log only a genuine blocker (basis-silent, expensive,
> irreversible). If the run is actually complete, tear down this heartbeat and write the final
> summary.

Note the job's id/handle when you create it — the final step removes it.

This is best-effort by design: a heartbeat lands when the session is between turns, so it
revives a run that has come to rest and re-grounds you in the autonomous-decision protocol. A
hard hang in the middle of one operation is the harness's own timeout to break, not the
heartbeat's — what the heartbeat reliably catches is the common case where the agent simply
stopped.

## Long runs — protect context

An unattended run can go for hours; context is the scarce resource. On harnesses
that support it:

- **Turn auto-compact on.** A nightshift run will outlast a single context window;
  without it the run dies mid-work when context fills.
- **Delegate to subagents by default.** This is the default operating mode, not an
  optimization: push every edit, search, and research step to a subagent and keep only
  its summary. The point is the *driver's* context — the main session runs the afk loop
  and must stay thin, or it compacts mid-run and loses the thread. The reason is context
  churn, not throughput, so even a single sequential task goes to a subagent. Spawning for
  speed and parallelism is still encouraged on top of this.

## Don't block — log it

When work genuinely needs a human — ambiguous spec, a judgment call you can't
safely default, or an envelope boundary — append a blocker to the handoff report
(below), then pick up the next unblocked work. Never stall the run on one blocked
item.

**Earn the blocker.** Before logging any blocker for a missing input — example, fixture,
dependency, test target — earn it first: fetch a public sample, download a real package,
write a dummy/stub, build the minimal scaffolding yourself. Only a resource you genuinely
cannot obtain or build is a real blocker.

**Keep making progress.** A finished goal or a clean checkpoint is where you pick up the next
thing, not where you stop and report-and-ask. While there's work you can start inside the
envelope and state rules — no unresolved decision, no unearnable blocker — start it and keep
going. Resolve discretionary forks by the decision-basis, record the choice, drive on.

## Stop conditions

Loop until out of unblocked work or out of token budget. When the run genuinely ends, **tear
down the heartbeat** (delete the scheduled job/timer) so it stops pinging a finished session,
then write the run summary into the handoff report.

## The handoff report — `.afk.log`

One file at the repo root (same convention as `ace-connect`'s `.inbox.log`) — the
human's morning read. Two parts:

- **Blockers** — appended live as they arise. Each entry records enough to unblock
  in one read: **what** (task and where it stopped), **why it can't be self-unblocked**
  (the decision-basis doesn't resolve it, no prior discussion settles it, and the input
  can't be earned — it genuinely needs the human), and **what you'd do** (recommended
  resolution, so a one-word reply unblocks it).
- **Summary** — written when the run ends: what landed (commits, tasks done) and
  what's still queued. Don't re-list blockers here; they're already above.
