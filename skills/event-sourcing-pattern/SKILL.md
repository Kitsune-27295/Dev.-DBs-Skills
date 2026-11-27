---
name: event-sourcing-pattern
description: Use when evaluating, designing, or reviewing an Event Sourcing implementation — persisting state changes as an immutable, append-only sequence of domain events (streams), reconstituting aggregates by replaying events, handling optimistic concurrency, snapshots, schema evolution (upcasting), external side effects during replay, and GDPR/privacy. Gives stream invariants, replay rules, CQRS pairing, and common mistakes.
---

# Event Sourcing Pattern

One idea: instead of overwriting the current state of an entity in place (CRUD), store **every state change as an immutable, append-only sequence of domain events** in an Event Store — making the event log itself the primary system of record from which current, historical, or projected state can be deterministically reconstructed at any time. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Fowler, Richardson & Dudycz)

| Term | Meaning | Test sentence |
|---|---|---|
| Domain Event | an immutable fact named in past tense (`ShipArrived`, `InvoiceIssued`) capturing a state transition and its parameters | "stored forever in the exact sequence it occurred" |
| Event Stream | the ordered sequence of events belonging to a single Aggregate instance (identified by `streamId` / `aggregateId`) | "keep streams short and aligned to one aggregate lifecycle" |
| Aggregate Reconstitution (Folding) | rebuilding an entity's current in-memory state by starting from an empty state and applying its stream's events in order (`state = fold(events, apply)`) | "`apply(event)` is a pure deterministic function with zero I/O or validation" |
| Optimistic Concurrency Check | appending a new event to a stream only if the stream's current `version` in the database matches the `expectedVersion` read when the aggregate was loaded | "prevents lost updates without heavy pessimistic row locks" |
| Snapshot | a cached checkpoint of an aggregate's folded state at `version = N` so reconstitution only replays events `> N` | "an optimization for long streams, never the source of truth" |
| Projection / Materialized View | an external read model (`cqrs-pattern`) updated by subscribing to the event store so queries do not have to replay streams on the fly | "how an event-sourced system answers list, search, and report queries" |
| Upcaster | a pure transformation function that converts an older persisted event schema (`v1`) into the current in-memory format (`v2`) during stream loading | "how event schemas evolve without mutating immutable history" |

## Non-negotiable architectural rules and invariants

1. **The Event Log is append-only and immutable:** Never `UPDATE` or `DELETE` a committed business event to change business state. To undo a past action, append a new **compensating / reversing event** (`EntryReversed`, `OrderCancelled`) that records the correction.
2. **Separate Command Decision (`decide` / `handle`) from State Evolution (`apply` / `evolve`):**
   - **Command handling (`decide`)** validates business rules against current state and emits new uncommitted events (or throws a domain error).
   - **Event application (`apply`)** mutates the in-memory state from an already-accepted event. `apply` **must never throw validation errors, check current wall-clock time, generate random IDs, or call external services**, because it runs every time historical events are replayed!
3. **Enforce Optimistic Concurrency on every stream append:** Every `append(streamId, expectedVersion, newEvents)` must atomically verify a unique `(stream_id, version)` constraint in the Event Store. If a concurrent command incremented the version first, reject and retry or fail cleanly.
4. **Silence external gateways during Event Replay:** When replaying historical events to rebuild state or projections, external side effects (sending emails, charging credit cards, calling third-party APIs) **must be suppressed or isolated to live command/subscription handlers**. Never call an external gateway inside an event `apply` method.
5. **Pair Event Sourcing with CQRS for queries:** An Event Store is keyed by `streamId`. You cannot efficiently run `SELECT * FROM orders WHERE status = 'PENDING'` by replaying 100,000 streams on every HTTP GET. Subscribe projectors to the event stream to maintain queryable read models (`cqrs-pattern`).
6. **Keep streams short and plan for Schema Evolution & Privacy (GDPR):** Model streams around bounded lifecycles (e.g., `ShoppingCart-123` or `AccountLedger-2026-11`, not one infinite stream for an entire tenant). Version every event payload from day one, use non-breaking additive changes + Upcasters, and handle PII deletion requirements via **Crypto-Shredding** (encrypting PII with a per-subject key that can be deleted) or storing sensitive PII in a separate lookup table outside immutable events.

## Building order

1. **Model the domain events and short streams:** Discover the past-tense facts and aggregate boundaries; verify that each stream has a clear lifecycle and bounded length.
2. **Write the pure Aggregate (`decide` + `apply`) test-first:** Test every command in `Given(pastEvents) -> When(command) -> Then(expectedNewEvents or error)` format with zero database or framework dependencies.
3. **Configure the Event Store with optimistic concurrency:** Ensure `(stream_id, version)` has a strict `UNIQUE` constraint and atomic batch append.
4. **Build idempotent CQRS Read Projections:** Project committed events into read tables (`last_processed_version` / checkpoint tracking) for UI queries.
5. **Add Upcasters and Snapshots only when needed:** Add upcasters when an event schema changes; add snapshots only if profiling shows a specific stream exceeds hundreds/thousands of events and slows down aggregate loading.

## Testing strategy (`Given / When / Then`)

| Component | Test | Uses |
|---|---|---|
| Aggregate Command & Evolution | pure `Given([events]) / When(cmd) / Then([newEvents])` unit tests | zero mocks, zero database; fast, deterministic specifications |
| Event Store Concurrency | database integration test | two parallel appends with the same `expectedVersion` (one must fail with concurrency conflict) |
| Upcasting / Schema Evolution | unit test | loads recorded historical JSON fixtures (`v1`) and verifies upcaster produces valid `v2` events |
| Read Projections | integration test | replays a sequence of events (plus duplicate delivery) and asserts the resulting SQL/document read model |

## When it earns its keep

- **Worth it:** Domains where an immutable audit trail, regulatory compliance, temporal queries ("what was the account state on Tuesday at 14:03?"),retroactive error correction, or atomic domain-state-plus-event persistence without 2PC (`microservices.io`) are core business requirements (e.g., accounting ledgers, financial trading, medical records, logistics tracking, complex workflow engines).
- **Not worth it:** Ordinary CRUD domains where only the latest state matters, where schema changes are frequent and casual, or where teams are unprepared for eventual consistency, projection rebuilding, and event versioning. Adopt inside the specific Bounded Context that needs it, never globally.

## Mistakes to catch

- **Putting validation or external I/O inside `apply(event)`:** Throwing a business exception or sending an email inside the state-folding method. If a business rule changes next year, replaying last year's valid events will crash your aggregate!
- **Treating internal Event-Sourcing events as public cross-service integration events:** Exposing fine-grained internal storage events directly to external microservices couples every other team to your internal persistence schema. Publish separate, coarse-grained public Integration Events at the module/service boundary.
- **Infinite streams ("God Stream"):** Appending millions of events across years to a single stream without lifecycle boundaries (e.g., closing the book per billing period), causing `O(N)` replay latency spikes.
- **Storing raw unencrypted GDPR PII inside immutable events:** Putting raw names/emails in an immutable event store with no crypto-shredding or external reference strategy when "right to erasure" applies.
- **Recording external query results only by calling the external system live:** As Fowler notes, if domain logic depends on an external tax or exchange-rate lookup, record the returned rate *inside the event payload* when the command executes so future replays remain 100% deterministic without calling the external service again.

## Quick Decision Checklist

- [ ] Does this domain need an audit trail, temporal queries or retroactive correction, rather than plain CRUD?
- [ ] Am I correcting history with a compensating event, never an UPDATE or DELETE of a committed one?
- [ ] Is apply free of validation, clock reads, random ids and external calls?
- [ ] Does every append check expectedVersion against a unique (stream_id, version) constraint?
- [ ] Are external side effects suppressed during replay, with external lookup results stored in the event payload?
- [ ] Are streams short and bounded, with versioned events and upcasters for schema changes?
- [ ] Are queries served by CQRS projections, with PII kept out of raw events?
- [ ] Are public integration events separate from internal storage events?

## Deep references

- [Replay semantics: external effects, reversal and code changes](references/replay-external-effects-and-code-changes.md) — read when designing replays, gateways, retroactive fixes or temporal rules.
- [Operational considerations: versioning, concurrency, GDPR and fit](references/azure-considerations-versioning-gdpr-and-fit.md) — read when deciding whether to adopt ES or planning schema evolution, idempotency and privacy.
- [Streams, state aggregation and practitioner guide](references/streams-aggregation-and-practitioner-guide.md) — read when modeling streams, evolve/decide functions, snapshots and event naming.
