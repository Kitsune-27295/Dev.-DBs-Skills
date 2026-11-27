# Sources — SOA vs Microservices Architecture

Every URL below was fetched and read during the 2026-11-27 rebuild (WebFetch).

| Source | Retrieved status | What it contributed |
|---|---|---|
| IBM Think, "SOA vs microservices", https://www.ibm.com/think/topics/soa-vs-microservices | 200, read 2026-11-27 | Scope as the core difference, four SOA service roles, reuse versus duplication, ESB single point of failure, shared data, governance, when to pick each. Does not address SOA deployment |
| AWS, "Difference between SOA and microservices", https://aws.amazon.com/compare/the-difference-between-soa-microservices/ | 200, read 2026-11-27 | Dimension comparison (reuse, communication, protocols, data, granularity, deployment, speed, governance), inventory example, SOA limits. No migration section |
| Lewis and Fowler, "Microservices" SOA sidebar, https://martinfowler.com/articles/microservices.html | 200, read 2026-11-27 | SOA means many things; ESB-centric efforts failed; some see microservices as service orientation done right; smart endpoints over ESB |
| Richardson, pattern language index, https://microservices.io/patterns/ | 200, read 2026-11-27 | Names of Strangler Application and Anti-corruption layer |

## Reading limits

Tool summaries of pages were read, not raw HTML. No scripts or data files exist here. The IBM speed claim is a vendor statement and is not adopted as universal.

## Claims not adopted as fact

- Migration steps (untangle shared database first, ESB orchestration into sagas, big-bang avoidance): agent inference; neither IBM nor AWS describes a migration path.
- Specific enterprise examples (mainframe, SAP, Salesforce): illustrations, not source claims.
- "Entity Services" as an SOA role: not in IBM's list; removed.
