---
name: cqrs-pattern
description: Use when evaluating, designing, or reviewing Command Query Responsibility Segregation (CQRS) or Command Query Separation (CQS) in a Bounded Context — splitting write models (Commands) from read models (Queries), handling eventual consistency between separate read/write stores, or avoiding unnecessary CQRS over-engineering on simple CRUD domains. Gives CQS vs CQRS rules, 3 levels of separation, sync/async projection rules, and common mistakes.
---

# CQRS (Command Query Responsibility Segregation) Pattern

One idea: extend Bertrand Meyer's method-level **Command Query Separation (CQS)** to the architectural model level — split a single unified CRUD data model into two separate models: a **Command (Write) Model** optimized for transactional invariants and task-based business mutations, and a **Query (Read) Model** optimized for fast, pre-shaped projections — **only** inside a specific Bounded Context where read/write asymmetry or domain complexity justifies the extra moving parts. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Meyer, Fowler & Young)

| Term | Meaning | Test sentence |
|---|---|---|
| CQS (Command Query Separation) | Meyer's method-level rule: every method is either a **Command** (mutates observable state, returns no data) or a **Query** (returns data, has zero side effects) | "asking a question must never change the answer" |
| CQRS | Greg Young's architectural pattern: using completely separate object/data models for Commands (writes) and Queries (reads) | "two distinct models instead of one shared CRUD entity graph" |
| Task-Based Command | an explicit business intention object (e.g., `BookHotelRoomCommand`, not `UpdateRoomStatusDto`) validated and processed by a Command Handler | "models why the user is changing state, not a raw table row update" |
| Read Model / Projection | a denormalized DTO, SQL view, or dedicated read store tailored 1:1 to a UI screen or query consumer | "zero domain logic; reads bypass domain aggregates entirely" |
| Single-Store CQRS | separate Command and Query code models (e.g., rich DDD ORM aggregates for writes, raw SQL/Dapper/views for reads) over the **same** relational database | "strong ACID consistency with zero projection lag or sync buses" |
| Dual-Store CQRS | Command store and Read store are physically separate databases synchronized asynchronously via domain events | "independent read/write scaling, but introduces eventual consistency" |
| Reporting Database | offloading only heavy analytical/reporting queries to a separate replica while keeping normal app reads and writes on a unified model | "simpler alternative when only a few complex reports hurt performance" |

## Core architectural rules and invariants

1. **Commands mutate state and return no domain payload; Queries never mutate state:** A Command may only return an acknowledgement (`void`, `202 Accepted`, newly created ID/version, or validation errors). A Query must never alter observable state, write audit mutations, or trigger domain side effects.
2. **Apply CQRS per Bounded Context, never across the entire system by default:** Most submodules of an application are simple CRUD and should stay CRUD. Use CQRS only in the specific Bounded Context that has severe read/write skew or complex collaborative domain invariants.
3. **Never route Queries through Domain Aggregates:** If your Query handler loads a rich DDD Aggregate from a Repository just to map it to a DTO, you have paid the cost of CQRS without getting the benefit. Queries should project directly from the database (views, thin SQL, or materialized read tables) into the response DTO.
4. **Prefer Single-Store CQRS before Dual-Store CQRS:** Start by separating the write model (domain aggregates + transactions) and read model (direct SQL projections or DB views) over the **same transactional database**. Only split into physically separate read and write databases when scaling or lock-contention measurements prove a single database cannot handle the load.
5. **Handle eventual consistency explicitly in Dual-Store CQRS:** When read projections update asynchronously via events, a user who submits a Command and immediately queries the Read Store may see stale data. Design the UI/API to handle this (e.g., return the new resource ID/version from the Command, use optimistic UI updates, or pass a version token so the read endpoint knows if the projection has caught up).
6. **CQRS does not require Event Sourcing:** You can (and often should) use CQRS with standard relational state storage on the write side. Combine CQRS with `event-sourcing-pattern` only when an immutable event log is independently justified.

## Building order

1. **Enforce method-level CQS first:** Separate mutating methods from read-only methods across services and repositories.
2. **Design task-based Commands and rich Write Aggregates:** Model writes around business intent (`PlaceOrder`, `CancelBooking`) that enforce invariants inside a transaction (`transaction-fix`, `race-condition-fix`).
3. **Build thin Query projections over the same DB (Single-Store CQRS):** Write fast, read-only SQL queries or database views returning screen-shaped DTOs with proper indexes (`query-performance`).
4. **Promote to Materialized Read Views (Dual-Store) only if required:** If read load or multi-table joins still bottleneck the write store, emit domain events via a Transactional Outbox to update a dedicated read store idempotently.

## Testing strategy

| Side | Test | Uses |
|---|---|---|
| Command Handler & Write Model | unit / domain acceptance test | verifies business invariants, state transitions, and emitted domain events |
| Query Handler (Single-Store) | database integration test | seeds real test DB rows and verifies filtering, pagination, permissions, and exact DTO projection |
| Read Model Projector (Dual-Store) | integration test | feeds domain events (including duplicates and out-of-order events) and verifies the materialized view state |
| Concurrency on Write Side | parallel race test | simultaneous conflicting commands on the same aggregate (verifies optimistic concurrency / version checks) |

## When it earns its keep

- **Worth it:** Collaborative domains where multiple actors concurrently act on the same data with complex business validation, workloads with extreme read-to-write ratio asymmetry (e.g., 100:1 reads vs. writes needing independent scaling), or systems already using `event-sourcing-pattern` (which cannot easily answer ad-hoc queries without a materialized read projection).
- **Not worth it:** Simple CRUD applications where the data read is virtually identical to the data written (Fowler warns that applying CQRS to a CRUD domain adds massive complexity, drags productivity, and puts projects in serious difficulty).

## Mistakes to catch

- **Applying Dual-Store Event-Sourced CQRS to simple CRUD:** Turning a basic form-over-data module into Command Bus + Event Store + RabbitMQ + Read Projector + MongoDB Read Store — multiplying bugs and eventual-consistency headaches for zero business value.
- **Cruddy Commands (`UpdateCustomerCommand` with 30 nullable fields):** Using CQRS syntax while still passing anemic table rows instead of task-based business intentions (`ChangeCustomerBillingAddress`).
- **Ignoring projection lag in the UI:** Redirecting the user immediately after a Command to a screen that queries an eventually consistent Read Model without showing the pending state or version check, making the user think their save failed.
- **Duplicating authorization rules inconsistently:** Enforcing tenant/role security on Commands while forgetting row-level tenant filters on the raw SQL Query projections (`security-audit`).
