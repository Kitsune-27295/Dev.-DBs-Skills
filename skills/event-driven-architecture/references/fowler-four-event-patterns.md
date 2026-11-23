# Fowler's Four "Event-Driven" Patterns in Depth

Sources: https://martinfowler.com/articles/201701-event-driven.html · Last verified 2026-11-23

Fowler's article exists because a workshop discovered that "event-driven" meant four different things to different people. Most arguments ("event sourcing is a disaster", "async is too hard") are really arguments about a pattern the speaker did not name. Name the pattern first.

## The four patterns

| Pattern | What moves | Core benefit | Core cost |
|---|---|---|---|
| Event Notification | "Something changed" (often just an id plus a link back) | Low coupling, trivial to add | Overall flow is invisible in code |
| Event-Carried State Transfer | The changed data itself | Consumers survive source outages, no query load on the source, lower latency | Copies everywhere, each receiver must maintain its own state correctly |
| Event Sourcing | The log of every state change is the source of truth | Audit, replay to any past state, alternative histories | Replay with external side effects, schema change over time, extra complexity |
| CQRS | Nothing in particular (separate read and write models) | Simpler models in complex domains, asymmetric load | Two models to maintain; many teams misuse it |

## Event Notification mechanics and trap

The sender does not care about the reply; the reacting logic is cleanly separated from the sending logic. The price: the end-to-end business flow across several notifications is written down nowhere. You can often only reconstruct it by watching a running system, so debugging and modification get hard.

The **passive-aggressive command** (Fowler's term): the sender actually needs a specific receiver to do something, which is a command, but disguises it as an event. Symptom: removing one subscriber silently breaks the sender's business outcome.

Typical thin event: `OrderPlaced { orderId, href }`. The receiver then calls back to read details, which creates load on the producer if many subscribers do so at once.

## Event-Carried State Transfer mechanics

A customer system publishes `CustomerAddressChanged` carrying the new address; each subscriber updates its local copy and never calls the customer system. Gains: resilience, latency, offloaded source. Losses: duplication (Fowler considers storage cost minor) and receiver complexity; he notes that simply calling the sender is often simpler when the data is rarely needed.

## Event Sourcing: three misconceptions Fowler corrects

1. Event processing does not have to be asynchronous (a local git commit is synchronous event sourcing).
2. Not every component needs to read the log; most code can use a derived working copy and never see events.
3. Events and snapshots are two views of the same data; snapshots are a replay-cost optimization.

Problems: replay is hard if results depend on outside systems (re-sending emails, re-charging cards), and event schemas evolve. Fowler suspects much of the perceived complexity comes from failing to separate "derive the working copy" code from "domain processing" code.

## CQRS in this article

Strictly not about events at all. It is "separate data structures for reading and writing". Fowler's anecdote: a team called event sourcing a disaster because every change meant updating both a read and a write model; that was CQRS cost, not event-sourcing cost, and the team lead blamed async messaging, which neither pattern requires. For CQRS detail see the `cqrs-pattern` skill.

## Decision rules

- Use Event Notification when the sender truly does not depend on any reaction. Avoid it when you can describe the happy path only by listing which subscribers must act.
- Use Event-Carried State Transfer at boundaries where availability or latency matters more than a single copy of the data; avoid it for rarely-read or highly sensitive data.
- Use Event Sourcing when audit or temporal queries are first-class requirements; avoid it when you only want a message bus.
- Choose each pattern independently; adopting one does not imply the others.

## How an agent should apply this

- When a request says "make it event-driven", ask or state which of the four patterns is meant before designing.
- If a proposed event name is an imperative (`SendInvoice`), flag it as a probable command and suggest a command message or direct call.
- Document the multi-hop flow of any notification chain in a sequence diagram, because the code will not show it.
- Never bundle event sourcing and CQRS in one recommendation unless each is separately justified.
- Review event schemas for evolution (versioning, tolerant readers) before accepting event-carried state.
