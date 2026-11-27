# Orleans Virtual Actors: Grains, Silos and Runtime Services

Sources: https://learn.microsoft.com/en-us/dotnet/orleans/overview · Last verified 2026-11-27

## Core definitions

- **Virtual actor:** an actor that always exists logically. It cannot be explicitly created or destroyed, and a server failure does not end its existence. Because it always exists it is always addressable.
- **Grain:** Orleans' virtual actor; a stable user-defined identity plus behavior plus state. Identity is a key (Guid, Int64, string, or compound), so callers address by domain key, not by reference.
- **Silo:** a host for grains and the runtime. Silos form a **cluster** that coordinates work, detects failure and recovers; grains in a cluster talk as if in one process. External clients use a client library; clients can be co-hosted in a silo.

## Lifecycle

The runtime activates grains on demand, evicts idle ones from memory, and can reactivate them later elsewhere. Callers never track where a grain lives. Result: write code as if every grain is always in memory. State is held in memory while active (lower latency, less store load) and written with `WriteStateAsync` for durability.

## Runtime services (feature checklist)

| Feature | What it gives | Use when |
|---|---|---|
| Persistence | multiple named state objects per grain (e.g. "profile", "inventory"), any storage | state must survive deactivation |
| Timers | non-durable, high frequency | cheap periodic work |
| Reminders | durable scheduling, fire even if grain inactive | must happen eventually |
| Placement | random, prefer-local, load/resource-based, custom | locality to resources or peers |
| Versioning / heterogeneous clusters | interface versions, rolling upgrades | stateful system upgrades |
| Stateless workers | stateless grains activated on many silos at once | parallel pure functions |
| Call filters, request context | authz, logging, tracing metadata | cross-cutting concerns |
| Distributed ACID transactions | decentralized, no central coordinator, serializable isolation | several grains must change atomically |
| Streams | managed pub/sub, checkpoints/cursors, batch delivery, backed by Event Hubs/Kinesis etc. | near-real-time item processing |

Version notes from the page (switchable by version): 9.x added a strong-consistency grain directory, memory-based activation shedding, an in-process test cluster, faster failure detection (90 s versus 10 min earlier), activation rebalancing, and a default-placement change from Random to ResourceOptimized in 9.2. 10.0 added a built-in dashboard, stable Redis providers and cancellation-token support for system targets. Check the page for the version you run.

## Typical fits named by the page

Gaming, banking, chat, GPS tracking, stock trading, shopping carts, voting; Microsoft cites Azure, Xbox, Skype, Halo among internal users.

## Classic versus virtual (summary)

Classic Akka: you spawn, hold references, build supervision trees. Orleans: you address by key; placement and recovery belong to the runtime. The page does not describe supervision trees; do not attribute them to Orleans.

## How an agent should apply this

- Choose the grain key from the domain aggregate id (order, device, user), one grain per consistency boundary.
- Keep grains small; do not create one grain through which all traffic flows (the single-grain hot spot).
- Use reminders for durable follow-ups and timers only for best-effort ticks.
- Test with the in-process test cluster rather than mocking the runtime.
- Use transactions only when multi-grain atomicity is truly required; otherwise prefer messages and idempotency (inference, not in source).
- Plan grain interface versions before the first production rollout.
