# Bounded Context: Where DRY and SSOT Stop

Sources: https://martinfowler.com/bliki/BoundedContext.html · Last verified 2026-11-23

## What the source says

Fowler (15 Jan 2014) presents Bounded Context as a central strategic pattern of Domain-Driven Design. A model is only effective when internally consistent ("unified"), but a large domain makes one unified model hard because different groups use subtly different vocabularies. His example: at an electricity utility, "meter" meant a grid-location connection, a grid-customer connection, or the physical device depending on department. "Customer" and "Product" are the same kind of **polyseme** (a word with several related meanings), easily smoothed over in conversation but not in code. Evans's DDD position: total unification of a large model is often not feasible or cost-effective, so divide into Bounded Contexts, each internally unified, and make relationships explicit via a **context map**.

Contexts can hold unrelated concepts (support tickets exist only in support) and shared concepts (products, customers) modeled differently, with mappings between them. Boundaries are usually drawn by **human culture** (the model carries its users' language) and sometimes by **technical representation** (in-memory vs. relational model in one app). Fowler cites related reading: Verraes and Wirfs-Brock on subtle boundaries, Evans's "bubble context" for adding features to legacy systems through explicit mapping.

## Consequences for SSOT (inference from the source)

SSOT answers "where is the single home of this fact?" Bounded Context answers "within what scope is a term's meaning single?". Therefore:

| Situation | Decision |
|---|---|
| Same fact, same context, two copies | True DRY violation; consolidate. |
| Same *word*, two contexts | Two facts that share a name. Keep two models. |
| Same fact genuinely owned by one context but needed by another | The owner publishes it (API, event, contract); consumers hold a **translated read model**, not the owner's class. |
| Two contexts truly co-own a small stable concept | Explicit shared kernel with joint ownership and change protocol; keep it tiny. |
| Two modules in one deployable, owned by groups with different vocabulary | Probably two contexts; treat the module boundary like a context boundary. |

The source page does not discuss team topology; reading boundaries off team ownership is an application of the idea, not a claim of the article.

## Worked example

Sales has `Customer{id, creditLimit, discountTier}`; Support has `Customer{id, contactChannel, tickets[]}`. A shared `Customer` with all fields forces Support to import credit logic and Sales to know tickets. Instead:

```
# Support context
class SupportContact: id, channel, open_tickets
def to_support_contact(sales_customer_dto) -> SupportContact   # translation at the edge
```

The `id` is the only shared knowledge; it is carried as a reference, not as a class.

## Boundary signals (use when deciding whether to share code)

- The same term gets different validation or lifecycle rules per team.
- Teams use different words for the same thing (a sign of separate languages).
- A change request from one stakeholder repeatedly forces edits to another team's code.
- The shared type accumulates optional fields, flags or per-caller `if` branches.

## Failure modes

- **God model:** one `Customer`/`User` whose invariants conflict; every change risks unrelated teams.
- **Shared database tables as shared model:** couples contexts through schema; prefer owned data plus published contracts (`modular-monolith-architecture`, `microservices-architecture`).
- **Premature microservice split** to "enforce" contexts when module boundaries would do.

## Use when / avoid when

Use separate models when language and invariants differ. Share code only for context-neutral mechanisms (money formatting, ID generation) that carry no business policy.

## How an agent should apply this

- Before extracting a cross-module helper, list how each module defines the entities it touches; if definitions differ, do not share the entity type.
- Put translation (mapper/ACL/DTO) at the boundary and test it.
- Share identifiers and contracts, not domain classes, across contexts.
- Record the context owner of each fact; the owner is its SSOT.
- If a "shared" type grows flags, split it per context and delete the flags.
- Link to `ddd-domain-heuristics-debiasing` for deciding context candidates; do not redraw boundaries here.
