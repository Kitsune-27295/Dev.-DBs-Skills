# Message Queues vs Publish/Subscribe (Valente)

Sources: https://engsoftmoderna.info/cap7.html (sections 7.5 and 7.6, read in translation; both sections confirmed present) · Last verified 2026-11-27

## Message queue architecture (7.5)

A broker (the queue) sits between producers (clients inserting messages) and consumers (servers removing and processing them). FIFO order; the client continues working after enqueuing, so interaction is asynchronous. The broker must be persistent and run on stable, high-capacity hardware, and teams normally buy or adopt an existing broker rather than build one.

Two kinds of decoupling:
- **Space**: producers do not know which consumers exist, consumers do not know who produced.
- **Time**: both need not be online together; messages accumulate while a consumer is down.

Benefits named: independent evolution while the message format stays stable, robustness to failures, easy scaling (add consumers on the same queue), and brokers being treated as infrastructure-team responsibility.

Book example: a telecom sales system enqueues "package bought"; the engineering system consumes it and activates the service, replacing a nightly batch file that could leave customers waiting almost a day.

## Publish/subscribe (7.6)

Messages are called events. Publishers send to an event broker; subscribers register interest beforehand, optionally by topic, and are notified. It resembles the Observer pattern but across distributed processes.

Differences from queues:

| Aspect | Queue | Pub/Sub |
|---|---|---|
| Delivery | One consumer gets each message (1:1) | All subscribers get each event (1:N, group communication) |
| Receiving | Consumers pull | Subscribers are notified asynchronously |
| Space/time decoupling | Yes | Yes |

Book example: an airline "sale" event (flight, date, passenger) is consumed by the miles system, marketing (upgrade or rental offers) and accounting, with no change to the sales system when a fourth subscriber is added.

## Trade-offs (the page has no explicit section; these are read from its text)

- Both models depend on a persistent, high-capacity broker (7.5 states this for queues; extending it to pub/sub is our inference).
- Results are not instantaneous (our reading; a busy consumer delays work).
- Teams are independent only as long as message formats stay stable; changing a format affects every consumer, which links to schema versioning in the Azure reference.

## Decision rules (own synthesis)

- Work distribution (each job done once, scale by adding workers): queue.
- Broadcast of a business fact to several independent reactors: pub/sub.
- Need history, replay, late joiners: add a durable log (see the streaming section in `azure-eda-topologies-and-challenges.md`).

## Example

```
queue "activate-service":   sales -> [msg] -> one engineering worker
topic "sale.completed":     sales -> [evt] -> miles, marketing, accounting (each gets a copy)
```

## How an agent should apply this

- Ask "should exactly one consumer handle this, or every interested party?" before choosing queue or topic.
- Treat the message format as a public contract and version it.
- Explain space and time decoupling concretely when justifying a broker to stakeholders.
- Do not propose building a broker; recommend an existing persistent one.
