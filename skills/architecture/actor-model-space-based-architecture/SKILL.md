---
name: actor-model-space-based-architecture
description: Design or review stateful systems built on isolated actors (Akka, Orleans virtual actors and grains) or on Space-Based Architecture (processing units plus an in-memory data grid that keeps the database off the hot path). Covers message isolation, supervision versus domain errors, grain lifecycle, mailbox limits and when the model does not fit. Use when millions of independent entities, or write spikes that crush one database, need concurrency without locks. For list or search screens over actors use `cqrs-pattern`; for broker-based messaging use `event-driven-architecture`; for choosing among styles generally use `architecture-decision-trees-tradeoffs`.
---

# Actor Model & Space-Based Architecture

One idea: eliminate shared mutable state, lock contention, and central database bottlenecks under massive concurrency by encapsulating state and behavior inside **isolated entities (Actors / Virtual Grains)** that communicate exclusively via **asynchronous immutable messages**, or inside **self-contained Processing Units backed by a replicated In-Memory Data Grid (Space-Based Architecture)**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Akka, Microsoft Orleans & Space-Based Architecture)

| Term | Meaning | Test sentence |
|---|---|---|
| Actor | the fundamental unit of concurrent computation: encapsulates private state and behavior; other code can only send it messages, so no locks are needed; typically handles one message at a time (general practice, not stated on the pages read) | "no external thread can ever read or mutate an actor's state directly" |
| Virtual Actor / Grain (Orleans) | a location-transparent actor with a stable domain identity (e.g., `UserGrain("u-42")`) that always exists conceptually; the runtime activates/passivates it in memory across cluster **Silos** on demand | "callers never manually create, destroy, or locate a Grain on a specific server" |
| Supervision Hierarchy | a parent-child tree of actors where a parent supervisor decides how to react to a child's fault (Akka Typed documents resume, restart and stop; stop is the default); the parent is told of a failed child by watching it | "let it crash and heal via parent supervision, distinguished from normal domain validation errors" |
| Space-Based Architecture (SBA) | a distributed style in which components exchange entries through shared spaces (tuple-space lineage) and the central database leaves the hot path: work is spread across **Processing Units** that hold replicated in-memory data | "built for extreme, elastic high-concurrency read/write spikes (ticketing, auctions, trading, bidding)" |
| Processing Unit (PU) | the self-contained unit of scalability and failover in SBA, containing application logic plus an in-memory data-grid partition and optional web/messaging frontend | "scale by adding Processing Unit instances seamlessly" |
| Virtualized Middleware (SBA Grids) | the middleware around the units. One description lists a **Messaging Grid** (requests, sessions), **Data Grid** (replication between units), **Processing Grid** (distributed/master-worker processing) and **Deployment Manager** (starts and stops units); Wikipedia lists three grids plus an SLA-driven container | "the middleware fabric that keeps Processing Units synchronized" |

## Core architectural rules and invariants

1. **Zero shared mutable state — communicate only via immutable messages:** Never pass mutable objects by reference between actors, and never use low-level locks/mutexes across actors. Every message sent to an actor or grain must be deeply immutable and serializable across the network.
2. **Never block the Actor / Grain execution thread:** An actor processes its mailbox sequentially on a lightweight scheduler thread. Avoid blocking synchronous I/O (`Thread.Sleep`, synchronous HTTP/SQL, or heavy CPU loops) inside an actor message handler; use asynchronous non-blocking I/O or offload heavy CPU work to a dedicated worker pool / stateless worker grain.
3. **Keep Actor/Grain granularity fine and state bounded:** Model one actor per fine-grained domain entity (`DeviceGrain(deviceId)`, `CartGrain(cartId)`, `PlayerGrain(playerId)`), never a single "God Actor" (`AllOrdersActor`) that serializes every user's request through one mailbox.
4. **Distinguish Domain Validation Errors from Supervision Faults:**
   - If a message fails business validation (e.g., invalid user ID or insufficient funds), the actor state is intact — return an explicit domain error message to the caller.
   - If the actor hits an unexpected fault (corrupted state, crash), let it fail and let the **parent supervisor** restart or stop it (Akka). In Orleans there is no supervision tree on the page read: the runtime owns placement and recovery.
5. **Keep the database off the SBA hot path:** Processing Units work against replicated in-memory data; a central store is loaded and updated asynchronously (often called write-behind or a data pump; those terms are practitioner vocabulary, not on the pages read). Design judgment, not a sourced number: keep at least two replicas on distinct nodes and define the flush-failure policy, so a node crash before the flush does not lose committed work.
6. **Prevent Deadlocks and Reentrancy surprises in Actor Call Graphs:** Avoid synchronous request-response cycles (`Actor A` awaits `Actor B` while `Actor B` awaits `Actor A`). Prefer one-way tell/event messages or acyclic call hierarchies, and mark reentrancy explicitly only where safe.

## Building order

1. **Choose the right model for the bottleneck:**
   - Use **Actor Model / Virtual Actors (Orleans/Akka)** when millions of independent stateful entities (IoT devices, game sessions, live carts, chat rooms) need concurrent single-threaded state mutations without DB row-lock contention.
   - Use **Space-Based Architecture** when unpredictable concurrent load (ticketing, trading, bidding) would make the central database the bottleneck, because scaling the web and app tiers only moves the bottleneck down.
2. **Design Actor Identity, Mailbox Contracts, and Lifecycle:** Define the strongly typed actor key, immutable command/event messages, state persistence snapshot points, and idle passivation timeout.
3. **Test Actors in an In-Process TestKit / TestCluster first:** Verify single-actor state transitions, multi-actor message flows, and supervisor restart behavior deterministically in memory.
4. **Configure Clustering, Partitioning, and Persistence:** Wire cluster membership, consistent-hash partition routing, and durable state / event-sourced persistence (or SBA write-behind data pumps).

## Testing strategy

| Target | Test | Uses |
|---|---|---|
| Single Actor / Grain behavior | unit test (`TestKit` / `In-Process TestCluster`) | sends messages and asserts emitted reply messages and internal state transitions |
| Supervision & Crash Recovery | fault-injection test | forces an actor exception and verifies parent supervisor restarts the child and recovers persisted state |
| Multi-Actor Concurrency & Ordering | scenario test | simulates interleaved messages from multiple callers to verify absence of deadlocks and race conditions |
| Space-Based Data Grid Failover | cluster resilience test | kills one Processing Unit node mid-load and verifies zero data loss from the replicated Data Grid and clean write-behind flush |

## When it earns its keep

- **Worth it:** High-concurrency stateful workloads with millions of independent entities (telemetry/IoT digital twins, multiplayer gaming backends, real-time collaboration, chat/presence, telecom call routing, financial order books, flash-sale ticketing).
- **Not worth it:** Standard CRUD web apps or reporting-heavy systems that rely on complex ad-hoc relational `JOIN` queries across the entire dataset (querying across 500,000 isolated actors in memory without a separate CQRS read index is an anti-pattern).

## Mistakes to catch

- **Querying across all Actors (`for id in allIds: ask(actor[id])`):** Scanning thousands of actors over the network to build a list screen. Project actor state changes to a queryable read database (`cqrs-pattern`) for searches and listings.
- **Passing mutable references between local Actors:** Mutating an object after sending it to another in-process actor — breaking actor encapsulation and introducing race conditions without compiler warnings.
- **Coarse-grained "Manager Actors" that become bottlenecks:** Routing all traffic through a single stateful `OrderManagerActor` instead of sharding across `OrderActor(orderId)` or using stateless router pools.
- **Unbounded Actor Mailboxes:** Akka Typed mailboxes are unbounded by default; a fast producer can grow a slow actor's queue until memory runs out. Choose a bounded mailbox (the non-blocking kind sends overflow to dead letters; blocking kinds need a push timeout) or add backpressure.
- **Using Space-Based Architecture with a huge dataset that cannot fit in RAM:** SBA keeps data in memory next to the logic; if the hot working set exceeds cluster memory (design inference), the core advantage is lost.

## Quick Decision Checklist

- [ ] Are all messages between actors deeply immutable, with no shared mutable state or locks across actors?
- [ ] Is every blocking call (sync I/O, sleeps, heavy CPU) kept out of the actor message handler?
- [ ] Is there one actor per fine-grained entity rather than a single "God Actor" or manager?
- [ ] Are domain validation errors returned as replies, with only unexpected faults left to supervision?
- [ ] Are mailboxes bounded or backpressured, and are synchronous actor-to-actor call cycles avoided?
- [ ] Are list or search screens served from a read database instead of querying all actors?
- [ ] For SBA, are writes asynchronous write-behind with at least 2 replicas, and does the hot set fit in RAM?

## Deep references

- [Akka actor model: messaging, supervision, mailboxes](references/akka-supervision-and-failure-model.md) — when designing actor protocols and deciding domain errors vs supervised faults
- [Orleans virtual actors and runtime services](references/orleans-virtual-actors-runtime.md) — when choosing grains, placement, reminders, streams or transactions
- [Space-based architecture components](references/space-based-architecture-components.md) — when judging whether SBA's grids and processing units fit a load problem
- [Trigger evals](references/trigger-evals.md) — when tuning or checking this skill's description
