# Bounded Context: Why Shared Models Stop at the Boundary

Sources: https://martinfowler.com/bliki/BoundedContext.html · Last verified 2026-11-23

Fowler's short bliki entry (published 2014) is the basis for the SKILL.md rule "DRY applies inside a context, not across".

## What the article establishes

- Bounded Context is a core pattern of DDD's strategic design: large models are split into contexts, and the relationships between contexts are made explicit.
- A model doubles as the ubiquitous language between developers and domain experts, so it must be internally consistent (unified) to be useful.
- In a large organization one unified model stops being feasible or cost-effective. Fowler cites Evans: total unification of a big domain model is not achievable. The alternative is several canonical models, each unified inside its own context.
- Example used: an electricity utility where "meter" means the grid-to-location connection, the grid-to-customer connection, or the replaceable physical device, depending on the group. People smooth this over in conversation; software cannot. The same problem recurs with "Customer" and "Product".
- Some concepts exist in one context only (a support ticket in customer support); some appear in several with different models, so mapping mechanisms are needed for integration. The article recommends depicting the relationships in a **context map**.
- Boundaries are usually driven by human culture, because language implies model. They can also be technical (in-memory model versus relational model inside one app). Verraes and Wirfs-Brock, cited by Fowler, note that history and human relationships can drive a split as much as domain concepts.

## Consequences for code sharing

| Situation | Reading | Action |
|---|---|---|
| Same word, same meaning, same invariants, same team | One context | DRY applies; share one model |
| Same word, different attributes or rules (Customer in billing vs support) | Polyseme across contexts | Keep two local models; translate at the edge |
| New feature "just needs the Customer class from the other service" | Boundary crossing | Define a small published contract or DTO and map into a local type |
| Two modules in one deployable but owned by groups with different vocabulary | Probably two contexts | Treat the module boundary like a context boundary |

Note: the page itself does not discuss team topology or give a sales-vs-support Customer example; those are applications of the idea, not claims from the article. The relationship patterns (shared kernel, anti-corruption layer and so on) are named in DDD literature but not explained on this page.

## Failure modes

- An enterprise-wide `Customer` entity with optional fields for every department: each team's change can break another's invariants.
- Sharing a library of "common domain objects" across services, which turns every schema change into a coordinated release.
- Mapping nothing: leaking one context's persistence model into another's API.

## How an agent should apply this

- Before proposing a shared domain type across packages/services, ask whether both sides use the same words with the same invariants; if not, propose two types plus a mapper.
- When reviewing a "common" or "shared" module, list which contexts import it and what each means by the term.
- Put translation code (mapper, anti-corruption layer, DTO) at the boundary and test it there.
- Allow genuine sharing only for stable, context-neutral values (IDs, money, timestamps) and say so explicitly.
- If the boundary is unclear, record it as an open question instead of unifying by default.
