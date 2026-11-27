# Architecture Styles as Constraints (Azure Architecture Center)

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/ · Last verified 2026-11-27

## Core idea

A style is a family of architectures sharing characteristics. It restricts which elements may exist and how they may relate; when the design respects those constraints, desirable properties emerge. Styles do not mandate technologies, though some fit better (containers suit microservices).

Example from the source: microservice constraints are single responsibility per service, independence between services, and private data per service. Obey them and you can deploy independently, isolate faults, ship more often and adopt new technology more easily. Break them (say, a shared database) and you keep the cost but lose the benefit: a design that only superficially conforms.

## The six styles at a glance

| Style | Dependency management | Fits | Watch out for |
|---|---|---|---|
| N-tier | horizontal tiers split by subnet; calls go downward | traditional business domains, low update frequency; lift-and-shift of layered apps | horizontal layering means a change touches many parts |
| Web-Queue-Worker | web front end and worker decoupled by a queue | simple domain with a few heavy tasks | both halves can grow into monoliths |
| Microservices | vertically decomposed services via APIs, own data each | complicated domains, frequent change | discovery, data consistency, distributed ops; needs mature DevOps |
| Event-driven | producers and consumers via broker, pub/sub | IoT, real-time, streaming | delivery guarantees, ordering, eventual consistency |
| Big data | split huge datasets, parallel local processing | batch plus stream analytics, ML | pipeline complexity (managed services help) |
| Big compute | allocate data to hundreds or thousands of cores | simulation, risk modeling, rendering | tightly coupled tasks need fast interconnect |

## Selection process

1. Identify the nature of the problem and the domain.
2. Name the business drivers, translate to prioritized architecture characteristics (nonfunctional requirements). Example from the source: time to market favors maintainability, testability, reliability; a tight budget favors feasibility and simplicity.
3. Involve informed stakeholders; weigh benefits against challenges for this subdomain and bounded context, not globally.
4. Treat the choice as ongoing: measure, validate, refine. Changing direction late is costly, so spend effort early.
5. Be practical: relaxing a constraint is sometimes better than chasing purity. Focus on why a style, not just how.

## Cross-cutting challenges to check

- **Complexity match**: too simple a structure becomes a big ball of mud; too heavy a style for the domain wastes effort.
- **Async messaging**: gains decoupling, retry and scale, costs eventual consistency and duplicate messages.
- **Interservice communication**: more latency and congestion after decomposition.
- **Manageability**: monitoring, deployment, operational health.

## Anti-patterns

- Picking microservices for a simple domain because of fashion.
- Adopting the label without the constraint (shared data, synchronous chains).
- Making the decision once and never re-measuring.

## How an agent should apply this

- Start from ranked characteristics, then map to the style table; never from a favorite style.
- When recommending a style, list the constraints it imposes and ask whether the team will actually uphold each.
- State the domain type next to the style (simple vs complicated, update frequency).
- Name at least two rejected styles and the challenge that ruled each out.
- Flag designs that violate their own style's constraints as the highest-risk finding.
