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

## Run the loop

Read `workflow.md` in the `ace` skill directory and drive it autonomously, with
one substitution: every "Stop. Wait for approval" gate is replaced by the
envelope. Forward motion is the default, not approval. Honor `$ARGUMENTS` as the
focus for the run if given; otherwise discover work via the storage cascade.

## Don't block — log it

When work genuinely needs a human — ambiguous spec, a judgment call you can't
safely default, or an envelope boundary — append a blocker to the handoff report
(below), then pick up the next unblocked work. Never stall the run on one blocked
item.

## Stop conditions

Loop until out of unblocked work or out of token budget. On stop, write the run
summary into the handoff report.

## The handoff report — `.afk.log`

One file at the repo root (same convention as `ace-connect`'s `.inbox.log`) — the
human's morning read. Two parts:

- **Blockers** — appended live as they arise. Each entry records enough to unblock
  in one read: **what** (task and where it stopped), **why it needs a human** (the
  specific decision or boundary), and **what you'd do** (recommended resolution, so
  a one-word reply unblocks it).
- **Summary** — written when the run ends: what landed (commits, tasks done) and
  what's still queued. Don't re-list blockers here; they're already above.
