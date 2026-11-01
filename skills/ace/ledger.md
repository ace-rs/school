# Procedure evidence

Use this contract when a skill points here. Numbered steps run in order, including any
branch or Wait the procedure names. Do not print a marker for each step.

1. **Retain decisions.** Keep each decisive command result, changed file, plan, user
   authorization, or report in the conversation or named durable artifact. Quote the
   user's exact words when they authorize a gated action or settle a durable decision.
2. **Resolve branches.** Record the condition that selected each branch. If a prerequisite
   is missing, return to the earliest step that can establish it. If that step requires
   the user's words, mark it as a Wait and stop the dependent work.
3. **Prove completion.** Report verification and audit evidence before claiming
   completion. Record durable evidence in the target artifact when the conversation will
   not survive.

At a handoff or pause, state the decisive evidence and next phase in concise ordinary
prose.

## Items presented to the user

An item is anything the user will be asked to rule on: a finding, a pending task, an
open choice, a blocker.

- **I1. Write what you can see.** When raising an item, record what you noticed and
  where, what you checked and its result, and the decision you could not make. A thin
  entry written mid-task is expected; record it anyway.
- **I2. Build context before presenting.** Treat the entry as a starting point. In a
  fresh pass, read the specs, code, instructions, and earlier rulings that govern it. A
  claim from a report, log, or another agent is a claim to verify, not a question to
  forward.
- **I3. Decide what the context allows.** An item needs the user only when their answer
  would change the outcome and nothing available settles it. Take one branch:
  - **Answered** — a stated rule, principle, decision on record, or earlier ruling
    settles it. Record the answer as `proposed`, cite what answers it, do not ask.
  - **Invalid** — the premise is wrong, the item is moot, or it is already done. Drop it
    and report it in one line.
  - **Testable** — a check you can run settles it. Run a read-only check now; otherwise
    record the check as `proposed` and present the result, not the question.
  - **Narrowed** — part of it is settled. Assume that part as under Answered and present
    only the remaining question.
  - **True fork** — no rule points one way, two rules conflict, the answer introduces a
    concept the user has not named, or the user reserved the decision. Present it with
    its context, the condition that applies, the rule involved, and a recommendation.
