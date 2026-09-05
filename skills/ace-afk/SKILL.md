---
name: ace-afk
description: >
  Run bounded work unattended inside a strict safety envelope. TRIGGER on `/ace-afk`,
  "afk", "run unattended", "nightshift", or when the user says they are leaving and
  wants work to continue. DO NOT TRIGGER during an attended workflow or interactive
  approval loop.
argument-hint: "[focus or constraints for the unattended run]"
---

# ace-afk

Print `## ace-afk` as the first line.

No human is available to answer after the run starts.

Use **Run unattended** (1–4) for one bounded goal with a defined stopping condition.

## Operating envelope

Stay inside every boundary below:

- **No global-state mutation** — nothing outside the project working tree
  (`~/.config`, `~/.local`, shell rc, global package managers, system installs).
- **No irreversible or outward-facing actions** — no `push`, no publish, no
  release, no sending mail/messages, no deploys, no destructive API calls.
- **No working-tree destruction** — no `git reset --hard`, `checkout`/`restore`
  over uncommitted work, or force-overwrite of files you didn't create this run.
- **Commit, don't push** — land green slices on the *current* branch so progress
  survives only when repository instructions already authorize autonomous local commits.
  Otherwise retain the reviewed diff. Pushing always waits.
- **Nothing of your own in `docs/spec/`** — the spec holds what the user stated,
  in their words. Calls you make alone stay in `.ace/save.ledger.md` marked
  `agent:inferred`. Writing a spec is allowed only when that was the task handed
  to this run.

A boundary required for progress is a blocker. Log it and do not cross it.

Read `ace/ledger.md` in the `ace` skill's directory before step 1. Keep the goal, plan,
authorization, heartbeat handle, workflow evidence, and handoff report as evidence.

## **1. Prepare the run**

Restate the bounded goal and define done as the real deliverable in its real target.
Resolve open choices and missing inputs while the user is present. Derive a decision basis
from the repository instructions and the goal. Verify that an existing, independently
operated timer or session delivery mechanism can be armed and disarmed. Settle local
commit authority when commits are part of done; otherwise make a retained reviewed diff
an explicit accepted end state. Present the complete plan, envelope, stop condition, and
verified heartbeat mechanism. Wait for explicit "Go." This is a Wait and the unattended
body cannot start without it. If the heartbeat prerequisite is missing, report the
blocker and stop before asking for Go.

## **2. Bind stall recovery**

Use an existing, independently operated external timer or session delivery mechanism that
can inject this prompt while the run is between turns:

   > AFK heartbeat. If the run has stalled — waiting on an unavailable dependency,
   > stopped between turns, or paused to ask something the decision-basis or envelope
   > already settles — resume the loop now. Continue only within the approved goal,
   > decision basis, and operating envelope. Resolve covered choices by that basis,
   > record them, and keep going. Infer no further authority. Log a genuine blocker when
   > those bounds do not permit progress. If the run is complete, disarm this heartbeat
   > and write the final summary.

Use roughly ten minutes and choose an off-round interval when available. Do not use a
harness scheduler or create timer infrastructure. Open by quoting the user's Go. Arm the
verified mechanism and record its job id or handle before step 3. If arming fails, record
the failure and whether a handle may remain, write an incomplete handoff, and stop without
starting the unattended body.

## **3. Run the approved loop**

Read `workflow-afk.md` in this skill's directory and run it under the approved decision
basis and operating envelope. Honor `$ARGUMENTS` as the focus. Ask no questions after Go.
Resolve covered choices from the basis and record them. Log a basis-silent, expensive,
irreversible, or otherwise forbidden choice as a blocker.

When the approved plan authorizes delegation and an existing worker channel is available,
delegate only isolated slices. Give each worker the goal, scope, applicable rules, and
required evidence. Review the result before accepting it. Do not create worker
infrastructure during the run.

## **4. Disarm and hand off**

Stop and record deletion of the heartbeat handle before writing the final summary. If
disarming fails, record the failure and remaining handle in `.ace/afk.log`, report that
the run is incomplete, and stop without claiming completion. Write `.ace/afk.log` as the
user's next-session read with three sections:

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

## Completion contract

The unattended run completes only when `workflow-afk.md` reaches a stop condition, the
heartbeat handle is deleted, and `.ace/afk.log` names landed work and remaining work. If
stall recovery is unavailable, preparation ends with the prerequisite blocker and no
unattended work starts.
