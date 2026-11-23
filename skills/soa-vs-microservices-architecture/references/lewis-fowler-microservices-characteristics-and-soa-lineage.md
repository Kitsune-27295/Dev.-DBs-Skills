# Lewis and Fowler: Microservice Characteristics and the SOA Lineage

Sources: https://martinfowler.com/articles/microservices.html · Last verified 2026-11-23

## Stance

The article (2014) gives no formal definition, only common characteristics: small independently deployable services, each in its own process, lightweight communication (often HTTP resource APIs), organized around business capabilities, possibly different languages and data stores. Its stance on maturity: "cautious optimism"; consequences of architecture decisions may only show years later.

## Characteristics

1. **Componentization via services:** out-of-process, independently replaceable; remote calls cost more, so APIs are coarser; interfaces become explicit.
2. **Organized around business capabilities:** cross-functional teams own UI, storage and integrations (Conway's Law).
3. **Products not projects:** teams own the service through its life ("you build it, you run it").
4. **Smart endpoints, dumb pipes:** logic in services, simple protocols between them.
5. **Decentralized governance:** teams pick tools; prefer shared battle-tested tools over top-down standards.
6. **Decentralized data:** each service owns data; avoid distributed transactions, use eventual consistency and compensation.
7. **Infrastructure automation:** continuous delivery, test and deployment automation.
8. **Design for failure:** circuit breakers, timeouts, bulkheads, real-time monitoring.
9. **Evolutionary design:** draw boundaries so things that change together stay together; services repeatedly changed together may need merging; versioning is a last resort.

## SOA sidebar

"SOA" meant many things; in practice often ESB-heavy integration, centralized governance and costly failed initiatives. Some advocates reject the label; others call microservices "SOA done right." Tolerant Reader emerged from integration work in large organizations.

## Trade-offs and cautions

- Remote communication adds cost; refactoring across service boundaries is harder than within a process.
- Complexity moves from components to the connections between them, where it is less visible.
- Outcomes depend on team skill.
- A common suggestion is monolith-first, but a good in-process interface is not always a good service interface.
- Synchronous call chains multiply downtime; favor async or limit sync hops per request.

## How an agent should apply this

- Use this checklist (characteristics 1-9) as the audit for "is it really microservices?"
- Treat a shared DB or a central rule engine as evidence of SOA-style coupling.
- Recommend a modular monolith when team skill, automation or domain knowledge is thin.
- Count synchronous hops per user request and cap them.
- Review boundaries after a few releases: merge services that always change together.
