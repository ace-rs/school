#!/usr/bin/env bash
set -euo pipefail

# connect-relay-probe.sh [SECRET]
# Two-hop relay smoke test for ace-connect: exercises send.sh across three live
# engines and back, in both directions. Each seed is self-contained — it embeds,
# verbatim, the send.sh command each downstream hop must run — so a hop needs no
# prior knowledge beyond "do exactly what the line says".
#
#   A: claude -> opencode -> codex   -> claude   (CTX RELAY-A ok)
#   B: claude -> codex    -> opencode -> claude   (CTX RELAY-B ok)
#
# Delivery (exit 0 from send.sh) only proves the socket accepted the seed. The
# real pass is BOTH tokens returning to your ace-connect inbox — that means the
# receiving agents ran, read the line, and forwarded on. Watch your Monitor for
# `CTX RELAY-A ok token=<secret>` and `CTX RELAY-B ok token=<secret>`.
#
# Preconditions: all three engines live (`discover.sh`), and your own inbox
# engine (claude) started so the returns land somewhere.

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
send="$script_dir/../../../skills/ace-connect/scripts/send.sh"

self="${ACE_RELAY_SELF:-ace-rs.school.claude}"
oc="${ACE_RELAY_OPENCODE:-ace-rs.school.opencode}"
cx="${ACE_RELAY_CODEX:-ace-rs.school.codex}"
secret="${1:-relay$$}"

# Direction A: opencode forwards to codex, codex returns to claude.
a_return="send.sh $cx $self 'CTX RELAY-A ok token=$secret'"
a_seed="RELAY-A token=$secret — forward exactly one line: \
send.sh $oc $cx \"RELAY-A token=$secret then run: $a_return\""

# Direction B: mirror — codex forwards to opencode, opencode returns to claude.
b_return="send.sh $oc $self 'CTX RELAY-B ok token=$secret'"
b_seed="RELAY-B token=$secret — forward exactly one line: \
send.sh $cx $oc \"RELAY-B token=$secret then run: $b_return\""

echo "seeding relay token=$secret" >&2
bash "$send" "$self" "$oc" "$a_seed"
bash "$send" "$self" "$cx" "$b_seed"
echo "seeded — watch inbox for CTX RELAY-A ok / CTX RELAY-B ok token=$secret" >&2
