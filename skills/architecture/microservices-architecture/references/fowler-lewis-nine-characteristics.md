# Fowler and Lewis: The Nine Characteristics in Depth

Sources: https://martinfowler.com/articles/microservices.html · Last verified 2026-11-23

The article stresses there is no formal definition; these are traits most, not all, microservice systems share.

## The characteristics, with their sharp edges
1. Componentization via services: out-of-process, so independently deployable and with explicit remote interfaces that resist encapsulation breaches. Costs: remote calls are slower so APIs must be coarser; moving responsibility across processes is hard.
2. Organized around business capabilities: criticizes UI/server/DB team splits (cross-team approvals, logic drifting to whichever codebase is reachable). Teams are cross-functional and own a vertical slice.
3. Products, not projects: the team owns the service for its life ("you build it, you run it"), which ties developers to production behavior.
4. Smart endpoints, dumb pipes: logic in services, not in an ESB (the authors' footnote jokes "Erroneous Spaghetti Box"). Use plain HTTP/REST and lightweight messaging (RabbitMQ, ZeroMQ named). Pitfall: turning in-process calls straight into RPC gives chatty, slow interactions; coarsen them.
5. Decentralized governance: per-service tool choice (examples: Node.js for a reports page, C++ for a near-real-time part), shared tools preferred over written standards, consumer-driven contracts and Tolerant Reader to limit central contract control.
6. Decentralized data management: each service owns its store, possibly different technologies; no distributed transactions; eventual consistency with compensations, acceptable where fixing mistakes costs less than the business lost to stricter consistency.
7. Infrastructure automation: CI/CD with heavy automated testing; monitoring of both technical and business metrics (orders per minute) and "semantic monitoring" as early warning.
8. Design for failure: every remote call can fail so clients must degrade gracefully; Circuit Breaker, Bulkhead, Timeout; Netflix's Simian Army injects failures in production hours; emergent behavior from choreography needs real-time monitoring.
9. Evolutionary design: services are replaceable or disposable; things that change together belong together (if two services keep changing together, merge them); The Guardian kept a monolith core and added short-lived features as services; versioning is a last resort, prefer tolerant consumers.

## Sidebars worth remembering
- Size: no fixed rule; examples run from "two pizza team" to one team supporting several services.
- Synchronous calls considered harmful: chained synchronous calls multiply downtime; The Guardian limits itself to one synchronous call per user request.
- SOA relation: overlaps with SOA, but many SOA efforts failed through ESB-centric design and central governance.
- Standards should be proven by several implementations, not imposed top-down.

## Authors' caution ("Are microservices the future?")
Cautiously optimistic, but: monoliths decay and microservice boundaries may resist decay (unproven); boundaries are hard to get right and refactoring across services is much harder than across modules; poor composition just moves complexity into the connections where it is less visible; a good in-process interface is often a poor service interface; a weak team will build a weak system either way.

## Tension points
Independence vs coordination of interface changes; transparency (HTTP) vs performance (binary protocols); autonomy vs operational and skill overhead; eventual consistency vs business guarantees; easy to draw boundaries, costly to move them.

## Example: coarsening a chatty call
```
before: for id in ids: GET /products/{id}        # N remote calls
after : POST /products/batch {ids:[...]}          # one remote call, one failure mode
```

## How an agent should apply this
- Check a proposed service against all nine traits; if team ownership (2, 3) or per-service data (6) is missing, call it a distributed monolith.
- Refuse in-process-style fine-grained APIs across the network; design coarse operations.
- Allow at most one synchronous hop on the user path; make the rest asynchronous.
- Treat service pairs that always change together as a merge candidate.
- Require timeouts, circuit breakers and business-level monitoring before a service goes to production.
