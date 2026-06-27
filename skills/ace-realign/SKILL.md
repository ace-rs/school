---
name: ace-realign
description: >
  Force re-attention on a rule you keep breaking — repeat it verbatim at the start
  or end of every message until the session ends or the user says stop. TRIGGER on
  "realign" when the user calls out a broken rule that already lives in a loaded
  surface (CLAUDE.md, a skill, an explicit earlier instruction). ALSO AUTO-TRIGGER
  without being asked: on the second violation of the same Law (a rule a loaded
  surface designates a Law) within a session, self-engage on that Law. DO NOT TRIGGER
  for first-time rule capture with no prior violation, when the user merely disagrees
  with an output rather than citing a broken rule, or — on the auto path — for
  watch-trends or a Law's first violation.
---

# Realignment Protocol

Print `## ace-realign` as the first line.

The user invokes this by saying **"Realign"** when you have broken a rule (from
CLAUDE.md, a loaded skill, or an explicit user instruction earlier in the session).
The fix is forced re-attention — repetition keeps the rule in working context every
turn.

This works only when the rule already lives in a surface that loads automatically. If
it isn't written down anywhere future sessions will see it, repetition won't help the
next session — edit the surface instead (project CLAUDE.md, user CLAUDE.md, a skill, or
in-repo docs).

## Auto-trigger on Laws (no invocation needed)

Some rules are designated **Laws** in a loaded surface — a CLAUDE.md may mark a Laws set
with global, per-repo, or session scope. Laws bind harder than ordinary instructions.

Each turn, self-audit your last action against the active Law set. On the **second**
violation of the **same Law** within a session, **arm this protocol immediately on that
Law** (run the steps below) — do not wait for the user to say "realign", do not make them
re-state the frustration. The first violation: fix it and move on, no arming.

Only **Laws** auto-arm. Watch-trends are self-monitored, never armed. Honor scope: a
session Law arms only within its phase, a per-repo Law only in its repo.

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
