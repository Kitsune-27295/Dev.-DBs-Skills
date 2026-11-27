# Decoupled DDD: Subdomain Roles and Implementation Patterns

Sources: https://vladikk.com/2016/04/05/tackling-complexity-ddd/ · https://github.com/ddd-crew/core-domain-charts · Last verified 2026-11-27

## Khononov's reframing: apply DDD to DDD

Khononov classifies DDD's own concepts the way DDD classifies a business: some are core, some supporting, some generic.

| Role | DDD element | Why |
|---|---|---|
| Core | Ubiquitous Language | The part that lowers project risk: one shared business vocabulary in talk, docs and code, each term with a single meaning |
| Supporting | Bounded Context | Exists to make the language possible: the boundary inside which terms keep one meaning |
| Generic | Implementation patterns | Off-the-shelf: Transaction Script, Active Record, Domain Model (Fowler, PoEAA), Event-Sourced Domain Model |

Consequences the article draws:
- Tactical patterns (aggregates, entities, value objects) are one way to implement logic, not "the" way to do DDD. A project can follow DDD with zero aggregates.
- The pattern choice is not permanent. Each fits a complexity level; upgrade when the domain grows (inference: this implies a trigger such as repeated rule changes or invariant bugs).
- Even simple domains benefit from the Ubiquitous Language because miscommunication creates accidental complexity.
- Bounded Contexts give a business-driven cut for microservices.

Note: the article only names the four implementation patterns; it does not explain them in depth. Details below are standard Fowler-style knowledge (not read from this source).

## Choosing an implementation pattern (agent heuristic, inferred)

| Subdomain complexity / differentiation | Default pattern | Signal to move up |
|---|---|---|
| Generic, simple CRUD | Active Record or Transaction Script | Rules start to interact |
| Supporting, procedural flows | Transaction Script | Same conditionals copied across scripts |
| Core, rich invariants | Domain Model | Audit/temporal questions ("why is it in this state?") |
| Core, audit/time-travel needed | Event-Sourced Domain Model | n/a, most expensive |

Do not buy a Domain Model for a Generic subdomain; buy or reuse a library instead.

## Core Domain Charts: how to place subdomains

Two axes: business differentiation (judged mostly by product/business people) and complexity (judged mostly by engineers). Charts are for discussion, not precise scoring.

Steps:
1. Pick a variant: portfolio (plain placement), context map plus Team Topologies interaction modes, or architecture migration (relabel the y-axis to sequence moves toward a target architecture).
2. List subdomains or bounded contexts; keep the chart focused.
3. Score complexity using clues: essential domain difficulty, accidental technical complexity, operational complexity outside the software, discovery/rule-design difficulty, scale and scarce talent, ramp-up time of a newcomer.
4. Score differentiation: how hard a competitor finds it to match, current vs potential advantage, brand damage from failures, Cynefin domain.
5. Plot relatively and debate across disciplines.

Pitfalls (README pitfalls not re-read in the 2026-11-27 summary; treat as unverified): overloading one chart; treating positions as exact; engineers or business working alone.

```text
high differentiation, high complexity  -> Core: Domain Model / Event Sourcing, best people
high differentiation, low complexity   -> Core-ish: simple, but protect and iterate fast
low differentiation, high complexity   -> Supporting/Generic hard: buy or outsource
low differentiation, low complexity    -> Generic: Active Record / SaaS
```
(The quadrant labels are this skill's inference, not text from the repo.)

## How an agent should apply this

- Classify each subdomain (Core/Supporting/Generic) before proposing aggregates or event sourcing.
- Start from the simplest implementation pattern that fits and name the signal that would trigger an upgrade.
- Insist on a single-meaning Ubiquitous Language per Bounded Context before any code modeling.
- Use the chart as a conversation artifact; ask for product input on differentiation rather than guessing.
- Never claim DDD requires tactical patterns; cite Khononov when pushing back on ceremony.
