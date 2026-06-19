# www component vocabulary

Reusable page parts for the `www/` review site, in the ace terminal idiom. All are plain
HTML using classes from `www/assets/style.css` — no framework, no per-element inline
styles. Reach for one when prose alone reads flat; skip it when prose is enough.

## Design language

Dark terminal surface. Two typefaces, five accent colors — each color has **one job**,
keep them in lane:

| Token      | Role               | Where                               |
| ---------- | ------------------ | ----------------------------------- |
| `--teal`   | structure          | `h2`/`h3`, table headers, labels    |
| `--action` | clickable (gold)   | links, nav                          |
| `--orange` | active / primary   | `h1`, active nav, figures, emphasis |
| `--cyan`   | system / brand     | site title, focus ring              |
| `--link`   | code tokens (blue) | prompts/keys, list markers          |

Fonts: Space Grotesk (sans), Space Mono (mono) — loaded in `index.html`, with system
fallbacks. Idioms: `> ` list bullets, `//` and `01 · ` section markers, left-barred notes,
schematic line-figures. No emoji; let type and color carry tone.

## Page skeleton

Every page is a fragment — one `<article>`, a provenance header, an `<h1>`, a `.lede`,
then sections. End with a `.next` pointer where a journey continues.

```html
<!-- derived from: docs/spec/x.md @ <commit> -->
<article>
  <h1>Page title</h1>
  <p class="lede">One or two sentences that frame the page for a reader.</p>
  <h2 class="section">First section</h2>
  <p>…</p>
  <p class="next">Next: <a href="pages/y.html" hx-get="pages/y.html"
     hx-target="#content">where this goes →</a></p>
</article>
```

`<h2 class="section">` auto-numbers (`01 · `); a plain heading doesn't. Use numbering when
the sections are a sequence, plain headings when they're peers.

## Note / callout

A left-barred well for an aside, caveat, or system remark. Default teal; `--warn` (orange)
for cautions, `--system` (cyan) for tooling/automation notes.

```html
<p class="note">An aside that supplements the main prose.</p>
<p class="note note--warn">A caveat the reader must not miss.</p>
```

## Panel

A raised card grouping a sub-topic that deserves its own frame. Don't nest panels.

```html
<div class="panel">
  <h3>Grouped topic</h3>
  <p>…</p>
</div>
```

## Compare

Side-by-side columns for two options or a before/after. Mark the recommended side
`is-pick` (teal border). Two columns; collapse to one on narrow screens automatically.

```html
<div class="compare">
  <div class="compare-col is-pick"><h4>Chosen</h4><p>…</p></div>
  <div class="compare-col"><h4>Rejected</h4><p>…</p></div>
</div>
```

## Stats

A row of headline numbers. Auto-fits; keep to 2–4.

```html
<div class="stats">
  <div class="stat"><span class="num">8</span><span class="lbl">skills</span></div>
  <div class="stat"><span class="num">~63%</span><span class="lbl">text cut</span></div>
</div>
```

## Steps

A numbered mono sequence for an ordered procedure (commands, a workflow). For unordered
points use a normal `<ul>` (renders with `> ` bullets).

```html
<ol class="steps">
  <li>Clone the school into the cache.</li>
  <li>Symlink <code>skills/</code> into the project.</li>
</ol>
```

## Tags

Bordered chips for a short label set — statuses, categories, applicable backends.

```html
<span class="tag">accepted</span><span class="tag">claude</span><span class="tag">codex</span>
```

## Tree

A directory layout. Mark folders `dir`, files `file`; whitespace is preserved.

```html
<div class="tree"><span class="dir">docs/</span>
  <span class="dir">spec/</span>
  <span class="dir">decisions/</span></div>
```

## Code block

Commands or config. Wrap prompts and keys in `.prompt` or `.key` (blue) and asides in
`.comment` (muted). Plain `<pre><code>` also works for untokenized blocks.

```html
<div class="code-block"><span class="prompt">$</span> ace setup ace-rs/school
<span class="comment"># clones, symlinks skills/, writes ace.toml</span></div>
```

## Figure

A schematic line-diagram drawn before the prose, terminal-style. Author the `<svg>`
literally; `aria-hidden` it and let the prose carry meaning. Strokes inherit the figure
color (orange default, with `--teal` and `--cyan` variants) via `currentColor` — never
hardcode fills. Keep it schematic: a box is a `rect`, an arrow a `path`; 4–5 nodes max.

```html
<figure class="figure" role="img" aria-label="school imports flow">
  <svg viewBox="0 0 680 90" aria-hidden="true">
    <rect x="1" y="25" width="180" height="40"/>
    <text x="91" y="49" text-anchor="middle">downstream</text>
    <path class="fill" d="M181 45 l14 -5 v10 z"/>
    <rect x="240" y="25" width="180" height="40"/>
    <text x="330" y="49" text-anchor="middle">ace-rs/school</text>
  </svg>
</figure>
```

Larger diagrams (structural nesting, illustrative mechanisms) follow the same rules as
`/visualise`; this site only needs the schematic flow above. When a visual is genuinely
interactive or complex, generate it with `/visualise` and embed the result here.
