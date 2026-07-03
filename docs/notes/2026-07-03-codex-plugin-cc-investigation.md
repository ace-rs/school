# openai/codex-plugin-cc — investigated for ace-connect fit

Prompted by: user asked to investigate the `codex-plugin-cc` Claude Code
plugin (install flow: `/plugin marketplace add openai/codex-plugin-cc`,
`/plugin install codex@openai-codex`, `/codex:setup`) as a possible fit for
`skills/ace-connect`'s experimental Codex backend
(`skills/ace-connect/references/codex.md`).

## What the plugin is

Real, OpenAI-maintained Claude Code plugin. Repo:
https://github.com/openai/codex-plugin-cc (inspected at commit
`80c31f99570876c3ef40327838b0a2ca1ae2cd9c`).

- Requires Node.js ≥18.18 and a Codex login (ChatGPT sub incl. Free, or API
  key).
- Wraps the **Codex app-server JSON-RPC protocol** — the same protocol
  `codex.md`'s `codex-app-bridge.sh` hand-rolls with `websocat`/`jq`/`socat`
  (`thread/start`, `turn/start`, etc.).
- Slash commands: `/codex:review`, `/codex:adversarial-review`,
  `/codex:rescue`, `/codex:transfer`, `/codex:status`, `/codex:result`,
  `/codex:cancel`, `/codex:setup`. Also ships a `codex:codex-rescue`
  subagent and an optional Stop-hook review gate.
- Repo layout: `plugins/codex/{agents,commands,hooks,prompts,schemas,
  scripts,skills}` — a Node-based app-server client lives under
  `plugins/codex/scripts/` (not read in detail — see Follow-up below).

## Verdict: does not replace ace-connect's Codex backend

The plugin is a **one-directional dispatch/poll** model: Claude Code spawns
a Codex app-server job, then polls `/codex:status` / `/codex:result` for
it. Codex never becomes an independently addressable peer that other
agents can push unsolicited messages to — there is no inbound "receive"
surface.

ace-connect's Codex backend needs the opposite: a **live, symmetric bus**
where a running Codex session can be messaged *and* reply on its own
initiative. This plugin architecturally cannot provide that — it can't
stand in for `scripts/codex.sh` / `codex-app-bridge.sh`.

## Where it IS useful (separate from ace-connect)

For the "delegate a task to Codex, come back later" pattern — which is
roughly what `codex.md`'s tool-harness one-shot-receive/re-arm loop
approximates by hand — `/codex:rescue --background` + `/codex:status` +
`/codex:result` is a strictly lower-effort, officially-maintained
replacement. Worth adopting standalone for that use case; it's orthogonal
to the ace-connect bridge and doesn't need to touch the skill.

## Follow-up not yet done

`plugins/codex/scripts/` almost certainly contains a working Node client
for the app-server protocol. It could answer the "Open Questions" at the
bottom of `skills/ace-connect/references/codex.md`:

1. How to identify the currently attached TUI thread when multiple are
   loaded.
2. Whether the same thread can accept input concurrently from TUI and
   bridge without state corruption.
3. Whether `turn/steer` is a better fit than `turn/start` for ace-connect
   injection (no need to wait for idle).

Not pulled down/read in this session — next session picking this up should
fetch `plugins/codex/scripts/` (and whatever it imports) from
`openai/codex-plugin-cc` and compare its thread-selection/turn-injection
approach against `codex-app-bridge.sh` before touching the bridge script.

## Action taken this session

Investigation only — no `/plugin marketplace add`, `/plugin install`, or
`/codex:setup` was run; nothing installed or mutated.
