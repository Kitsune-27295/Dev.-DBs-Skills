# Microservice Premium, Monolith First and Adoption Readiness

Sources: https://martinfowler.com/microservices/ · https://microservices.io/patterns/microservices.html · Last verified 2026-11-23

## Fowler's stance
Every style has trade-offs and most situations are better served by a monolith. Benefits: strong module boundaries (help larger teams), independent deployment, technology diversity. Costs: distribution (remote calls are slow and fail), eventual consistency, operational complexity needing a mature ops team. Teams adopt too eagerly and underestimate the "Microservice Premium", a tax on cost and risk.

## Monolith First vs the counterpoint
- Fowler's colleagues observed that successful microservice systems mostly began as a monolith that grew too large and was split; systems built as microservices from scratch mostly ran into serious trouble.
- Counterpoint (Stefan Tilkov, 2015): starting monolithic is usually wrong, since a team unable to build a well-structured monolith is unlikely to build well-structured services.
- The resolution for an agent (inference): start with a modular monolith with enforced boundaries, and extract when a force below justifies it.

## Richardson's forces
- Dark energy (favour splitting): simpler components, team autonomy, fast pipelines, multiple stacks, segregating by scalability, availability or security needs.
- Dark matter (favour fewer boundaries): simple and efficient interactions, ACID over BASE, minimal runtime coupling (availability), minimal design-time coupling (lockstep changes).
- Assemblage is his process for grouping subdomains by weighing these forces. Context: DORA metrics and Team Topologies (small cross-functional teams owning subdomains).
- Drawbacks: hard-to-troubleshoot distributed operations, eventual consistency, runtime coupling reducing availability, design-time coupling forcing lockstep releases.

## Distributed operations catalogue
Saga (commands as local transactions), command-side replica, API composition (queries as local queries joined in memory), CQRS (separate query models). Asynchronous variants generally need the Transactional Outbox. Richardson's wider pattern language also lists decomposition (by business capability or subdomain, self-contained service), Strangler Application and anti-corruption layer for migration, API gateway and backend-for-front-end, service discovery, circuit breaker, consumer-driven contract tests and service component tests, and observability (log aggregation, metrics, distributed tracing, health check API).

## Prerequisites (Fowler's list)
Rapid provisioning, basic monitoring, rapid application deployment; operations carries the biggest burden. Teams without these should not adopt the style.

## Migration guidance Fowler links
Start with a simple service, then extract vertical business-relevant capabilities; each step an atomic improvement. For a data-rich service separate behaviour first, then data, keeping one write copy at all times. Rethink tests because of network partitions.

## Decision table
| Situation | Recommendation |
|---|---|
| One team, new product, unclear domain | Modular monolith |
| Many teams blocked by shared deploys, clear subdomains, automation in place | Extract services along business capabilities |
| Needs ACID across the candidate boundary | Keep together (dark matter) |
| No CI/CD, monitoring or on-call ownership | Do not adopt yet |
| One subsystem needs very different scaling or security | Extract only that one |

## How an agent should apply this
- Ask for the forcing function (team autonomy, scaling, security isolation) before recommending services.
- Verify the three prerequisites exist; if not, recommend a modular monolith.
- Draw boundaries on business capabilities and keep ACID-coupled data together.
- For migration, extract one vertical slice at a time, behaviour before data, with a single writer.
- Document the premium you accept: consistency model, new failure modes, ops load.
