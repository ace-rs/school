# Token-efficient wire languages for local agent-to-agent (A2A) communication

Research notes for `ace-connect` — a unix-socket bridge between Claude Code and
Codex on the same host. Compiled 2026-05-09. Citations are inline as URLs;
where I could not verify a claim, I say so explicitly.

---

## 1. Problem statement

`ace-connect` today carries plain prose between two LLM-driven coding agents
over a unix socket. Wire format is tab-separated `from=<slug>\tto=<slug>\tbody=<text>`,
`body` capped at ~500 chars (no tabs/newlines), larger payloads spilled to a
tmpfile path. Both sender and receiver are LLMs: they *write* the body in a
tool call and *read* it as a tool result.

Once a task spans more than a handful of round-trips, prose becomes the
dominant token cost on both sides — the sender pays output tokens to compose
it, the receiver pays input tokens to ingest it, and Claude/Codex each replay
the full transcript on every turn. The question is: **what wire-level dialect
yields the best tokens-per-message ratio without raising error rate beyond
plain prose?**

Concrete constraints from the design:

- Both peers are frontier-class LLMs (Claude 4.x, GPT-5/Codex). Either can
  read or write any encoding humans have produced, but neither has been
  *trained* on a custom dialect.
- Messages are short and conversational (status, asks, answers, file
  pointers), not bulk data. So compression schemes optimized for tabular data
  matter less than ones optimized for prose.
- The dialect must be self-describing or pre-agreed; there is no central
  schema registry.
- Agents must agree mid-session if they're going to switch dialects.
- Reversibility to plain prose matters for human debugging — both sides log
  to disk and a human reads transcripts.

---

## 2. Evaluation dimensions

When I read each candidate below, I scored it implicitly along these axes:

1. **Input-token reduction** vs prose at the *receiver*. This is what bills
   you on every subsequent turn because the message stays in context.
2. **Output-token reduction** at the *sender*. Generation is slower and
   costlier per token than ingestion for most providers.
3. **Error rate / ambiguity** — does the receiver misread the message? Does
   the dialect have ambiguous parse rules?
4. **Reversibility** — can you mechanically (or with one prompt) turn a
   message back into plain prose for a human reader?
5. **Mutual adoption cost** — how much instruction has to land in *both*
   agents' system prompts before the dialect works?
6. **Asymmetric tolerance** — what happens if one peer is weaker (smaller
   model, less context budget) and can't follow the dense form?
7. **Learning cost** — does the model already know this dialect from
   pretraining, or do you have to teach it?

---

## 3. Survey of candidate dialects

### 3.1 Caveman / "drop articles and hedges" prompt-shaping

Two relevant projects, both real and verified:

- **JuliusBrussee/caveman** — Claude Code skill, claims ~65–75% output-token
  reduction by stripping articles, fillers, hedges, and pleasantries.
  Technical content (code, paths, URLs, version numbers) passes through
  untouched. Has intensity levels (lite / full / ultra / wenyan-*).
  https://github.com/JuliusBrussee/caveman
- **wilpel/caveman-compression** — separate "semantic compression" tool;
  reports 40–58% reduction with LLM-based recompression and 100% fact
  retention on a 13-fact benchmark.
  https://github.com/wilpel/caveman-compression

Independent benchmark by Kuba Guzik (verified, posted on dev.to and Medium)
ran caveman against a *baseline that already said "be concise, return JSON"*
on Claude Sonnet and Opus across 72 runs (incident diagnosis + timeout
extraction). Result: **9–21% output-token reduction** depending on model,
with 100% factual accuracy retained. The headline 75% number compared
against an unprimed "you are a helpful assistant" baseline.
https://dev.to/jakguzik/i-benchmarked-the-viral-caveman-prompt-to-save-llm-tokens-then-my-6-line-version-beat-it-2o81

**Take.** Real but modest savings on prose-heavy outputs. Models don't need
to be *taught* caveman — pretraining covers telegraphic English. Trivial to
roll back to prose. Best fit for an "outbound only" rule: each agent writes
caveman, but neither needs special parsing on receive.

### 3.2 Chain-of-Symbol (CoS) and Sketch-of-Thought (SoT)

- **Chain-of-Symbol** (Hu et al., 2023, arXiv:2305.10276) — replaces
  natural-language descriptions of spatial relations with compact symbolic
  ones. Reports up to 60.8% accuracy improvement and 65.8% input-token
  reduction *on spatial planning tasks*. Domain-bound: not a general dialect.
  https://arxiv.org/html/2305.10276v7
- **Sketch-of-Thought** (Aytes et al., 2025, arXiv:2503.05179) — three
  paradigms (Conceptual Chaining, Chunked Symbolism, Expert Lexicons) routed
  by a lightweight classifier. Reports up to **84% token reduction** on
  reasoning tasks with minimal accuracy loss. Code:
  https://github.com/SimonAytes/SoT
- **Chain of Draft** (Xu et al., 2025, arXiv:2502.18600) — instructs the
  model to produce ~5-words-per-step intermediate drafts. **68–92% token
  reduction** vs CoT, latency cut 50–75%, accuracy preserved. Code:
  https://github.com/sileix/chain-of-draft

**Take.** SoT and CoD are the strongest empirical wins in the literature, but
they target *internal* reasoning traces, not inter-agent messages. The
techniques port naturally though: "respond in chain-of-draft style, ≤5 words
per step" is a one-line system-prompt addendum that frontier models obey.

### 3.3 Structured envelopes — JSON-RPC, JSON5, MessagePack-as-text, TOON

- **JSON-RPC 2.0** is the lingua franca: A2A, MCP, and ACP all use it.
  https://a2a-protocol.org/latest/specification/ ;
  https://modelcontextprotocol.io/docs/learn/architecture
- **TOON** (Token-Oriented Object Notation) is a JSON-isomorphic line-based
  format with explicit array lengths and CSV-style tabular rows. Reports
  **30–60% token reduction** vs JSON on uniform arrays-of-objects, but
  "loses its advantage" on small/irregular/hierarchical payloads.
  https://github.com/toon-format/spec ;
  https://github.com/toon-format/toon
- **MessagePack** is binary; pointless here because LLMs see strings.

Critique of A2A-style verbose JSON for agent-to-agent traffic, with
representative numbers, in Duncan's TOON-vs-JSON post:
https://jduncan.io/blog/2025-11-11-toon-vs-json-agent-optimized-data/

**Take.** For `ace-connect`'s short, single-message-per-turn payloads, full
JSON envelopes are pure overhead — the field names eclipse the body. TOON
only pays off on tabular payloads, which `ace-connect` doesn't have. A
minimal `key=val\tkey=val` framing (which is what `ace-connect` already uses)
is already near-optimal for the *envelope*; the question is the *body*.

### 3.4 SMS / leetspeak / abbreviation tables

I could not find a serious benchmark for SMS-style shorthand on modern LLMs.
Anecdotally, "u" vs "you" saves 1 BPE token, but most modern tokenizers fold
common abbreviations into single tokens already. Leetspeak likely *increases*
tokens because non-standard substitutions break BPE merges. **Skip.** No
verified study; I'm not asserting one exists.

### 3.5 Aviation / military brevity codes

Multi-Service Tactical Brevity Code (NATO APP-7, US FM 3-54.10) is a real
1000-word vocabulary of single-word procedure terms ("FOX", "BINGO",
"SPLASH") that compress aircraft-status sentences into one token.
https://en.wikipedia.org/wiki/Multi-service_tactical_brevity_code ;
https://nato.radioscanner.ru/files/article140/brevity_words_app7e_.pdf

I could not find any LLM study that adopts brevity code for inter-agent
messaging. The interesting *idea* is the design pattern: a fixed,
pre-agreed vocabulary of single-token procedure words for the most common
turn-types ("ACK", "WAIT", "STUCK", "DONE"). This is essentially
the Anthropic "Expert Lexicon" paradigm from SoT (3.2) applied to A2A.

### 3.6 Programming-language-as-wire-format

S-expressions, Python tuples, edn — all dense, all parsed losslessly by
frontier models, all zero learning cost. No published benchmarks I could
verify on token efficiency vs JSON for small payloads. Theoretical advantage:
~20–30% fewer tokens than JSON because of fewer quotes and braces, but I
**did not find a peer-reviewed measurement** to back this; I'm flagging the
claim as unverified.

Lojban-for-machines was floated in HN threads circa 2023; no serious project
in 2026 that I could find. Skip.

### 3.7 Anthropic's own guidance — token-efficient tool use

Claude 3.7 Sonnet introduced a `token-efficient-tools-2025-02-19` beta header
that **reduced output tokens by an average of 14%, up to 70% in best cases**.
Claude 4.x has it built in; the header is a no-op there.
https://docs.anthropic.com/en/docs/build-with-claude/tool-use/token-efficient-tool-use ;
https://www.anthropic.com/news/token-saving-updates

This is *tool-call* compression, not message-body compression — but it's the
provider's official answer to "how should agents emit dense structured
output". Inference: Anthropic believes compressed JSON-tool-calls are the
right primitive. For `ace-connect`, the analogue is to treat the bridge
message as a tool call with a tightly-typed body schema.

### 3.8 Dedicated A2A protocols

- **Google A2A** (now Linux Foundation) — JSON-RPC 2.0 over HTTPS with
  Agent Cards (capability metadata) and `Part` types (TextPart, FilePart,
  DataPart). https://a2a-protocol.org/latest/specification/ ;
  https://github.com/a2aproject/A2A
- **MCP** — JSON-RPC 2.0, stdio or SSE. ~250 tokens per advertised tool;
  81 tools across 3 servers ≈ 20k tokens before any work happens
  (cited from MCP Playground; presented as a community estimate, not a
  formal benchmark).
  https://mcpplaygroundonline.com/blog/mcp-token-counter-optimize-context-window
- **IBM ACP** — REST + JSON, MimeType-tagged Parts. **Merged into A2A under
  the LF in 2025**; ACP active development is winding down.
  https://www.ibm.com/think/topics/agent-communication-protocol
- **ANP** (Agent Network Protocol) — proposes a *meta-protocol* layer where
  agents negotiate the underlying wire dialect via natural-language
  handshake. https://agent-network-protocol.com/specs/communication.html

None of these protocols define a "dense dialect" for the message body.
They standardize the *envelope* and leave the body as free text or
arbitrary JSON. So adoption gives `ace-connect` schema/discovery ergonomics
but no inherent token win for the body.

### 3.9 Emoji / unicode compression

Counterintuitive: a single emoji often costs **3+ BPE tokens**, sometimes
10+ for ZWJ-glued compounds. https://d3lm.medium.com/why-emojis-are-technically-inefficient-and-dangerous-for-llms-582ee3202549
There are also documented prompt-injection attack vectors via invisible
unicode (variation selectors, ZWJ chains).
https://repello.ai/blog/prompt-injection-using-emojis ;
https://aws.amazon.com/blogs/security/defending-llm-applications-against-unicode-character-smuggling/

**Skip emoji entirely.** They're more expensive than ASCII *and* a security
hazard.

### 3.10 LLMLingua and prompt compression

Microsoft LLMLingua (EMNLP'23) and LLMLingua-2 (ACL'24) achieve up to
**20× compression with ~1.5% accuracy loss** on GSM8K-style prompts using a
small auxiliary LM to drop low-perplexity tokens.
https://github.com/microsoft/LLMLingua ;
https://arxiv.org/abs/2310.05736

**The catch for A2A:** LLMLingua compresses *prompts* — text destined for
*one* LLM that will read the compressed form. The receiver doesn't run a
decompressor; the LLM itself parses the dropouts. So in principle, you
could LLMLingua the body before sending. In practice:
- It needs a small LM running locally (one more dependency in
  `ace-connect`).
- The output is *less human-readable*, hurting reversibility.
- Empirically tuned for paragraph-scale inputs; uncertain win on 500-char
  bodies.
- Both peers must be tolerant of the dropout style.

### 3.11 Classical Chinese / wenyan

Posited as the "ultimate" memory compression because each character is one
token (on tokenizers with good CJK coverage) and classical idioms encode
entire situations in 4 chars.
- ai.rs blog post claims 24% token savings at 96% retrieval on agent memory
  benchmarks. https://ai.rs/ai-developer/classical-chinese-agent-memory-compression
- MemChinesePalace: https://github.com/Chandler-Sun/MemChinesePalace
  (the README explicitly says "not a serious project").
- A counter-paper (arXiv:2604.14210) titled
  "Mythbuster: Chinese Language Is Not More Efficient Than English in Vibe
  Coding" claims the savings don't hold on coding tasks. I have *not* read
  the full PDF, just the title — flagging this as a contradicting source
  worth investigating.

**Take.** Provocative but not load-bearing for `ace-connect`. Human
debuggability is severely hurt unless your team reads classical Chinese.

### 3.12 Emergent / self-played dialects

Language Self-Play and related multi-agent emergent-communication work
(reviewed at https://www.emergentmind.com/topics/language-self-play-lsp)
shows that agents can co-evolve compressed protocols. None of this work is
production-ready, and the protocols that emerge are typically *not
human-interpretable*. Inappropriate for `ace-connect` v1.

---

## 4. Empirical comparisons

Verified numbers, all on output-token reduction unless noted, all comparing
against a stated baseline:

| Dialect              | Reduction        | Accuracy impact     | Source                       |
|----------------------|------------------|---------------------|------------------------------|
| Caveman (vs unprimed)| 65–75% (claimed) | 100% facts retained | Brussee README; not indep.   |
| Caveman (vs primed)  | 9–21% (measured) | 100% facts retained | Guzik dev.to benchmark       |
| Chain of Draft       | 68–92%           | parity with CoT     | Xu 2025 arXiv:2502.18600     |
| Sketch of Thought    | up to 84%        | minor loss          | Aytes 2025 arXiv:2503.05179  |
| Chain of Symbol      | up to 65.8% in   | +60.8% accuracy     | Hu 2023 arXiv:2305.10276     |
|                      | input tokens     | (spatial only)      |                              |
| TOON vs JSON         | 30–60%           | 76.4% vs 75.0%      | toon-format benchmarks       |
|                      | (tabular only)   |                     |                              |
| YAML vs JSON         | 20–30%           | not reported        | LogRocket / openapi.com      |
| Anthropic token-     | avg 14%, peak    | parity              | Anthropic docs               |
| efficient tool use   | 70%              |                     |                              |
| LLMLingua            | up to 20×        | ~1.5% loss on GSM8K | Microsoft LLMLingua          |
| Classical Chinese    | 24% (claimed)    | 96% retrieval       | ai.rs blog (not peer-rev.)   |

**Caveats on every row.** None of these benchmarks measured *short
inter-agent status messages*, which is `ace-connect`'s actual workload. The
closest analogue is the Guzik caveman benchmark (production-incident
diagnosis), which gives a realistic 9–21% expectation for a primed baseline.

---

## 5. Recommendation matrix for ace-connect

Three candidates, ranked by expected value-for-effort. All assume the
baseline is "agent already trying to be terse because the system prompt told
it to."

### Rank 1 — Caveman-lite + brevity vocabulary (hybrid)

System-prompt rule on both peers: *"Drop articles, hedges, pleasantries.
Use the brevity vocabulary below for common turn-types."*

Brevity vocabulary (fixed 8–16 verbs, single-token where possible):

```
ACK    received
WAIT   working, no progress yet
DONE   task complete, see file <path>
ASK    need input: <question>
STUCK  blocked: <reason>
FILE   payload at <path>
CTX    background: <one-liner>
NACK   reject: <reason>
```

First-message template:

```
ASK alice: review schema in /tmp/x.sql, focus on indexes
```

vs prose baseline:

```
Hey Alice, could you take a look at the schema I've put in /tmp/x.sql?
I'd like you to focus particularly on the indexes.
```

19 vs 53 chars / ~7 vs ~16 tokens. **Expected savings: 15–25% on real
traffic, matching Guzik's measurement.** Zero learning cost (frontier models
already know this register from logs and IRC). Trivially reversible
(pretty-printer is one prompt). One peer being weaker is fine — caveman
prose degrades gracefully back to standard prose if the receiver doesn't
recognise the verb.

### Rank 2 — Chain-of-Draft body style (for *answers* / status updates)

Apply CoD to body when the agent is reporting reasoning ("here's what I
found"), not asks ("please do X"). Steps are ≤5 words, dash-prefixed.

Template:

```
DONE alice:
- ran tests, 3 fail
- root cause: stale fixture
- fix in /tmp/patch.diff
```

68–92% reduction is the published number on reasoning-rich outputs, but
short status updates are already terse, so realistic gain is more like
30–50%. Pairs orthogonally with Rank 1 (envelope verbs + CoD body).

### Rank 3 — Tool-call envelope, free-text body

Skip dialect engineering on the body; instead get Anthropic's free 14% by
making `ace-connect send` a *real tool call* with a typed schema instead of
a tab-separated string blob. This is structural, not lexical — the agent
doesn't change its writing style; the protocol does the saving.

This is also the path Google A2A / MCP / ACP all settled on. It composes
with Rank 1 (you can still mandate caveman in the `body` field).

### Combined recommendation

Stack them: Rank 3 envelope (typed tool call) + Rank 1 body convention
(brevity vocab + drop articles). Skip CoD as a *requirement*; let agents
use it inside DONE/ASK bodies if natural.

Combined expected wire-token reduction vs current prose: **30–45% on
multi-turn tasks**, with no measurable accuracy hit. This is a guess
extrapolated from the citations above; it would need a measurement on real
`ace-connect` transcripts to verify.

---

## 6. Adoption mechanics

How do two agents agree on the dialect? Four options, in increasing order of
machinery:

1. **Out-of-band, system-prompt baked in.** Both `ace-connect` peers ship
   identical system-prompt addenda describing the brevity vocab and rules.
   No negotiation in-band. **This is the right v1.** Easiest to debug, no
   spec evolution problems.

2. **First-message announce.** Sender begins with `DIALECT caveman-v1` and
   the receiver either acks or downgrades. Useful only if you ever expect
   to ship multiple dialects in parallel, which v1 does not need.

3. **Header field on the envelope.** If you take Rank 3 (typed tool call),
   add a `dialect` field to the schema, default `prose`. Receiver checks
   the header. This is what MCP/A2A do via their capability negotiation
   handshake.
   https://modelcontextprotocol.io/docs/learn/architecture

4. **Meta-protocol auto-negotiation.** ANP-style — agents introspect each
   other's capabilities and pick a shared dialect. Massive overkill for
   two known peers on a unix socket.

**Asymmetric / weaker peer fallback.** Caveman degrades naturally; the
receiver sees grammatical English minus articles and parses it fine. The
brevity vocab does *not* degrade naturally — `ACK` could be misread by a
weaker model as a typo. Mitigation: include the brevity table in the
*receive-side* system prompt, not just the send-side. If a peer is too
weak to memorize 8 verbs, it's probably too weak to participate in
multi-turn ace-connect at all.

---

## 7. Open questions / unsolved

Things the literature does not answer for `ace-connect` specifically:

1. **Tokenizer-specific savings.** All published benchmarks use cl100k_base
   or similar. Claude 4.x uses Anthropic's proprietary tokenizer and Codex
   uses a GPT-5-era tokenizer. Caveman, CoD, brevity-vocab savings on
   short inter-agent messages have not been measured on either. We'd need
   to measure on actual transcripts.

2. **Round-trip degradation.** When agent B replies in dialect X, does
   agent A's *next* output (which now contains B's reply in its context)
   stay in dialect X? Or does the model regress to prose because it sees
   prose elsewhere in its context? Unverified.

3. **Brevity vocab collisions.** `ACK`, `WAIT` etc. appear in source code
   comments, log lines, and docstrings the agents read. Does the dialect
   pollute downstream outputs? E.g. does the agent start writing "ACK" in
   commit messages? Worth a quick eval.

4. **Reversibility automation.** A pretty-printer ("expand caveman to
   prose") is trivial; a *test* that dialect→prose→dialect is fixed-point
   is not. Without it, drift is unmeasured.

5. **Cost of the system-prompt addendum itself.** Caveman-style instructions
   are ~150–500 tokens. On a short session they're net-negative; you save
   <150 tokens of body but added 300 tokens of instructions to every turn.
   Crossover point on `ace-connect` traffic is unknown. Anthropic prompt
   caching mitigates this, but only if the addendum is at the front of the
   prompt and stable across turns.

6. **Failure mode taxonomy.** No published study of *which* token-savings
   dialects increase agent-misreading rate, vs which are neutral. Caveman
   benchmarks measure factual retention but not "did the agent take the
   wrong action because the message was ambiguous."

7. **Model-asymmetry behavior.** Claude and Codex have different default
   verbosity profiles. If Claude is the prose hog and Codex is naturally
   terse, the dialect's marginal value differs across the two senders. Not
   measured.

Resolving (1), (2), and (5) would require a small in-house eval: replay 10
real `ace-connect` task transcripts under each candidate dialect, count
tokens, and human-rate task completion. That's the smallest credible
benchmark, and it's the work I'd recommend before committing to a dialect.

---

## Sources

- Caveman (Brussee): https://github.com/JuliusBrussee/caveman
- Caveman compression (Peltomäki): https://github.com/wilpel/caveman-compression
- Caveman benchmark (Guzik): https://dev.to/jakguzik/i-benchmarked-the-viral-caveman-prompt-to-save-llm-tokens-then-my-6-line-version-beat-it-2o81
- Chain-of-Symbol: https://arxiv.org/abs/2305.10276
- Sketch-of-Thought: https://arxiv.org/abs/2503.05179, https://github.com/SimonAytes/SoT
- Chain of Draft: https://arxiv.org/abs/2502.18600, https://github.com/sileix/chain-of-draft
- TOON spec: https://github.com/toon-format/spec
- TOON impl: https://github.com/toon-format/toon
- LLMLingua: https://github.com/microsoft/LLMLingua, https://arxiv.org/abs/2310.05736
- Google A2A spec: https://a2a-protocol.org/latest/specification/
- A2A repo: https://github.com/a2aproject/A2A
- MCP architecture: https://modelcontextprotocol.io/docs/learn/architecture
- IBM ACP: https://www.ibm.com/think/topics/agent-communication-protocol
- ANP: https://agent-network-protocol.com/specs/communication.html
- Anthropic token-efficient tool use: https://docs.anthropic.com/en/docs/build-with-claude/tool-use/token-efficient-tool-use
- NATO brevity codes: https://en.wikipedia.org/wiki/Multi-service_tactical_brevity_code, https://nato.radioscanner.ru/files/article140/brevity_words_app7e_.pdf
- Emoji tokenization: https://d3lm.medium.com/why-emojis-are-technically-inefficient-and-dangerous-for-llms-582ee3202549
- Emoji injection: https://repello.ai/blog/prompt-injection-using-emojis
- Classical Chinese for agent memory: https://ai.rs/ai-developer/classical-chinese-agent-memory-compression
- MemChinesePalace: https://github.com/Chandler-Sun/MemChinesePalace
- TypeChat: https://github.com/microsoft/TypeChat
- TOON vs JSON post: https://jduncan.io/blog/2025-11-11-toon-vs-json-agent-optimized-data/
- MCP token cost commentary: https://mcpplaygroundonline.com/blog/mcp-token-counter-optimize-context-window
