---
name: ace-realign
description: Two-mode realignment protocol. TRIGGER on "realign" (force re-attention by repeating a broken rule at start or end of every message) or "realign fix" (trace the prompt-chain cause and edit the right context surface — project CLAUDE.md, user CLAUDE.md, memory, in-repo docs, or a skill — so the failure doesn't recur for future sessions or other agents).
---

# Realignment Protocol

Two modes. Pick by trigger phrase. The selection guidance below each mode header
tells you when to switch.

---

## Mode 1 — Repeat ("Realign")

The user invokes this mode by saying **"Realign"** when you have broken a rule
(from CLAUDE.md, a loaded skill, or an explicit user instruction earlier in the
session).

**Use this mode when:** the rule already exists in the right context surface
(project CLAUDE.md, user CLAUDE.md, a skill, or an explicit earlier instruction
in this session) and you failed to apply it. The fix is forced re-attention —
repetition keeps the rule in working context every turn.

**Switch to fix mode if:** the rule isn't actually written down anywhere it will
be loaded automatically, or it lives in a surface that future sessions / other
agents / other humans on the project won't see (e.g. mentioned only in chat, or
buried in memory when it should be in project CLAUDE.md). Repetition won't help
the next session — editing the surface will.

When triggered:

1. **Identify the broken rule.** Name it explicitly and cite where it came from
   (e.g. "Edit protocol — CLAUDE.md Workflow section"). Quote the rule verbatim
   if short; paraphrase tightly if long.
2. **Repeat the rule at the start or end of every message going forward.** Use a
   short, consistent format, e.g. `> Realign: <rule text>`. Place it once per
   message — start or end, pick one and stay consistent.
3. **Keep doing (2) until the session expires or the user tells you to stop**
   (e.g. "stop realigning", "you can drop the realign", "clear"). Do not
   self-terminate the protocol — it persists across tasks and topic switches.

If the user says "Realign" again while the protocol is already active, treat it
as a new violation: identify the new rule, and from then on repeat **both**
rules in every message (stack them, do not replace).

---

## Mode 2 — Fix ("Realign fix")

The user invokes this mode by saying **"Realign fix"** (or "Realign root", or
similar) when a wrong action has happened and they want the *cause* repaired,
not just re-flagged.

**Use this mode when:** the wrong action happened because the right context was
missing, lived in the wrong surface, was overridden by stronger competing
context, or was ambiguous enough that the LLM defaulted to a wrong inference.
The fix is editing a context surface so future sessions, other agents, and
other humans on the project all see the correction.

**Switch to repeat mode if:** the rule already exists in the right surface and
the failure was pure non-compliance, not a context defect. Editing nothing-is-
wrong won't help; repetition will force adherence for the rest of the session.

When triggered, do these steps in order. Skip nothing.

1. **Trace the prompt chain.** Identify which inputs most plausibly produced
   the wrong action. Candidates: project CLAUDE.md, user CLAUDE.md, loaded
   skills, memory entries, the recent assistant turn, the user's recent turn,
   tool result content, default LLM tendency. State the trace as a *context
   defect* — what was loaded, what was missing, what was ambiguous, what
   anchored the wrong inference. Do not write apology, admission of guilt, or
   self-criticism. Those are no-ops for an LLM; only context changes alter
   future behavior.
2. **Pick the right surface for the corrective context.** Default heuristics:
   - **Project CLAUDE.md** — repo-specific architecture facts, conventions,
     procurement/build commands, ownership of which-fix-goes-where. Benefits
     every agent and human who enters the tree. Default for repo facts.
   - **User CLAUDE.md** (`~/.claude/CLAUDE.md`) — cross-project agent-behavior
     rules (tone, workflow, edit protocol, tool-use defaults). Use when the
     defect would recur across unrelated projects.
   - **Skill** (`~/.claude/skills/<name>/SKILL.md` or project-local) — when the
     fix is a multi-step procedure or a triggerable mode rather than a single
     rule.
   - **In-repo docs / specs** — design decisions, runbooks, rollout plans
     readable by humans without an LLM in the loop.
   - **Memory** — user-specific preferences, in-flight project state, or
     references that won't help other humans/agents. **Not** for repo-
     architecture facts that other contributors need.
   When in doubt between memory and project CLAUDE.md for a repo fact, prefer
   project CLAUDE.md — it's checked in, reviewable, and visible to everyone.
3. **Propose the minimal edit.** State exactly which file, which section, what
   text. Aim for the smallest change that closes the defect — no broader
   refactor, no extra rules. Wait for explicit approval before writing.
4. **Apply on approval.** Make the edit. Confirm with a brief diff stat.

If the user invokes "Realign fix" multiple times in a session, treat each as an
independent root-cause analysis — don't bundle them into a single edit unless
they share the same surface and the user agrees.
