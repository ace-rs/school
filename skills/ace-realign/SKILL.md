---
name: ace-realign
description: >
  Repeat a broken loaded rule every turn until the user stops it. TRIGGER on "realign"
  when the user cites a broken rule, or automatically on the second session violation of
  the same rule marked hard or non-negotiable. DO NOT TRIGGER for new rule capture or
  disagreement without a cited rule; on the automatic path, exclude first violations and
  ordinary rules.
---

# ace-realign

Print `## ace-realign` as the first line.

Use **Arm a rule** (A1–A3) for the first active rule, **Stack a rule** (S1–S2) for
another violation while armed, and **Stop** (X1) only on the user's instruction.

## Arm a rule

- **A1. Select the rule.** On explicit "realign," select the loaded rule the user says
  was broken. On the automatic path, select only the same hard or non-negotiable rule
  broken for the second time this session. Do not auto-arm for an ordinary rule, a first
  violation, or a rule marked only for monitoring. Honor the rule's stated scope.
- **A2. Cite it.** Name the rule and its loaded source. Quote the exact rule when short.
  For a long rule, quote a self-contained verbatim excerpt that preserves its condition
  and command. If the cited rule is not in a loaded surface or an explicit earlier user
  instruction, report the missing prerequisite and do not arm.
- **A3. Repeat it.** Put `> Realign: <rule text>` once at the chosen edge of every
  message. Keep the same edge and wording across tasks until the session ends or the user
  stops it. If one message omits the line, restore it in the next message; the omission
  never disarms the rule.

## Stack a rule

- **S1. Add it.** When another rule meets A1 while realignment is active, run A2 for that
  rule and add it without replacing an active rule.
- **S2. Repeat all.** Print every active `> Realign:` line at the same chosen edge of each
  message.

## Stop

- **X1. Disarm.** Remove a realignment only when the user says to stop it or the session
  ends. If the user names one of several active rules, remove only that rule. The user's
  stop instruction is the completion evidence.

## Completion contract

Arming completes when the source citation and first `> Realign:` line appear. Stacking
completes when every active line appears together. The active line on each later message
is continuing evidence. If lasting behavior across sessions is required, persist the rule
through a separate authorized edit to an always-loaded repository or user instruction
surface.
