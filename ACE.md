# ACE Skills

ACE (Accelerated Coding Environment) is the session orchestration harness this school
plugs into. The five skills below cover the full workflow lifecycle — starting, saving,
recovering, realigning, and contributing back.

| Skill                                          | Role                                                                       |
|------------------------------------------------|----------------------------------------------------------------------------|
| [`ace`](skills/ace/SKILL.md)                   | Entry point — resume or start the workflow; surface the next task.         |
| [`ace-save`](skills/ace-save/SKILL.md)         | Checkpoint session state before `/clear`, exit, or context switch.         |
| [`ace-audit`](skills/ace-audit/SKILL.md)       | Recovery — re-enter the workflow's review step when a diff slipped.        |
| [`ace-realign`](skills/ace-realign/SKILL.md)   | Force re-attention on a broken rule, or repair the context surface.        |
| [`ace-school`](skills/ace-school/SKILL.md)     | Propose skill changes back to the school via PR.                           |

## `ace` — workflow entry point

Starts or resumes the ACE workflow. Loads at session start, after `/clear`, between tasks,
or when the user signals continuation at a session boundary ("go", "continue", "next",
"resume"). Stays silent when those cues refer to the in-flight edit or step instead of a
session boundary.

## `ace-save` — session checkpoint

Persists in-flight session state to durable storage so the next `/ace` resumes cleanly.
Triggered by "save session", "checkpoint", "before I clear", "wrap up", or any signal that
a `/clear` or exit is imminent. Writes session notes only — not a substitute for `git
commit`.

## `ace-audit` — workflow recovery

Re-enters the audit step in `ace/workflow.md` when a diff landed without passing
through review. Triggered by `/ace-audit` or any request to audit, review, or check
work against skill compliance.

## `ace-realign` — rule re-attention or context repair

Two modes. **"Realign"** identifies a broken rule and repeats it at the start or end of
every message until the session ends or the user says stop. **"Realign fix"** traces the
prompt-chain cause of a wrong action and edits the right context surface (project
CLAUDE.md, user CLAUDE.md, memory, in-repo docs, or a skill) so the failure doesn't recur
for future sessions or other agents.

## `ace-school` — contribute back

Proposing skill changes, creating PRs to the school repo, understanding school structure.
Triggered when the user wants to propose changes, create a school PR, run `ace diff`, or
asks about school structure/workflow.
