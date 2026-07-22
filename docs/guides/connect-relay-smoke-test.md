# Smoke-test ace-connect with a relay probe

Confirms the whole `ace-connect` path end to end — `send.sh` → an engine's socket
→ the agent's session → the agent's own `send.sh` reply — across three live
engines, in both directions. Isolated socket tests prove the plumbing; only a
relay through real agents proves an inbound line actually lands in a session and
gets acted on.

## When to run

After touching any `ace-connect` script (`send.sh`, `discover.sh`, the boot
scripts, either bridge), or when a peer reports messages not arriving. Cheap,
non-destructive — it only injects two short turns into each agent's session.

## The idea

A single delivered line (`send.sh` exits 0) proves only that the socket accepted
the bytes. It does **not** prove the agent ran. So relay a secret token through a
chain of agents and require it to come **back** to your inbox:

```
A: claude -> opencode -> codex    -> claude
B: claude -> codex    -> opencode -> claude
```

Each seed line is self-contained: it embeds, verbatim, the `send.sh` command the
next hop must run, which in turn embeds the final return-to-claude command. A hop
needs no prior knowledge — it does exactly what its line says. Running both
directions exercises each engine as both a forwarder and a returner.

## Run it

Precondition: all three engines live (`discover.sh` lists them) and your own
inbox engine (claude) started, or the returns bounce.

```sh
docs/guides/scripts/connect-relay-probe.sh            # token defaults to relay<pid>
docs/guides/scripts/connect-relay-probe.sh mysecret42 # or pin the token
```

Override the slugs for a different trio:
`ACE_RELAY_SELF`, `ACE_RELAY_OPENCODE`, `ACE_RELAY_CODEX`.

## What passes

Both tokens return to your `ace-connect` inbox (a Monitor event or `.ace/`
inbox line):

```
from=ace-rs.school.codex     body=CTX RELAY-A ok token=<secret>
from=ace-rs.school.opencode  body=CTX RELAY-B ok token=<secret>
```

- **Both return** → full path healthy in both directions.
- **`send.sh` exits 0 but no return** → delivery works, but a hop's agent didn't
  run or didn't forward. Read that engine's `*.bridge.log` — the line reached the
  bridge but the session never acted, or the forward `send.sh` failed.
- **`send.sh` exits 1** → the seed never landed; the target socket is dead. Check
  `discover.sh` and the engine's boot log.

A one-directional return isolates the break to the silent leg's forwarder.
