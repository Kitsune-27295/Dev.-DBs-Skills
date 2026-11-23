# Choosing a Style, Deployment Topologies, and Architecture Erosion

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/ · https://engsoftmoderna.info/cap7.html · Last verified 2026-11-23

## Styles are constraints
The Azure guide defines an architecture style as a family of architectures sharing characteristics; it constrains the allowed elements and relationships, and desirable properties emerge only if you respect the constraints. Its warning: adopting a style superficially, without its constraints, yields none of the benefits; but sometimes it is better to relax a constraint than chase purity. Choose with stakeholders, starting from the problem and prioritised nonfunctional requirements (time to market favours maintainability/testability; a tight budget favours simplicity). Changing direction later is costly, so invest upfront and keep measuring.

## How N-tier compares (guide's table, paraphrased)
| Style | Dependency management | Best-fit domain |
|---|---|---|
| N-tier | horizontal tiers divided by subnet | traditional business domain, low update frequency |
| Web-Queue-Worker | front end and worker decoupled by async messaging | simple domain with some heavy tasks |
| Microservices | vertical functional services calling via APIs | complicated domain, frequent updates |
| Event-driven | producers/consumers, independent view per subsystem | IoT, real-time |

The guide notes horizontal layering makes it hard to change one feature without touching several layers, which limits agility for frequent updates. Complexity must match the domain: too simplistic leads to a big ball of mud.

## Valente's treatment (Engenharia de Software Moderna, ch. 7)
- Layered architecture: a layer uses only the layer directly below. Benefits: partitions complexity, constrains dependencies, layers can be swapped, one layer reused by several above. Classic examples: protocol stacks (HTTP over TCP over IP over Ethernet), Dijkstra's THE system.
- Three layers: UI (client), business logic (application server; example rules: grade within 0..max, notify students on posting), database. A two-tier variant merges UI and logic in the client, which then needs more client power.
- MVC vs three-tier: MVC dates from 1970s GUIs (Model has no dependency on View/Controller); three-tier from 1990s distributed systems, often with MVC inside the UI tier; web MVC frameworks later look much like three-tier.
- Monolith: modules developed separately but one process and address space; scale by replicating the whole system. Microservices: separate processes, no shared memory, scale only the bottleneck service, each owns its data.
- Anti-pattern Big Ball of Mud: any module may call almost any other, dependencies explode. Cited case: a bank system grew from about 2.5M to over 25M lines, onboarding time rose from 3 to 7 months, fixes introduced new bugs. The chapter notes architecture decisions can take years to show harm. (It does not use the term "architecture erosion"; that wording is this repo's, not Valente's.)

## Failure modes
- Layering by folder name only, with no enforced import rule, drifts toward mud (inference from the above).
- Splitting into microservices to fix poor layering moves the mess onto the network (inference).

## How an agent should apply this
- Justify N-tier with the guide's fit: evolving requirements, lift-and-shift, hybrid, low change frequency.
- If the domain is complex with frequent change, say layering alone will hurt agility and point to `hexagonal-architecture`, `clean-architecture`, or services.
- Enforce import direction in CI; unenforced layers are documentation, not architecture.
- Treat async messaging as a trade: decoupling and retries versus eventual consistency and duplicates.
- Do not equate three-tier deployment with MVC; state which one a design uses.
