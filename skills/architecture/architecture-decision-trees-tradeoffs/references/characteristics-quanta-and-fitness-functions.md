# Architecture Characteristics, Quanta, Coupling and Fitness Functions

Sources: https://github.com/pkardas/notes/blob/master/books/fundamentals-of-architecture.md (third-party study notes on Richards and Ford, Chapters 1-9) · Last verified 2026-11-27

This is a secondary source (reader's notes), so treat claims as the notes' rendering of the book.

## Laws and dimensions

- Everything in architecture is a trade-off; an apparent non-trade-off means it is not yet found. Why matters more than how.
- Frozen Caveman anti-pattern: an architect who reverts to a pet concern for every architecture.

## Characteristics

A characteristic qualifies when it (1) is non-domain, (2) influences structure, (3) is critical to success.

- Groups used in this skill: operational, structural, cross-cutting (the item lists were not re-read in the 2026-11-27 pass). Explicit (in requirements) versus implicit (needs domain knowledge).

Rules: have stakeholders pick about the top three from the final list; over-specifying bloats design (the notes cite the Vasa warship, too heavy and too complicated). Scalability (many concurrent users without serious degradation) is not elasticity (bursts of requests). For an example of drivers mapped to characteristics see [architecture-styles-as-constraints.md](architecture-styles-as-constraints.md).

## Measuring: fitness functions

An architectural fitness function is any mechanism giving an objective integrity assessment of one characteristic or a combination: metrics, monitors, unit tests, chaos engineering. Choosing measures per characteristic is the skill's own advice.

```
# fitness function sketch (own example)
assert p99_latency("/checkout", load=500rps) < 400  # performance
assert no_import_cycles("domain/*")                  # modularity
```

## Connascence

Two components are connascent if changing one forces changing the other. Static connascence is source-level coupling; dynamic connascence shows up only at runtime. The notes' kind-by-kind ranking was not re-read; prefer static, weaker forms and keep strong coupling inside a module (design guidance).

## Architecture quantum

An independently deployable artifact with high functional cohesion and synchronous connascence. Whether a shared database merges quanta, and the plug-in case, were not re-read; treat them as inference. Practical use: the quantum count tells you how many places need distinct characteristic profiles (for example one part needs elasticity, another does not).

## Partitioning and components

- Technical partitioning (layers) finds code by capability; domain partitioning (DDD, microservices) matches how change arrives.
- Conway's law: designs copy the organization's communication structure.
- **Entity trap** anti-pattern: components defined around database relationships rather than workflows; usually too coarse.

## Distributed reality

Eight fallacies (reliable network, zero latency, infinite bandwidth, secure network, fixed topology, one administrator, free transport, homogeneous network). **Stamp coupling** is sending or receiving far more data than the caller needs; the notes' example compares 2,000 requests at large versus small payloads. Mitigations, distributed-transaction advice and the big-ball-of-mud claim were not re-read.

## How an agent should apply this

- Elicit and rank at most three driving characteristics before proposing any style.
- For each chosen characteristic, propose one concrete fitness function.
- Count quanta; if one quantum cannot serve conflicting characteristic needs, say where to split.
- Prefer domain partitioning when change follows business workflows; call out entity-trap designs.
- Mark claims sourced from these notes as secondary.
