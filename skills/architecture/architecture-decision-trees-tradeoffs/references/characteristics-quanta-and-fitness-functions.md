# Architecture Characteristics, Quanta, Coupling and Fitness Functions

Sources: https://github.com/pkardas/notes/blob/master/books/fundamentals-of-architecture.md (third-party study notes on Richards and Ford, Chapters 1-9) · Last verified 2026-11-23

This is a secondary source (reader's notes), so treat claims as the notes' rendering of the book.

## Laws and dimensions

- Everything in architecture is a trade-off; an apparent non-trade-off means it is not yet found. Why matters more than how.
- Architecture has four dimensions: structure/style, characteristics, decisions, design principles.
- Architects favor breadth over depth, stay hands-on (proofs of concept, code reviews), and watch out for the Frozen Caveman anti-pattern (reapplying one past fear everywhere).

## Characteristics

A characteristic qualifies when it (1) is non-domain, (2) influences structure, (3) is critical to success.

- **Operational**: availability, performance, reliability, scalability, recoverability, robustness.
- **Structural**: maintainability, extensibility, portability, upgradeability, configurability.
- **Cross-cutting**: security, privacy, accessibility, legal, usability, authentication/authorization.
- Explicit (in requirements) versus implicit (needs domain knowledge).

Domain-driver mapping from the notes: time to market -> agility, testability, deployability; user satisfaction -> performance, availability, fault tolerance, security; mergers -> interoperability, adaptability, extensibility; tight time and budget -> simplicity, feasibility.

Rules: have stakeholders pick about the top three; over-specifying bloats design (Vasa warship); aim for "least worst". Scalability (many users) is not elasticity (bursts).

## Measuring: fitness functions

An architectural fitness function is any mechanism giving objective integrity feedback on a characteristic: metrics, monitors, unit tests, chaos experiments, automated scalability tests. Define characteristics precisely (they are vague and composite) as operational (response-time statistics), structural (cyclomatic complexity) or process measures (agility). Developers should understand the function before it is enforced.

```
# fitness function sketch (own example)
assert p99_latency("/checkout", load=500rps) < 400  # performance
assert no_import_cycles("domain/*")                  # modularity
```

## Connascence

Two components are connascent if changing one forces changing the other. Static kinds (name, type, meaning, position, algorithm) are source-visible; dynamic kinds (execution, timing, values, identity) are runtime-only and harder to analyze. Weakest is name, strongest is identity. Prefer static, weaker forms; keep strong connascence within a module, not across services.

## Architecture quantum

An independently deployable unit with high functional cohesion and synchronous connascence, containing everything it needs including its data. Separate databases make separate quanta; a shared database must be owned by one quantum. Plug-ins deployed as services inside a monolithic core still form one quantum. Practical use: the quantum count tells you how many places need distinct characteristic profiles (for example one part needs elasticity, another does not).

## Partitioning and components

- Technical partitioning (layers) finds code by capability; domain partitioning (DDD, microservices) matches how change arrives.
- Conway's law: structure mirrors communication structure.
- **Entity trap** anti-pattern: components derived from database tables rather than workflows. Alternatives: actor/actions, event storming, workflow.
- Granularity: too fine = chatty, too coarse = internal coupling.

## Distributed reality

Eight fallacies (reliable network, zero latency, infinite bandwidth, secure network, fixed topology, one administrator, free transport, homogeneous network) motivate timeouts and breakers. Notes' arithmetic example: 2,000 req/s times 500 KB is about 1 GB/s. Distributed transactions are hard, so eventual consistency and sagas appear. **Stamp coupling** (receiving far more data than needed) is mitigated with private endpoints, field selectors, GraphQL or messaging. Big ball of mud arises from weak governance.

## How an agent should apply this

- Elicit and rank at most three driving characteristics before proposing any style.
- For each chosen characteristic, propose one concrete fitness function.
- Count quanta; if one quantum cannot serve conflicting characteristic needs, say where to split.
- Prefer domain partitioning when change follows business workflows; call out entity-trap designs.
- Mark claims sourced from these notes as secondary.
