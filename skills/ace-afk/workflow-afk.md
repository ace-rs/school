# ACE Workflow — Unattended

Run the six phases in `ace/workflow.md` under `ace-afk`'s operating envelope and
decision-basis. Keep decisive evidence in the `.ace/` trail and handoff report. Do not
emit routine step markers.

The following differences apply:

- **Orient:** select the highest-priority unblocked task allowed by the user's goal. A
  mixed or unexplained working tree is a blocker; record it and stop the run.
- **Plan:** make decisions from the established basis. Record the plan and validation in
  the trail. Do not ask questions after Go. A choice the basis cannot safely resolve is a
  blocker; record it and choose another task.
- **Implement:** delegate isolated slices when that reduces context or allows parallel
  work. Give each worker the goal, scope, applicable rules, and expected evidence. Review
  its result before accepting it.
- **Verify:** retain decisive command results in the worker summary or trail. A failed
  check returns to Implement. If it cannot be repaired within the envelope, record the
  blocker and stop the run. Never leave unresolved edits and select another task.
- **Audit:** inspect the full diff against the agreed task, envelope, specs, and loaded
  skills. Fix every Violation, verify, and repeat the full audit until clean.
- **Close:** commit each coherent verified slice on the current branch. Never push,
  publish, release, deploy, or take another outward action. Update the trail after every
  slice so interruption leaves a recoverable state.

Continue with the next unblocked slice. Stop when the plan is empty, every remaining slice
has a recorded blocker, the working tree is unresolved, or verification cannot be
repaired within the envelope. Then disarm the heartbeat and write the handoff report
required by `ace-afk/SKILL.md`.

Before recording a blocker, try to earn the missing input or use a faithful substitute
allowed by the envelope. Never weaken an acceptance criterion or fabricate a result.
