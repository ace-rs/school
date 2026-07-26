# Scratch

**Unsettled exploration** — research dumps, surveys, investigations, drafts, transcripts:
thinking-in-progress whose claims are not expected to stay current. This is the residual
home. Material lands here only when it fits nothing above it in the routing gate — never as
a default.

Belongs here *only* if it is genuinely exploratory. Anything settled — current or intended
design, a ruling, a convention, our own exact surface — is `../spec/`; third-party lookup
is `../vendor/`; a task walkthrough is `../guides/`.

**Toll.** Open every scratch file with one line naming why it is not spec:

```
<!-- not spec because: still exploring; nothing settled yet -->
```

If that line cannot be written truthfully, the artifact belongs in one of those folders.
Put it there instead.

## Format

One file per artifact: `YYYY-MM-DD-slug.md` (the date matters — scratch is about the moment
it was written). No template; write whatever shape fits.

## Lifecycle

Disposable. Edit, rewrite, or delete freely. When exploration settles, promote the durable
claim up to `../spec/`; what remains here is the raw working material.

Two carve-outs on deletion:

- **Cited provenance is retained.** A note another doc cites as its provenance stays, even
  though scratch is disposable — disposability governs new filing, not deletion of
  already-cited material. Never orphan a citation.
- **Collapse instead of scatter.** When design notes pile up on one theme, consolidate them
  into a single `prior-art.md` digest — one section per source, each cross-linked to the
  live `../spec/` doc it fed — then repoint citations and drop the absorbed notes.
  `prior-art.md` is the one undated file here.
