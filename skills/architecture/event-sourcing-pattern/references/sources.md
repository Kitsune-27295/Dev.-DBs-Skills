# Sources — Event Sourcing Pattern

Every URL below was re-fetched on 2026-11-27 (rebuild pass; first authoring pass was 2026-11-22).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Martin Fowler, "Event Sourcing", https://martinfowler.com/eaaDev/EventSourcing.html | 200, dated 2005-12-12, draft material | Definition, complete rebuild, temporal query, event replay and reversal, external updates and queries, code changes, snapshots |
| Microsoft Azure Architecture Center, "Event Sourcing pattern", https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing | 200, page date 2026-03-27 | Complexity warning, rehydration, optimistic concurrency, intent-focused events, versioning strategies, idempotency, snapshots, GDPR options, use/avoid lists, a broker is not an event store |
| Chris Richardson, "Pattern: Event sourcing", https://microservices.io/patterns/data/event-sourcing.html | 200 | Event sourcing as atomic state-plus-event persistence, event store as broker, benefits and drawbacks, snapshot as load optimization. The current page does NOT cover idempotent consumers, GDPR or schema evolution (confirmed with curl) |
| Oskar Dudycz, EventSourcing.NetCore, https://github.com/oskardudycz/EventSourcing.NetCore | 200, CC-BY-SA-4.0, about 100k of 111k characters read | Index of practitioner material: short streams, `Evolve`, versioning topics, GDPR videos, anti-patterns. Ideas restated in own words; no text copied |

## Reading limits
- The Dudycz README is an index of links; linked articles and videos were not opened.
- No scripts or data files in this skill.

## Claims not adopted as fact
- A numeric snapshot threshold ("hundreds or thousands of events"): no source gives one; Azure says "every N events".
- "Version every event from day one": own advice; Azure lists strategies only.
- A `UNIQUE (stream_id, version)` constraint as the only way to enforce append concurrency: an implementation choice; Azure requires only that the store rejects a stale append.
- `decide`/`evolve` as official terms: Dudycz uses `Evolve`; "decide" is a common convention, not in the sources.
- Richardson as the source for idempotent consumers or GDPR: Azure is the source.
