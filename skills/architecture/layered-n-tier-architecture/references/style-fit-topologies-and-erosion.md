# Choosing a Style, Deployment Topologies, and Architecture Erosion

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/ · https://engsoftmoderna.info/cap7.html · Last verified 2026-11-23

## Styles are constraints and how N-tier compares
Styles as constraints, the selection process and the style comparison table are owned by `architecture-decision-trees-tradeoffs` (`architecture-styles-as-constraints.md`). N-tier fits a traditional business domain with low update frequency. Horizontal layering makes it hard to change one feature without touching several layers, which limits agility for frequent updates. Complexity must match the domain: too simplistic leads to a big ball of mud.

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
