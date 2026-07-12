# Codex app-server bridge — protocol findings + live validation + redesign

## Status — 2026-07-12: reactive-only, settled

The forward truth for this track lives here. **§1–§9 below are the dated research
log** — mine them for protocol facts (durable and correct), but every "next steps" /
"pending changes" / "deferred" list inside them is **closed**, resolved by this
status. Don't act on those older agendas.

**Decision: reactive-only.** A codex on the bus answers peer messages; it does not
drive its own agenda. That deletes the "autonomous-swarm driver" outright — a
reactive codex needs no turn-injection loop, so there is nothing to build there.

**Receive contract — one-shot per peer message, no persistent driver:**

    initialize → thread/loaded/list → turn/start {threadId, input} → confirm turn/started → close

The `app-server` runs the agent loop itself; the bridge only injects. No draining,
no `turn/completed` tracking, no event scraping, no `thread/resume`/subscription on
the live path. Headless-no-human variant: if `thread/loaded/list` is empty, create a
thread first (`thread/start`), remember its id, reuse it for later messages — still
one-shot per message, still no loop.

**Reply-back = codex's own `send.sh` call, symmetric with Claude.** Claude's bridge
never scrapes Claude's output to reply — the agent calls `send.sh` itself and the
reply lands async on the sender's socket. Codex mirrors it exactly: `turn/start`
delivers, codex does the work, codex shells out to `send.sh`, the reply arrives on
the bus. The bridge does **not** subscribe-and-relay. Precondition (the real
constraint, not draining): `send.sh` reachable on PATH inside the app-server's
sandbox, and codex instructed via the ace-connect dialect to reply that way.

**Dead — do not revisit or resurrect:**

- the **autonomous / self-directed driver** — reactive-only removes the need;
- **reply-back by bridge subscribe/relay** of `item/agentMessage` + `turn/completed`
  — wrong model; codex self-replies;
- the validated **Node** rigs `codex-bridge.mjs` / `pty-inject-daemon.mjs` (§8) — no
  Node, rejected; findings kept, code not promoted;
- the **PTY-inject** track and **plain-codex** injection (§8.2–8.3) — never launch a
  plain codex for ace-connect; exposure is chosen at launch via `--listen`.

**Open — genuinely undecided:**

- **Sandbox/approval posture from ace-connect mode.** The server's launch owns
  cwd + sandbox (§4.3, §8.1); every injected peer turn inherits it. control →
  read-only; autonomous → workspace-write in-tree + carve-outs. Wire it into how
  `codex.sh` launches the app-server. This is the one real blocker.
- **Does codex reliably honor the dialect and call `send.sh`?** Unverified. If it
  drops replies, that is a dialect/prompt fix — not a reason to reintroduce scraping.

**Remaining edits to land, no new code beyond wiring:** sandbox posture into
`codex.sh`'s app-server launch per mode; `codex-app-bridge.sh` drop the
subscribe/relay reply path (keep get-thread + `turn/start`). Rig cleanup (outside
tree, per-path go): `~/Documents/ace-rs/codex-live-test/` + shallow clones
`~/Documents/ace-rs/{codex,codex-plugin-cc}`.

---

Continuation of [`2026-07-03-codex-plugin-cc-investigation.md`](2026-07-03-codex-plugin-cc-investigation.md)'s
"Follow-up not yet done". That note asked: fetch the codex-plugin-cc client, compare its
thread-selection / turn-injection against `skills/ace-connect/scripts/codex-app-bridge.sh`,
and answer the three open questions in `skills/ace-connect/references/codex.md`. This note
does that against real source, then **validates it live** on the installed binary.

Sources inspected (cloned as siblings of the school for this work):

- `~/Documents/ace-rs/codex` — `openai/codex`, shallow clone, tip `be33f80`. Rust
  workspace under `codex-rs/`. File:line refs below are from this tip; the binary tested
  was **0.142.5** (upgraded mid-session from 0.142.3), so treat refs as "current-ish,
  verify against the pinned tag if it matters".
- `~/Documents/ace-rs/codex-plugin-cc` — `openai/codex-plugin-cc`, Node client under
  `plugins/codex/scripts/`.
- Live test rig: `~/Documents/ace-rs/codex-live-test/` (`bridge-probe.mjs`,
  `launch-tui.sh`, isolated `workspace/`).

## TL;DR

The three open questions are answered; the July "brand-new v2/turn/steer" framing was
wrong (steer landed Feb 2026, PR #10821; v2 realtime thread API Feb 2026, PR #12715). The
real enabler is the **multi-client transport**: many clients attach to one
`codex app-server` and the server fans thread events out to all of them. A live test proved
a second client injects a turn into the thread an interactive TUI is driving, and the TUI
renders it. But the test also corrected two design assumptions (no daemon on a Homebrew
install; the *server* — not the TUI — owns cwd/sandbox).

---

## 1. Protocol reference (v2 app-server)

Wire dialect is JSON-RPC **without** a `jsonrpc` field. Request `{id, method, params,
trace?}`; response `{id, result|error}`; notification `{method, params}`
(`codex-rs/app-server-protocol/src/protocol/rpc.rs:46-88`). All v2 params are `camelCase`.
Method→type table: `client_request_definitions!` in
`app-server-protocol/src/protocol/common.rs`.

### Transport / multi-client

`AppServerTransport` (`app-server-transport/src/transport/mod.rs:72-78`): `Stdio |
UnixSocket | WebSocket | Off`, selected by `--listen URL` (`stdio://` default, `unix://`,
`unix://PATH`, `ws://IP:PORT`, `off`).

- **stdio** is one-owner (single stdin/stdout pair) — the model the current bridge and the
  plugin both fight.
- **unix socket** upgrades each connection to WebSocket and **spawns a task per
  connection** (`unix_socket.rs:46-91`); socket is `0o600`.
- **ws://** binds localhost TCP; each connection gets a monotonic `ConnectionId`
  (`mod.rs:194-198`).

Per thread the server holds `connection_ids: HashSet<ConnectionId>`
(`app-server/src/thread_state.rs:252-256`); one per-thread listener task snapshots the
subscriber set per event and sends to all of them
(`app-server/src/thread_lifecycle.rs:302-326`). **So a non-owning client sees events from
turns it did not start** — this is the whole basis for a bridge that observes what the human
does.

The **daemon** (`app-server-daemon`) does not change the wire protocol — it is a lifecycle
supervisor that keeps one managed app-server alive on a control socket and auto-updates it.
**It requires OpenAI's standalone installer** (see §4) and is unavailable on a Homebrew
install.

### Thread lifecycle (v2)

- `initialize` (still v1, `common.rs:467`) with `capabilities.experimentalApi = true` to
  unlock experimental methods/fields.
- `thread/list` — persisted threads, paged, filterable by `cwd`, `sourceKinds`,
  `searchTerm` (`common.rs:615`; `thread.rs:1067`).
- `thread/loaded/list` — **thread ids live in memory right now**
  (`thread.rs:1226-1247`). Best "what is the TUI running" probe. There is **no
  `thread/current`** — "active" is a per-thread `ThreadStatus` (`NotLoaded | Idle |
  SystemError | Active{activeFlags}`, `thread.rs:1249-1262`), not a server-global
  selection. Identify the TUI's thread = loaded/list ∩ metadata filter (cwd + status).
- `thread/resume {threadId}` — attaches + **subscribes** the connection, streaming history
  then live events with no gap (`thread.rs:305-438`; contract at `thread.rs:310-323`).
  Rejoins a running thread if the id names one. **Requires an on-disk rollout** (see §4
  correction).
- `thread/inject_items {threadId, items}` — append Responses-API items to model-visible
  history **without** starting a turn (`thread.rs:1289`). Seed context vs drive a turn.
- `thread/unsubscribe` — stop receiving a thread's events without closing the connection.

### Turn methods

- `turn/start {threadId, input:[UserInput], …}` → `{turn}` (`turn.rs:63-165`). `UserInput`
  is a `type`-tagged enum: `text|image|localImage|skill|mention` (`turn.rs:285-316`).
  **Subtlety:** core's start path calls `steer_input(expected_turn_id: None)`
  (`core/src/session/handlers.rs:183-233`) — so `turn/start` on a thread with an active
  turn **merges into it** rather than erroring; only `NoActiveTurn` spins a fresh turn.
  The current bridge's `turn/start` has therefore been doing *unguarded* mid-turn injection
  all along.
- `turn/steer {threadId, input, expectedTurnId}` → `{turnId}` (`turn.rs:167-201`).
  `expectedTurnId` is **required, non-empty** (`turn_processor.rs:863`). Thread-scoped, not
  connection-scoped — **a second client can steer a turn the TUI started**, gated only by
  the turn-id precondition, not ownership. Strictly safer than `turn/start` for injection:
  fails loudly (`ExpectedTurnMismatch`) instead of racing blind.
- `turn/interrupt {threadId, turnId}` (`turn.rs:203-214`).

`ActiveTurnNotSteerable {turnKind: review|compact}`
(`app-server-protocol/src/protocol/v2/shared.rs:105-111`; core
`core/src/session/mod.rs:3860`) is returned when the active turn is a `/review` or manual
`/compact` — the only non-steerable kinds. Regular turns steer fine. Delivered structurally
in the error `data`. **This is the answer to "concurrent input without corruption": the
server rejects unsafe injection with a typed error rather than corrupting state.**

### Events

Notifications catalog: `server_notification_definitions!` (`common.rs:1607-1684`).
Turn/thread-relevant: `turn/started` (carries the `turnId` you need for steer),
`turn/completed`, `thread/status/changed`, `item/started`, `item/completed`,
`item/agentMessage/delta`, plus server→client approval/input requests
(`item/*/requestApproval`, `common.rs:1456`).

### Versioning

v1 survives as the handshake + legacy approval/config types (v1 uses `conversationId`; v2
uses `threadId`). Everything thread/turn-shaped is v2. Experimental gating is per-method
and per-field via `#[experimental("…")]`; requires `capabilities.experimentalApi = true`.
`turn/steer`'s core fields (`threadId`, `input`, `expectedTurnId`) are **stable** — only
`responsesapiClientMetadata` / `additionalContext` are experimental (`turn.rs:184-188`).
`thread/resume.history` and `.path` are marked `[UNSTABLE]`.

**Recommended stable surface for the bridge:** `initialize` → `thread/loaded/list` →
`thread/resume {threadId}` → receive notifications → `turn/start` /
`turn/steer {expectedTurnId}` / `turn/interrupt`.

---

## 2. codex-plugin-cc — reusable patterns

The plugin (Node, `plugins/codex/scripts/`) is a one-directional dispatcher, not a symmetric
bus (see the 07-03 note's verdict), but its client is a solid reference.

- **Transport-abstract JSON-RPC-over-JSONL client** (`lib/app-server.mjs`): `pending` Map +
  monotonic id, `sendMessage` hook subclassed for stdio vs unix socket. It spawns
  `codex app-server` (stdio), framing = newline-delimited JSON (`app-server.mjs:190,268`).
- **Broker daemon** (`app-server-broker.mjs`): one long-lived app-server, N ephemeral CLI
  clients over a unix socket, single-flight arbitration — a second caller mid-turn gets a
  synthetic `-32001` "broker busy"; streaming methods hold ownership until `turn/completed`;
  `turn/interrupt` has a cross-socket carve-out. **We do not need this** — it exists because
  the plugin uses one-owner stdio servers. The `--listen` socket makes per-thread
  serialization the server's job.
- **Completion inference** (`lib/codex.mjs:373`, `captureTurn` at `:559`): `turn/completed`
  is unreliable with subagents, so it tracks `finalAnswerSeen` + pending-collaboration sets
  and arms a 250ms debounce. **Worth stealing** for the reply-back path.
- **Notification-before-response race** → buffer notifications until the turn id is known,
  then replay (`codex.mjs:591`). Worth stealing.
- It **creates its own threads** (`thread/start` / `thread/resume`, recognized by a
  `"Codex Companion Task"` name prefix) — it never attaches to the human's TUI thread. The
  opposite of what the bridge wants.
- Injection is **`turn/start` only** — no `turn/steer` anywhere in the codebase.

---

## 3. Current bridge — recap + stale assumptions

`skills/ace-connect/scripts/codex-app-bridge.sh` today: launches `codex app-server --listen
ws://127.0.0.1:0`, scrapes the port from the log, talks WebSocket via a `websocat` coprocess
through two FIFOs, and per accepted ace-connect socket line does `turn/start` with a wrapper
prompt on "the first loaded thread". The human TUI is a second client via `codex --remote`.

Assumptions a redesign should drop:

- **"first loaded thread == the TUI's thread"** (`.result.data[0]`) — replace with
  loaded/list ∩ cwd filter.
- **`turn/start` as injection primitive** — unguarded mid-turn merge; prefer `turn/steer`
  with `expectedTurnId` when a turn is active.
- **No turn-lifecycle tracking** — `rpc()` returns on the ack, never observes completion;
  cannot serialize or reply. Use `turn/started`/`turn/completed`.
- **Port scrape from log** — fragile; keep, but it is the only option (no daemon, §4).
- **Bridge writes no `.pid`** — invisible to `discover.sh`. Emit one.
- **Hardcoded `approvalPolicy:never, sandbox:workspace-write`** — must derive from
  ace-connect mode, and note §4: the *server launch* is what actually decides this.
- **Reply is a blind "delivered to thread N"** on the ack — no real answer flows back.
  Subscribe and relay `item/agentMessage` + `turn/completed`.

---

## 4. Live validation (2026-07-07, codex 0.142.5)

Rig: `~/Documents/ace-rs/codex-live-test/`. An isolated `codex app-server --listen
ws://127.0.0.1:8321` launched **from a throwaway `workspace/` dir** with
`-c approval_policy='"never"' -c sandbox_mode='"read-only"'`; an interactive TUI in a tmux
pane via `codex --remote ws://127.0.0.1:8321`; a second client `bridge-probe.mjs` using
**Node 22's built-in `WebSocket`** (no websocat).

Sequence and result:

1. `initialize` + `initialized` + `thread/loaded/list` over WS — **works on the Homebrew
   binary**. Empty until the TUI launched.
2. TUI launched, registered thread `019f31dd-…`; `thread/loaded/list` from the second client
   returned exactly that id. **→ Q1 mechanism confirmed live.**
3. `thread/resume {threadId}` **failed**: `no rollout found for thread id …` — the TUI's
   thread was loaded-in-memory but had zero turns, so no on-disk rollout to resume.
4. Skipped resume; `turn/start {threadId, input:[{type:text,text:…}]}` from the second
   client **succeeded** with an injected message telling codex it was a live bridge test and
   to touch nothing. Thread went `active → idle`.
5. TUI pane rendered the injected message as a user turn and codex's reply beneath it:
   *"Received via the ace-connect bridge; working directory:
   /Users/chakrit/Documents/ace-rs/codex-live-test/workspace"*. codex obeyed — no writes, no
   commands. **→ cross-client injection into the human's live thread proven end-to-end.**
6. Quit: `/quit` did nothing; **Ctrl-C ×2** closed the pane cleanly.

### Corrections the live test forced

1. **Daemon/`proxy` unavailable on Homebrew.** `codex app-server daemon start` hard-refuses:
   *"managed standalone Codex install not found at ~/.codex/packages/standalone/current/
   codex … Install it with: curl -fsSL https://chatgpt.com/codex/install.sh | sh"*. So the
   "dial the shared daemon control socket" simplification is **out** unless the user adopts
   OpenAI's installer. The bridge must keep launching its own `app-server --listen ws://…`
   — structurally the same shape as today.
2. **WebSocket transport, but Node ≥21's built-in `WebSocket` removes the `websocat`
   dependency.** Raw JSON to the socket gets silence (it upgrades to WS). A from-scratch
   bridge in Node needs no external WS tool.
3. **cwd + sandbox come from the *server's* launch, not the TUI's `--remote` flags.** First
   TUI run showed `directory: ~/Documents/ace-rs/school` purely because the app-server was
   launched from the school dir; `-c sandbox_mode` passed to the *TUI* was ignored. This is
   load-bearing for safety: **the bridge controls the autonomy/sandbox posture by how it
   launches the app-server, and every injected peer turn inherits the human's powers.** A
   server launched workspace-write means peer messages can write — a real security
   consideration for the ace-connect mode model.
4. **Reply-back and `turn/steer` gate on `thread/resume`, which needs a rollout.** A pristine
   never-run thread cannot be subscribed. Real bridge targets (threads with history) are
   fine, but a freshly created thread yields no event stream until it has ≥1 turn. Steer also
   needs the active `turnId`, only available via subscription — so the whole steer/reply path
   depends on resume succeeding.

---

## 5. From-scratch redesign

First-principles shift the live test *confirms* is still right: use the multi-client
`--listen` server; the human TUI and the bridge are co-equal WS clients on it. Corrections
above shape the rest.

| Concern       | Current bridge                                 | From-scratch                                                                 |
| ------------- | ---------------------------------------------- | ---------------------------------------------------------------------------- |
| Backend       | `app-server --listen ws://…:0`, scrape port    | Same (daemon unavailable on Homebrew). Node WS client, drop `websocat`       |
| Thread select | first loaded thread, blind                     | `thread/loaded/list` ∩ `cwd`/`status:Active` filter                          |
| Attach        | none                                            | `thread/resume {threadId}` when a rollout exists; tolerate `no rollout`      |
| Inject        | `turn/start` blind                             | `turn/steer {expectedTurnId}` when a turn is live; `turn/start` when idle    |
| Non-steerable | untracked                                       | catch `ActiveTurnNotSteerable{review\|compact}`, queue until `turn/completed`|
| Reply to peer | blind "delivered" on ack                       | subscribe, relay `item/agentMessage` + `turn/completed` back over the bus    |
| Arbitration   | none                                            | none — server serializes per-thread (no plugin-style broker needed)          |
| Discovery     | writes no `.pid`                               | emit `$slug.pid` for `discover.sh`                                            |
| cwd/sandbox   | hardcoded in `thread/start`                     | **set at server launch** (cwd + `-c sandbox_mode`/`approval_policy`); derive from ace-connect mode |

Net: **simpler than the plugin** (no broker — the shared socket makes serialization the
server's job) but **not** as simple as a daemon-based design (no daemon; the server launch
carries the security posture).

---

## 6. Open items / next steps

- ~~Fold the redesign into `skills/ace-connect/references/codex.md` (replace the "Open
  Questions" + "Protocol Discovery" sections with the answers above).~~ Done 2026-07-09
  (commit `1db1550`): Protocol reference + Resolved questions + Open items.
- The remaining items here (reply-back contract, sandbox derivation, `turn/steer`
  validation) are **closed** — see the Status section at the top of this note.

## 7. Repro artifacts

- Clones: `~/Documents/ace-rs/{codex,codex-plugin-cc}` (shallow; delete when done).
- Test rig: `~/Documents/ace-rs/codex-live-test/` — `bridge-probe.mjs` (WS JSON-RPC probe:
  `list` / `inject <threadId> <text>` / `steer <threadId> <turnId> <text>`),
  `launch-tui.sh`, `workspace/`.
- Stray test session left in `~/.codex/sessions/2026/07/05/rollout-…-019f31dd-….jsonl`
  (throwaway; `codex delete 019f31dd-…` to remove).

---

## 8. Live validation + the plain-codex breakthrough (2026-07-12, codex 0.142.5)

Ran the whole thing live against a real codex the user launched. Two tracks:
**(A)** the app-server bridge, now built and validated; **(B)** the harder question —
inject into a **plain, already-running** codex that must never be restarted.

### 8.1 App-server bridge — built + validated (resolves items #2, #4; #3 proposed)

Wrote a from-scratch Node bridge, `~/Documents/ace-rs/codex-live-test/codex-bridge.mjs`
(rig-local Node rig; **rejected — no Node, not promoted**; findings below are kept).
One long-running
process: WS client to `codex app-server --listen ws://…` + a **persistent Node
`net.Server`** unix inbox (zero rebind gap — strictly better than `start.sh`'s
one-`socat`-per-message). No `websocat` (Node ≥21 built-in `WebSocket`), no daemon.

Proven end-to-end (~10.8k codex tokens total):

- **Re-arm-free inject** — peer msg → `turn/start` when idle → renders in the human's TUI
  as a chat turn. Codex never re-arms; the wrapper owns the socket loop.
- **Reply-back (#2)** — subscribe via `thread/resume`, accumulate the answer from
  `item/completed {item.type:"agentMessage"}` (the `item/agentMessage/delta` stream carries
  **bare-string** deltas, not `{text}` — capture bug I hit and fixed), relay on
  `turn/completed` via `send.sh`. Landed as `DONE pong` in my Monitor.
- **Mid-turn steer (#4) — VALIDATED** — capture `turn.id` from `turn/started` (it's at
  `params.turn.id`, not `params.turnId`), inject via `turn/steer{expectedTurnId}` on the
  active turn. Fired live (`steer into <turnId>`), codex addressed it. **Timing gotcha:**
  gpt-5.5 finishes short turns in <2s, so a mid-turn test needs a long turn (count to 150)
  + short gap (~1s) or the turn completes first and you get a fresh `turn/start`.

Confirmed protocol facts: `thread/resume` **fails on a pristine thread** ("no rollout") —
no subscription (⇒ no turn-tracking / reply-back) until the thread has run ≥1 turn; it
self-heals after. The **server's launch dir owns cwd + sandbox** (TUI `--remote` flags
ignored) — every injected peer turn inherits the human's powers ⇒ item #3 (sandbox posture
from ace-connect mode) is a real security decision, **still undecided**.

### 8.2 Plain codex is NOT reachable by socket — exposure is launch-time

Exhaustively checked whether a **plain** `codex` TUI (no `--listen`) exposes an attachable
endpoint. It does **not**, by design:

- `features list`: `tui_app_server = removed/true` (TUI always runs an app-server
  internally, but over an **anonymous socketpair** — `lsof` fd 38↔39, both ends in-proc, no
  path); `remote_control = removed/false` (the daemon-attach feature is gone).
- No named/listen socket, nothing in the process env, no per-session socket file.
- Managed daemon (`app-server daemon` / `remote-control` / `proxy` → control socket
  `~/.codex/app-server-control/…sock`) is **walled behind the standalone installer** on
  Homebrew; the plain TUI doesn't register there (`app-server-daemon/*.lock` are empty).
- `lldb` attach to grab the fd is **blocked** — codex is hardened-runtime signed
  (`flags=0x10000(runtime)`, no get-task-allow); needs SIP-off or re-sign (both = a
  restart).

Verdict: the native multi-client channel exists only if exposure is chosen **at launch**
(`--listen` split, validated) — **never launch plain codex** for ace-connect use.

### 8.3 Breakthrough — PTY-injection daemon for an un-restartable plain codex

The one input surface a plain codex exposes is its **PTY**. A **persistent daemon** that
turns each ace-connect line into PTY input (`tmux send-keys`) is interactive and re-arm-free
— the loop lives in the daemon, codex just receives user turns.

`~/Documents/ace-rs/codex-live-test/pty-inject-daemon.mjs` (rig-local Node rig;
**rejected — PTY track dead, not promoted**).
**Proven live** against a plain running codex: two messages injected back-to-back, no
re-arm, no restart, no socket — codex answered them as normal chat turns.

Open refinements (not re-arm — serialization/robustness):
- **Serialize injections** — back-to-back sends merged into one input line (2nd `Enter`
  before the 1st submitted). Fix: after `Enter`, poll `capture-pane` until the input line
  clears before injecting the next.
- **Reply-back** — scrape the pane between prompt-reappearing states and relay over the bus.
- **Human/daemon share the input line** — interleave risk; gate injection to empty-input, or
  bracketed paste. Single-user, low collision.
- Requires codex in a controllable terminal (tmux / `expect` / `reptyr`).

---

## 9. Prune to one path — EXECUTED 2026-07-12

Ruling: `docs/decisions/2026-07-12-codex-single-listen-path.md`. Applied to
`references/codex.md`, `SKILL.md`, `scripts/codex.sh` (commit `768b957`): one
receiver (`codex.sh` → `codex app-server --listen` + `codex-app-bridge.sh` +
`codex --remote`), ephemeral port + per-slug rendezvous file, the tool-harness
one-shot `socat` receive and the PTY track dropped. Node rejected ("i hate
node.js") — the §8 Node rigs are not promoted.

Forward direction is the **Status** section at the top of this note, not here.

(Aside, non-durable: `~/.codex/config.toml` stored the GitHub PAT in plaintext —
user to rotate.)
