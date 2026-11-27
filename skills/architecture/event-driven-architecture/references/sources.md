# Sources for the event-driven-architecture skill

Last verified 2026-11-27. All pages re-fetched with WebFetch on that date; summaries are in our own words.

| # | Source | Status | What the skill takes from it |
|---|---|---|---|
| 1 | Martin Fowler, "What do you mean by 'Event-Driven'?" (2017-02-07), https://martinfowler.com/articles/201701-event-driven.html | Read, 200 OK | Four distinct patterns (Event Notification, Event-Carried State Transfer, Event Sourcing, CQRS); passive-aggressive command; ECST trade-offs (resilience and latency against receiver-managed state); event sourcing misconceptions (not necessarily async, snapshots and change lists are two views, git as analogy); CQRS not strictly about events and often misused. |
| 2 | Microsoft Azure Architecture Center, "Event-driven architecture style", https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/event-driven | Read, 200 OK; page date 2026-03-06, live copy updated 2026-11-17 | Producer, channel, consumer; pub/sub vs event streaming vs competing consumers; consumer variations; payload styles; broker vs mediator topology; challenge catalog; when to use or avoid. |
| 3 | Marco Tulio Valente, *Engenharia de Software Moderna*, ch. 7, sections 7.5 and 7.6, https://engsoftmoderna.info/cap7.html | Read, 200 OK (Portuguese) | Queue (1:1, pull) vs pub/sub (1:N, notified); space and time decoupling; telecom and airline examples. |

## Reading limits

- The PT-PT copy of source 2 was not re-read. Pseudo-code blocks in references are ours, not from the sources.

## Claims not adopted

- Product names for pub/sub (SNS/SQS, RabbitMQ) and the Kafka-as-streaming mapping: not in sources 1 to 3 (the Azure page only names Event Grid, Event Hubs and the Kafka endpoint of Event Hubs). Removed from the skill body.
- "Snapshots are a replay-cost optimization": not stated by Fowler; replaced by his wording.
- Envelope field list (aggregate version, causation id, schema version): our convention, marked as such in the skill; only correlation ID and a versioning strategy are in the Azure page.
- "Choreography becomes an un-debuggable pinball machine" and "callback storm of 20 subscribers": our illustrations, no source; kept only as qualitative warnings.

## Nuances

- Thin vs fat events (Fowler) and keys-only vs full payload (Azure) are the same tension: neither is universally right; choose per consumer and boundary.
