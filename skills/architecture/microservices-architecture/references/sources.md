# Sources — Microservices Architecture

Every URL below was fetched and read during the 2026-11-27 rebuild (WebFetch).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Lewis and Fowler, "Microservices", https://martinfowler.com/articles/microservices.html | 200, read 2026-11-27 (dated 2014-03-25) | Nine characteristics, ESB footnote, one-synchronous-call rule of The Guardian, Simian Army, two-pizza size sidebar, SOA sidebar, Tolerant Reader, merge co-changing services, closing caution |
| Fowler, "Microservices Resource Guide", https://martinfowler.com/microservices/ | 200, read 2026-11-27 | Microservice premium, link to Monolith First, behavior-then-data migration with one write copy. It does not list the three prerequisites (the earlier draft credited it wrongly) |
| Fowler, "Microservice Prerequisites", https://martinfowler.com/bliki/MicroservicePrerequisites.html | 200, read 2026-11-27 (dated 2014-08-28) | Rapid provisioning, basic monitoring, rapid application deployment |
| Richardson, "Pattern: Microservice Architecture", https://microservices.io/patterns/microservices.html | 200, read 2026-11-27 | Dark energy and dark matter forces, Assemblage, DORA, Team Topologies, drawbacks, distributed operations |
| Richardson, pattern language index, https://microservices.io/patterns/ | 200, read 2026-11-27 | Pattern categories and names |

## Reading limits

Only page text returned by the fetch tool was read. The Richardson page words CQRS like API composition, which looks like a copy error on the site, so CQRS is not defined from it. No scripts or data files exist in this skill. Tool summaries, not raw pages, were inspected.

## Claims not adopted as fact

- Distributed tracing and log aggregation as prerequisites: Richardson lists them as observability patterns, not Fowler as prerequisites; kept as labeled agent inference.
- Default of a modular monolith: Fowler's Monolith First view is owned by `monolithic-architecture`; the default here is agent inference.
- Vendor or author claims of speed or cost gains are not adopted.
