# Streams, State Aggregation and Practitioner Guide (Dudycz)

Sources: https://github.com/oskardudycz/EventSourcing.NetCore · Last verified 2026-11-27

Read note: the README is mostly an index of links and videos (licence CC-BY-SA-4.0). The fetch returned about 100,000 of 111,000 characters, so the tail was not read; the README never mentions "decide", so the decide/evolve naming below is a common functional convention, not a source quote ("Keep your streams short!" is a video title in section 2.2).

## Vocabulary
- Event: a past-tense, immutable fact, readable differently by different consumers. Typical fields: id, type, stream id, stream position, timestamp, metadata (correlation and causation ids).
- Stream: one per entity or process, identified by a unique id; position orders events and exposes concurrency conflicts.
- Storage is agnostic: all you need is an append-only log; dedicated event stores (Marten on Postgres, KurrentDB) are implementations.

## State rehydration
Read the stream ordered by position, start from an empty entity, apply each event. A generic `Evolve` dispatches to typed `Apply` methods (Marten finds `Apply(Event)` by convention). Online aggregation always runs current business logic, so a logic change needs no data migration; inline snapshots are stored documents that must be re-aggregated after logic changes.

## Modeling notes
- Aggregate base: id, version, queue of uncommitted events dequeued on save.
- Strongly typed ids (`ReservationId`) catch argument mix-ups; cost is serialization and LINQ friction. Marten wants string or Guid ids, so expose a backing property.
- Aggregates are optional: the Helpdesk sample uses commands as pure functions and no aggregate class.

## Topics the repo covers (titles read, bodies partly unread)
Keeping streams short (the ClosingTheBooks sample models closing and opening periods so streams do not grow forever), anti-patterns (property sourcing, state obsession), when not to use ES, projections and read models, testing projections, snapshots, event versioning (simple mapping for new optional/required/renamed properties, upcasting, downcasters, stream transformations, contract testing), GDPR with crypto-shredding, ETags for optimistic concurrency, outbox and inbox, sagas, uniqueness, out-of-order events and idempotency in workshops.

## Why short streams matter (reasoning, partly inference)
Long streams make rehydration slow and make schema evolution touch more history. Model a stream around a bounded lifecycle (a hotel stay, an accounting period) and close it, carrying a summary into the next stream, instead of one stream per entity forever. Snapshots fix performance but not the evolution burden.

## Property sourcing anti-pattern
Events named after property changes (`NameChanged`, `StatusSetTo`) mirror a CRUD table and lose intent. Prefer business facts (`OrderShipped`).

## Sketch: decide/evolve split
```ts
type Cmd = { type: "Reserve"; seats: number };
type Ev  = { type: "SeatsReserved"; seats: number } | { type: "ReservationRejected" };
const evolve = (s: State, e: Ev): State => e.type === "SeatsReserved" ? { ...s, free: s.free - e.seats } : s;
const decide = (s: State, c: Cmd): Ev[] => s.free >= c.seats ? [{ type: "SeatsReserved", seats: c.seats }] : [{ type: "ReservationRejected" }];
// handler: state = fold(evolve, initial, stream); append(decide(state, cmd), expectedVersion)
```

## Internal vs public events
Dudycz and DDD practice warn against exposing every internal persistence event as a public contract; translate to integration events at the boundary (also stated by Microsoft).

## How an agent should apply this
- Keep `evolve` pure and total, and `decide` pure and side-effect free; infrastructure stays in the handler.
- Bound each stream to a business lifecycle; add a closing/summary event rather than relying only on snapshots.
- Name events as business facts in the past tense; reject property-level events.
- Prefer online aggregation until measurements justify snapshots, and rebuild snapshots after logic changes.
- Use correlation and causation ids in metadata from day one.
