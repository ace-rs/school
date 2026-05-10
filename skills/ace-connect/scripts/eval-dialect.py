#!/usr/bin/env -S uv run --no-project --with tiktoken --quiet python
"""eval-dialect.py FIXTURES.json

Count tokens for paired prose / dialect bodies and emit a markdown reduction
table. Uses tiktoken's o200k_base (GPT-4o) as a Claude-tokenizer proxy —
absolute counts are off by ~5% vs Claude's actual tokenizer, but the *ratio*
between prose and dialect is what we care about, and BPE ratios are stable
across vocabularies.

Fixtures format:
  [{"name": "...", "prose": "...", "dialect": "..."}, ...]
"""

import json
import sys

import tiktoken


def main() -> None:
    if len(sys.argv) != 2:
        print("usage: eval-dialect.py FIXTURES.json", file=sys.stderr)
        sys.exit(2)

    with open(sys.argv[1]) as f:
        fixtures = json.load(f)

    enc = tiktoken.get_encoding("o200k_base")

    print("| Case | Prose | Dialect | Reduction |")
    print("|------|------:|--------:|----------:|")

    total_prose = 0
    total_dialect = 0
    for fx in fixtures:
        p = len(enc.encode(fx["prose"]))
        d = len(enc.encode(fx["dialect"]))
        pct = (p - d) * 100 / p if p else 0.0
        print(f"| {fx['name']} | {p} | {d} | {pct:.1f}% |")
        total_prose += p
        total_dialect += d

    total_pct = (total_prose - total_dialect) * 100 / total_prose
    print(
        f"| **Total** | **{total_prose}** | **{total_dialect}** | "
        f"**{total_pct:.1f}%** |"
    )


if __name__ == "__main__":
    main()
