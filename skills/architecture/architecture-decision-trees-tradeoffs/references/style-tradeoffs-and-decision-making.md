# Style-by-Style Trade-offs, Style Selection, ADRs and Risk Storming

Sources: https://github.com/pkardas/notes/blob/master/books/fundamentals-of-architecture.md (study notes, Chapters 10-20) · Last verified 2026-11-27

Secondary source: the notes contain no rating tables and omit trade-offs for pipeline and microkernel. Where the notes are silent, this file says so. Re-check on 2026-11-27 confirmed the sinkhole, 4-12 service-based services, mediator versus broker, SOA verdict, ADR sections, wiki advice, "synchronous by default" and risk storming; other table cells come from the earlier read.

## Style catalog

| Style | Shape | Trade-offs stated in the notes |
|---|---|---|
| Layered | presentation, business, persistence, database; technically partitioned; closed or open layers | simple, cheap, familiar, good start when final style unknown; poor DDD fit; beware the **sinkhole** (pass-through layers) |
| Pipeline | filters (producer, transformer, tester, consumer) joined by pipes; ETL | not discussed |
| Microkernel | minimal core plus independent plug-ins and a registry; Eclipse, Jenkins, browsers | not discussed; fits per-client customization; one quantum |
| Service-based | UI plus 4-12 coarse domain services, usually one shared DB | pragmatic, cheaper than microservices/EDA, natural DDD fit, better ACID, good modularity; shared schema changes are costly |
| Event-driven | mediator or broker topology | see below |
| Space-based | processing units with in-memory data grids, data pumps to the DB | extreme scalability/elasticity for spiky load; data collisions when replicated caches are updated in two instances (detail on the style: `actor-model-space-based-architecture`) |
| Orchestration-driven SOA | enterprise services plus central orchestrator | judged largely a failure: reuse produced coupling and coordinated deployments |
| Microservices | one bounded context per service, each self-contained | scalable, elastic, evolvable; network performance cost; heavy cross-service transactions signal wrong granularity; sagas are complex |

### Event-driven topologies

| | Mediator | Broker |
|---|---|---|
| Control | central workflow and error handling | none, chained events |
| Message type | commands | events |
| Strength | workflow control, error handling | high decoupling, responsiveness |
| Weakness | lower scalability, less decoupled | hard error handling, cannot restart transactions |


## Choosing a style (Chapter 18 synthesis)

Understand the domain, structurally relevant characteristics, data architecture (with DBAs), organizational cost and plans, and process, team and operations. Settle three questions in order: monolith vs distributed, where the data lives, sync vs async. Default: synchronous unless asynchronous is needed (a practitioner heuristic, not a law). Check whether the domain's shape matches the topology.

## Decision process and anti-patterns

- **Covering your assets**: deferring decisions out of fear. **Groundhog Day**: re-debating because no rationale was recorded. **Email-driven architecture**: decisions lost or unknown to implementers.
- Architecturally significant decisions affect structure, nonfunctional characteristics, dependencies, interfaces or construction techniques.

### ADR sections (as in the notes)

Title (numbered), Status (proposed, accepted, suspended/superseded), Context, Decision (emphasize why), Consequences (check benefits outweigh costs), optional Compliance and Notes. The notes recommend a wiki over Git for storage (opinion; a repo-local ADR works too, see `adr-architecture`).

```
ADR-007 Status: accepted
Context: 3 teams, shared checkout DB, deploy collisions weekly
Decision: service-based split into 5 domain services, keep one DB
Consequences: + simpler than microservices, - schema changes need DB team
Compliance: fitness test blocks cross-service table access
```

## Risk analysis

Risk storming is a collaborative exercise that examines one risk dimension at a time in three activities: identification, consensus, mitigation. The risk-matrix scoring details were not re-read.

## How an agent should apply this

- Offer 2-3 candidate styles with the stated trade-off, never a single winner.
- Resolve monolith/distributed, data ownership and sync/async explicitly and in that order.
- Write an ADR with context, decision, consequences and a compliance check for every significant choice.
- Run a lightweight risk-storming pass on the winner and attach mitigations.
- Warn when a choice resembles SOA-style heavy reuse via a central orchestrator.
