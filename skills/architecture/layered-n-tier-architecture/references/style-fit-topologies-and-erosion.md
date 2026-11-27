# Choosing a Style, Deployment Topologies, and Architecture Erosion

Sources: https://learn.microsoft.com/en-us/azure/architecture/guide/architecture-styles/ · https://engsoftmoderna.info/cap7.html · Last verified 2026-11-27 (Azure styles page dated 2025-09-25; chapter read 2026-11-27)

## Styles are constraints and how N-tier compares
Styles as constraints, the selection process and the style comparison table are owned by `architecture-decision-trees-tradeoffs` (`architecture-styles-as-constraints.md`). N-tier fits a traditional business domain with low update frequency. Horizontal layering makes it hard to change one feature without touching several layers, which limits agility for frequent updates. Complexity must match the domain: too simplistic leads to a big ball of mud.

## Valente's treatment (Engenharia de Software Moderna, ch. 7)
- Layered architecture: a layer uses only the layer directly below. Benefits: partitions complexity, constrains dependencies, layers can be swapped, one layer reused by several above. Classic examples: protocol stacks (HTTP over TCP over IP over Ethernet) and Dijkstra's 1968 THE operating system.
- Three layers: UI (client), business logic (application server; example rules: a grade must lie between zero and the assessment's maximum; students are notified by e-mail), database. A two-tier variant merges UI and logic in the client, which then needs more client power.
- MVC vs three-tier: MVC dates from the late 1970s; three-tier became feasible with 1990s distributed applications; web MVC frameworks resemble three-tier, which causes the confusion. MVC lineage is owned by `mvc-architecture`; monolith vs microservices trade-offs by `monolithic-architecture` and `microservices-architecture`.
- Anti-pattern Big Ball of Mud: any module may call almost any other, dependencies explode. Cited case: a bank system grew from about 2.5M to over 25M lines, onboarding time rose from 3 to 7 months, fixes introduced new bugs. The chapter also says documentation, reviews and pair programming did not cure the mess. (The chapter does not use the term "architecture erosion"; that wording is this repo's, not Valente's.)

## Failure modes
- Layering by folder name only, with no enforced import rule, drifts toward mud (inference from the above).
- Splitting into microservices to fix poor layering moves the mess onto the network (inference).

## How an agent should apply this
- Justify N-tier with the guide's fit: evolving requirements, lift-and-shift, hybrid, low change frequency.
- If the domain is complex with frequent change, say layering alone will hurt agility and point to `hexagonal-architecture`, `clean-architecture`, or services.
- Enforce import direction in CI; unenforced layers are documentation, not architecture.
- Treat async messaging as a trade: decoupling and retries versus eventual consistency and duplicates.
- Do not equate three-tier deployment with MVC; state which one a design uses.
