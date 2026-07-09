# Documentation organization in the LLM era — and what ace-docs should adopt

Research notes for the ace-docs taxonomy redesign. Compiled 2026-06-07 with a
fan-out/verify research harness: 5 search angles, 24 sources fetched, 108
candidate claims, 25 adversarially verified (2-of-3 vote), 0 refuted. Citations
are inline as URLs. Single-source, vendor-framed, and contested claims are
flagged explicitly — same honesty bar as the rest of `notes/`.

---

## 1. The design question

ace-docs currently scaffolds three folders sorted on ONE axis — **permanence**:
`notes/` (impermanent) → `decisions/` (point-in-time) → `spec/` (current
intent). All three are the project's internal *design record*; the skill even
says, in frontmatter, DO NOT TRIGGER for "user-facing product/API docs." The
question: is permanence the right organizing axis, and what is the taxonomy
missing?

## 2. Headline finding

Documentation practice in 2025–2026 is converging on **two orthogonal axes, and
permanence is neither of them**:

1. **Document TYPE / purpose** — the Diátaxis framework. Human-facing. Sorts by
   what the reader is trying to *do*.
2. **AUDIENCE / context-role** — the LLM-native layer (llms.txt, AGENTS.md /
   CLAUDE.md, auto-wikis, context engineering). Sorts by who/what consumes the
   doc and when it is loaded into a context window.

Permanence is canonically correct for exactly **one** doc class: architecture
decision records. Everywhere else both converging frameworks classify by type
or audience, not by how long a claim stays current.

So the instinct that the taxonomy is "missing an axis" is correct, and the two
additions worth making are the two named at the outset: **usage/how-to** and
**reference**.

## 3. Diátaxis — the type axis

Diátaxis (Daniele Procida) is the dominant *type-based* framework. Four types on
a 2×2 of two orthogonal axes — *action vs cognition* (does the user need to act
or to know?) and *acquisition vs application* (is the user at study or at
work?):

- **tutorials** — learning-oriented (action + acquisition)
- **how-to** — task-oriented; "addresses a real-world goal or problem"
  (action + application)
- **reference** — "technical description — facts — that a user needs in order to
  do things correctly" (cognition + application)
- **explanation** — understanding-oriented; "provide context and background...
  put things in a bigger picture" (cognition + acquisition)

The load-bearing claim, verbatim from the source: "Each has a different purpose,
and needs to be written in a different way," and "Crossing or blurring the
boundaries described in the map is at the heart of a vast number of problems in
documentation." That is the entire case for a type axis — and it is *not* a
permanence claim. https://diataxis.fr/start-here/ ;
https://ubuntu.com/blog/diataxis-a-new-foundation-for-canonical-documentation

**Caveat (verified, important).** Diátaxis is dominant in *theory*; explicit
formal adoption is low — ~4% in the 2025 Django Developer Survey — and
practitioners report the quadrants blur in real use. Adopters include Django,
Cloudflare, NumPy, Gatsby. Treat it as a compass, not rigid buckets. Even
critics (idratherbewriting.com) accept the analytical framing while rejecting
strict bucketing. → For ace-docs this argues *adopt the axis, not all four
quadrants*: collapse rare types rather than ship empty `tutorials/`.

## 4. ADRs — the one place permanence is canonical

The decisions log is vindicated exactly as built. ADRs are conventionally
**immutable, point-in-time** records: "Don't alter existing information in an
ADR. Instead, amend... or supersede... by creating a new ADR."
https://github.com/joelparkerhenderson/architecture-decision-record —
corroborated by Fowler ("Once an ADR is accepted, it should never be reopened or
changed - instead it should be superseded") and Nygard's original
Proposed/Accepted/Deprecated/Superseded status field. So permanence is the
*correct* axis for `decisions/` — and only there. (Vote 2-1: the dissent cites a
documented "mutability with date-stamps" deviation, but the source frames it as
a deviation *from* the convention, which narrows rather than falsifies it.)

## 5. The LLM-native layer

### 5.1 llms.txt — the curated-index pattern (durable) vs the web standard (contested)

llms.txt (Jeremy Howard / Answer.AI, 2024-09-03) is a proposed standard: a
markdown file at a site root giving "brief background information, guidance, and
links to detailed markdown files," "mainly... useful for inference, i.e. at the
time a user is seeking assistance." Rationale, verbatim: "context windows are
too small to handle most websites in their entirety." https://llmstxt.org/ ;
https://www.answer.ai/posts/2024-09-03-llmstxt.html

**Caveat (verified).** Adoption/efficacy is actively contested — multiple
"llms.txt is dead" critiques argue no major LLM is demonstrated to consume it
(adoption "stalls as major AI platforms ignore proposed standard").
https://ppc.land/llms-txt-adoption-stalls-as-major-ai-platforms-ignore-proposed-standard/
The durable takeaway is the **pattern** — a concise, curated, link-out index in
markdown aimed at inference-time consumption — not the web standard winning. In
a repo, `docs/README.md` + the `CLAUDE.md` pointer already *are* that index.

### 5.2 CLAUDE.md / AGENTS.md — the "schema document"

The agent-facing entry point is not a folder; it is a single schema/index file
that tells the agent how the docs are laid out. This is the convergent role of
`CLAUDE.md` (Claude Code) and `AGENTS.md` (Codex). Karpathy names both
interchangeably (§6). ace-docs step 4 (wire a `docs/` pointer into
CLAUDE.md/AGENTS.md) already implements this. Unresolved in the ecosystem:
whether AGENTS.md and CLAUDE.md converge to one cross-tool standard or persist
per-backend (§9).

### 5.3 Auto-wikis: DeepWiki, deepwiki-rs/Litho — supplement, not source of truth

DeepWiki (Cognition/Devin, launched 2025-05-05) auto-indexes a GitHub repo and
generates a wiki — architecture diagrams, source links, codebase summaries — no
manual authoring; at launch it had indexed 50,000+ top public repos.
https://cognition.ai/blog/deepwiki ; https://docs.devin.ai/work-with-devin/deepwiki
It is explicitly **dual-audience**: humans read it "to get up to speed," and the
Devin agent reads it "to better understand and find the relevant context in your
codebase." It is exposed to external agents (Claude, Cursor) via an MCP server
(`read_wiki_structure`, `read_wiki_contents`, `ask_question`).
https://cognition.ai/blog/deepwiki-mcp-server — concrete proof the field is
building docs as a *shared human+agent context artifact*.

Two facts that bound how much to lean on auto-generation:

- **Auto-wiki output defaults to a content-TYPE taxonomy**, not permanence and
  not strict Diátaxis. deepwiki-rs / "Litho" organizes generated docs as
  Project Overview / Architecture Overview / Workflow Overview / Deep Dive /
  Boundary-Interfaces / Database-Overview, positioned for "human teams and
  intelligent agents." https://github.com/sopaco/deepwiki-rs — independent
  evidence that practice gravitates to a type axis.
- **Holistic, architecture-aware auto-doc is an unsolved problem.** Best tools
  sit at ~64–69% quality (CodeWiki 68.79% vs DeepWiki 64.06%; arXiv:2510.24428,
  ACL 2026). https://arxiv.org/abs/2510.24428 Accuracy/consent backlash exists
  (hallucinated build systems, no maintainer oversight). → Auto-wikis are a
  **regenerable supplement** over human-curated durable docs, not a replacement.
  Same philosophy ace-docs already applies to `/visualise` HTML. The gap is
  closing fast, so revisit this in 2026.

## 6. Karpathy — primary sources (verbatim)

Three statements, all verified 3-0 against primary sources, tracing the
agent-first-docs argument:

1. **LLMs are the audience now** (Mar 2025): "It's 2025 and most content is
   still written for humans instead of LLMs. 99.9% of attention is about to be
   LLM attention, not human attention. E.g. 99% of libraries still have docs
   that basically render to some pretty .html static pages assuming a human will
   click through them." (`99.9%` is deliberate hyperbole.)
   https://x.com/karpathy/status/1899876370492383450 — operationalized by his
   `rendergit` (human-view vs LLM-view split). https://github.com/karpathy/rendergit

2. **Context engineering** (Jun 2025): "+1 for 'context engineering' over
   'prompt engineering'. ... in every industrial-strength LLM app, context
   engineering is the delicate art and science of filling the context window
   with just the right information for the next step." (He amplified Tobi
   Lütke's term, not coined it.) https://x.com/karpathy/status/1937902205765607626 ;
   https://simonwillison.net/2025/Jun/27/context-engineering/

3. **The persistent-wiki + schema blueprint** (Apr 2026) — the most on-point
   source for this repo. Instead of query-time RAG, "the LLM incrementally
   builds and maintains a persistent wiki — a structured, interlinked collection
   of markdown files"; "the wiki is a persistent, compounding artifact. The
   cross-references are already there" (vs RAG, where "the LLM is rediscovering
   knowledge from scratch on every question. There's no accumulation"). It is
   governed by "a document (e.g. CLAUDE.md for Claude Code or AGENTS.md for
   Codex) that tells the LLM how the wiki is structured, what the conventions
   are, and what workflows to follow when ingesting sources, answering
   questions, or maintaining the wiki."
   https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

   That is `docs/` (the wiki) + `CLAUDE.md` (the schema) — the architecture
   ace-docs already scaffolds. The redesign is finishing the wiki's taxonomy,
   not changing the model.

## 7. Context engineering — docs as loadable, addressable units

Anthropic's guidance: a "just-in-time" strategy where agents "maintain
lightweight identifiers (file paths, stored queries, web links)" and "load data
into context at runtime using tools," rather than pre-loading everything — with
a *hybrid* (some up-front + JIT) as the actual recommendation, under the
overarching rule "do the simplest thing that works."
https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
→ Implication for the taxonomy: structure durable docs as discoverable,
addressable units (clear paths + an index) an agent can pull on demand. Folder
structure and a map matter more than one monolithic dump. (Caveat: "recommends
pure JIT" overstates — the load-bearing point, addressable units + index,
holds.)

## 8. Recommendation for ace-docs

Adopt a **two-cluster hybrid**: keep the permanence axis where it is canonical
(the design record), add a type axis for the outward/usage docs. Same axis
everywhere is the trap that makes `reference/` feel wrong next to `notes/`.

```
docs/
  reference/   system facts — architecture, config, API, CLI, schemas   (living)
  guides/      how-to + getting-started, task-oriented                   (living)
  ──────────────────────────────────────  usage · sorted by TYPE
  spec/        current design intent / RFCs                              (living, edit in place)
  decisions/   dated ADRs                                                (frozen; supersede, don't edit)
  notes/       research, exploration, drafts                             (disposable, dated)
  ──────────────────────────────────────  design record · sorted by PERMANENCE
```

| Folder       | Axis        | Reader question it answers      | Grounded in                          |
|--------------|-------------|---------------------------------|--------------------------------------|
| `reference/` | type        | "what exactly is X?"            | Diátaxis; highest-value agent context |
| `guides/`    | type        | "how do I use this?"           | Diátaxis how-to+tutorial (collapsed) |
| `spec/`      | permanence  | "what do we intend to build?"  | existing; current-intent layer       |
| `decisions/` | permanence  | "why did we choose X (so we don't redo it)?" | ADR convention (immutable) |
| `notes/`     | permanence  | "what did we explore?"        | existing; ephemeral layer            |

Plus two non-folder positions:

- **`CLAUDE.md` / `AGENTS.md` is the schema/front door** — already wired by
  ace-docs step 4. This *is* Karpathy's schema layer; keep it as the single
  entry point and skip a separate `llms.txt` in a code repo (pattern already
  covered by `docs/README.md` + the pointer).
- **No `human/` vs `llm/` split.** Single-source docs serve both readers
  (DeepWiki, Karpathy's wiki, llms.txt all treat one artifact as dual-audience).
  An audience-split folder duplicates and rots.

`reference/` is the single highest-value addition for agent context (the
research calls it out explicitly); `guides/` is second. Both are what was asked
for at the outset.

**Fit-most-repos** by subsetting — no restructuring as a repo grows: a
library/internal tool often uses just `decisions/` + `notes/` (+ `spec/`); a
CLI/product adds `guides/` + `reference/`. Empty dir + README is the nudge.

**Forks still open** (taste calls, see §9 and the chat thread):
- usage folder name/granularity (`guides/` vs `usage/` vs split four-quadrant);
- where descriptive architecture lives (`reference/` vs a separate
  `explanation/` vs `spec/`);
- whether to mention `llms.txt` at all in the scaffold.

## 9. Open questions (unresolved by the corpus)

1. Does any team run a Diátaxis *type* taxonomy AND an agent-context layer
   (llms.txt / AGENTS.md / auto-wiki) on the same repo, and how do they
   reconcile them — one tree for both, or parallel human- vs agent-rendered
   views (the rendergit pattern)? No worked dual-axis example in the corpus.
2. Is the agent-facing reference layer better **hand-authored** (durable) or
   **auto-generated per session** (DeepWiki/Litho-style, disposable)? The
   ~64–69% quality ceiling and the "LLM-authored content pollutes
   source-of-truth" critique cut against full automation; the human-owned vs
   machine-regenerated boundary is unresolved.
3. Do `AGENTS.md` and `CLAUDE.md` converge to one cross-tool standard or persist
   per-backend? Relevant since this school injects `CLAUDE.md` and may want
   `AGENTS.md` parity.
4. In a repo, is a curated index better as an in-repo `llms.txt` file, or is the
   `CLAUDE.md`/`AGENTS.md` schema doc a sufficient single entry point? The two
   overlap; the corpus doesn't settle whether both are needed.

## Sources

Frameworks / type axis:
- Diátaxis (primary): https://diataxis.fr/start-here/
- Canonical/Ubuntu adopter: https://ubuntu.com/blog/diataxis-a-new-foundation-for-canonical-documentation
- Critical take: https://idratherbewriting.com/blog/what-is-diataxis-documentation-framework
- Python adoption discussion: https://discuss.python.org/t/adopting-the-diataxis-framework-for-python-documentation/15072

Permanence / ADRs:
- ADR collection (primary): https://github.com/joelparkerhenderson/architecture-decision-record

LLM-native conventions:
- llms.txt (primary): https://llmstxt.org/ ; https://www.answer.ai/posts/2024-09-03-llmstxt.html
- llms.txt adoption critique: https://ppc.land/llms-txt-adoption-stalls-as-major-ai-platforms-ignore-proposed-standard/
- AI config files overview: https://www.deployhq.com/blog/ai-coding-config-files-guide
- AGENTS.md guide: https://www.augmentcode.com/guides/how-to-build-agents-md

Auto-wikis:
- DeepWiki (primary): https://cognition.ai/blog/deepwiki ; https://docs.devin.ai/work-with-devin/deepwiki
- DeepWiki MCP (primary): https://cognition.ai/blog/deepwiki-mcp-server
- deepwiki-rs / Litho (primary): https://github.com/sopaco/deepwiki-rs
- Auto-doc quality benchmark (ACL 2026): https://arxiv.org/abs/2510.24428

Karpathy primary sources:
- LLM-audience tweet (Mar 2025): https://x.com/karpathy/status/1899876370492383450
- rendergit: https://github.com/karpathy/rendergit
- context-engineering tweet (Jun 2025): https://x.com/karpathy/status/1937902205765607626 ; https://simonwillison.net/2025/Jun/27/context-engineering/
- persistent-wiki + schema gist (Apr 2026): https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

Context engineering:
- Anthropic (primary): https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- Documentation-as-context (Google Cloud): https://medium.com/google-cloud/documentation-as-context-a-skill-to-automate-your-blueprints-for-the-agentic-era-2bec0cf041a3
