---
name: actor-model-space-based-architecture
description: Use when designing, reviewing, or debugging concurrent/distributed stateful systems with the Actor Model (Akka, Microsoft Orleans Virtual Actors/Grains, Erlang/OTP) or Space-Based Architecture (Processing Units, In-Memory Data Grids, Messaging/Processing Grids, eliminating single-database bottlenecks under extreme write spikes). Gives actor isolation rules, supervision hierarchies, grain lifecycle, data-grid write-behind invariants, and common mistakes.
---

# Actor Model & Space-Based Architecture

One idea: eliminate shared mutable state, lock contention, and central database bottlenecks under massive concurrency by encapsulating state and behavior inside **isolated, single-threaded entities (Actors / Virtual Grains)** that communicate exclusively via **asynchronous immutable messages**, or inside **self-contained Processing Units backed by a replicated In-Memory Data Grid (Space-Based Architecture)**. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Hewitt/Akka, Microsoft Orleans & Space-Based Architecture)

| Term | Meaning | Test sentence |
|---|---|---|
| Actor | the fundamental unit of concurrent computation: encapsulates private state, behavior, and a mailbox; processes one message at a time without locks | "no external thread can ever read or mutate an actor's state directly" |
| Virtual Actor / Grain (Orleans) | a location-transparent actor with a stable domain identity (e.g., `UserGrain("u-42")`) that always exists conceptually; the runtime activates/passivates it in memory across cluster **Silos** on demand | "callers never manually create, destroy, or locate a Grain on a specific server" |
| Supervision Hierarchy | a parent-child tree of actors where a parent supervisor decides whether to `Resume`, `Restart`, `Stop`, or `Escalated` a child actor when an internal fault occurs | "let it crash and heal via parent supervision, distinguished from normal domain validation errors" |
| Space-Based Architecture (SBA) | a distributed architecture named after tuple spaces that removes the central database from the synchronous hot path by partitioning work across **Processing Units** and an **In-Memory Data Grid** | "built for extreme, elastic high-concurrency read/write spikes (ticketing, auctions, gaming, IoT)" |
| Processing Unit (PU) | the self-contained unit of scalability and failover in SBA, containing application logic plus an in-memory data-grid partition and optional web/messaging frontend | "scale by adding Processing Unit instances seamlessly" |
| Virtualized Middleware (SBA Grids) | the four cluster engines coordinating SBA: **Messaging Grid** (request routing), **Data Grid** (replicated in-memory state), **Processing Grid** (master/worker parallel orchestration), and **Deployment Manager** (SLA-driven elasticity) | "the middleware fabric that keeps Processing Units synchronized" |

## Core architectural rules and invariants

1. **Zero shared mutable state — communicate only via immutable messages:** Never pass mutable objects by reference between actors, and never use low-level locks/mutexes across actors. Every message sent to an actor or grain must be deeply immutable and serializable across the network.
2. **Never block the Actor / Grain execution thread:** An actor processes its mailbox sequentially on a lightweight scheduler thread. Never run blocking synchronous I/O (`Thread.Sleep`, synchronous HTTP/SQL, or heavy CPU loops) inside an actor message handler; use asynchronous non-blocking I/O or offload heavy CPU work to a dedicated worker pool / stateless worker grain.
3. **Keep Actor/Grain granularity fine and state bounded:** Model one actor per fine-grained domain entity (`DeviceGrain(deviceId)`, `CartGrain(cartId)`, `PlayerGrain(playerId)`), never a single "God Actor" (`AllOrdersActor`) that serializes every user's request through one mailbox.
4. **Distinguish Domain Validation Errors from Supervision Faults:**
   - If a message fails business validation (e.g., invalid user ID or insufficient funds), the actor state is intact — return an explicit domain error message to the caller.
   - If the actor hits an unexpected system fault (corrupted state, crash), throw/fail and let the **Parent Supervisor** (or Virtual Actor runtime) restart or deactivate the actor to restore a clean state.
5. **Space-Based Data Grid Persistence must be asynchronous (Write-Behind) with Replication:** In Space-Based Architecture, Processing Units read and write exclusively to the replicated In-Memory Data Grid on the hot path. A separate asynchronous **Data Pump** flushes grid mutations to the physical database (Write-Behind). Ensure at least $N \ge 2$ synchronized in-memory replicas across distinct nodes so a node crash before the Data Pump flushes does not lose committed transactions.
6. **Prevent Deadlocks and Reentrancy surprises in Actor Call Graphs:** Avoid synchronous request-response cycles (`Actor A` awaits `Actor B` while `Actor B` awaits `Actor A`). Prefer one-way tell/event messages or acyclic call hierarchies, and mark reentrancy explicitly only where safe.

## Building order

1. **Choose the right model for the bottleneck:**
   - Use **Actor Model / Virtual Actors (Orleans/Akka)** when millions of independent stateful entities (IoT devices, game sessions, live carts, chat rooms) need concurrent single-threaded state mutations without DB row-lock contention.
   - Use **Space-Based Architecture** when extreme traffic spikes (flash sales, concert ticketing, bidding) would crush a central relational database even with read caching, because writes themselves must execute in distributed memory.
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
- **Unbounded Actor Mailboxes:** Allowing a fast producer to enqueue millions of messages into a slow actor's unbounded mailbox until the node crashes with an Out-Of-Memory error. Always use bounded mailboxes or backpressure streams.
- **Using Space-Based Architecture with a huge dataset that cannot fit in RAM:** SBA requires active working-set partitions to reside in the distributed in-memory data grid; if the hot working set exceeds cluster memory budgets and thrashes to disk, SBA loses its core advantage.
