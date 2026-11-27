---
name: dto-mapper-anti-corruption-layer
description: "Shape and translate data at boundaries: Data Transfer Objects per use case, explicit Mappers/assemblers, and Anti-Corruption Layers that protect a domain model from legacy or third-party semantics. Covers where mappers live, pure and tested translation, DTO vs entity vs value object, ACL ports/adapters/translators, migration-time ACLs and their lifetime. Use when exposing or consuming APIs/events, integrating a legacy or external system, designing request/response shapes, debugging model leakage, mass assignment, or auto-mapper drift."
---

# DTO, Mapper & Anti-Corruption Layer

One idea: **every boundary gets its own data shape, and one translator owns the conversion, so no model leaks past the adapter that speaks it.** DTOs shape data for the wire, mappers translate, and an Anti-Corruption Layer (ACL) is a mapper-plus-port strategy for protecting your model from a foreign one. Sources and retrieval status: [references/sources.md](references/sources.md).

Boundary: this skill owns boundary data shapes and translation between models and contexts. Persistence abstraction and transactions are `repository-unit-of-work`; input validation and parsing rules are `validator-input-parser`; invariants inside domain types are `value-objects-type-invariants`; error body formats are `error-handling-problem-details`; contract governance is `arc42-api-contracts-architecture`; BFF response shaping is `bff-pattern`.

---

## 1. Three Tools, Three Questions

| Tool | Question it answers | Fowler/Microsoft source |
|---|---|---|
| DTO | What shape crosses this process or trust boundary? | Carries data between processes to reduce calls; serializable; assembler on the server |
| Mapper | Who converts between two independent models so they stay unaware of each other? | Object that sets up communication between two independent objects |
| ACL | How do I stop a foreign system's semantics from corrupting my design? | Facade/adapter layer translating between subsystems with different semantics |

## 2. DTO Rules

1. **One DTO per use case and direction** (request, response, event). Name by use case, not by table.
2. **Never expose domain or ORM entities** across a boundary; schema refactors would become breaking API changes and lazy graphs leak.
3. **Data only**: no behavior and no invariants. Shape checks happen at the edge (`validator-input-parser`); invariants live in the domain.
4. **Whitelist inbound fields** to prevent mass assignment (`never-trust-the-client`).
5. Flat and coarse-grained over the wire; derive or generate from the contract to keep a single source of truth (`pragmatic-solid-and-ssot`).
6. **Do not add DTOs inside one process with no boundary.** Copying an entity into an identical DTO is ceremony. A boundary means HTTP, queue, RPC, or a deliberately hidden inner model.
7. Do not confuse a DTO with a DDD Value Object (Fowler notes the historical naming clash).

## 3. Mapper Rules

- Mapper lives in the **adapter that owns the foreign shape**; the inner model never imports it.
- Boundaries: HTTP edge (DTO <-> command/domain), persistence edge (aggregate <-> record, inside the repository), external edge (foreign <-> local, inside an ACL), event edge (domain event <-> message).
- **Explicit, pure, total** functions: no I/O, no lookups, no business rules; unmappable input yields an explicit error.
- Auto-mappers only for truly 1:1 shapes and always with a test that fails on unmapped fields.
- Test with round-trip and golden fixtures.

```
def to_domain(dto: PlaceOrderDto) -> PlaceOrder:
    return PlaceOrder(CustomerId(dto.customer_id), [Line(Sku(l.sku), Quantity(l.qty)) for l in dto.lines])
```

## 4. When You Need an Anti-Corruption Layer

| Situation | Choose |
|---|---|
| Same bounded context, you own both sides | Plain DTO + mapper, no ACL |
| Legacy system with different vocabulary, migrating in stages | **ACL**, transitional |
| Third-party API you cannot change, semantics differ | **ACL**, permanent |
| Two of your contexts with different meanings of "Customer" | Context map + translation at the boundary (ACL on the downstream side) |
| Semantics essentially identical | No ACL; keep it a thin mapper |

ACL structure: a **port** in your domain vocabulary, an **adapter** speaking the foreign protocol, a **translator** converting models. Retries, circuit breaking and caching sit in the adapter (`circuit-breaker-retry-telemetry`, `caching-strategies`).

```
class LegacyBilling(BillingPort):          # port owned by the domain
    def invoice_for(self, order): return from_legacy(self.client.call("CRT_INV", to_legacy(order)))
```

## 5. ACL Rules (Microsoft guidance)

1. Translation only: **no business rules or orchestration** in the layer.
2. Decide scope (all traffic or a subset), owner and **lifetime** (retire after migration or keep) and record it (`adr-architecture`).
3. Expect added latency and an extra component: plan scaling, monitoring, releases.
4. Validate and sanitize at the boundary; trust levels differ.
5. Correlation IDs and structured logs so translation failures are diagnosable.
6. Keep data consistency across the two systems explicit (events, outbox, idempotency).
7. Asynchronous translation (message broker) when the legacy system cannot meet throughput.
8. For incremental migration, pair with `parallel-change-expand-contract`.

Vendor rule: the vendor lives behind an adapter at the edge and the domain knows ports; handle partial failure explicitly (raise, per-source outcome, unavailable state, never empty-as-unknown). Worked example: [vendor behind an adapter](references/vendor-behind-an-adapter.md).

## 6. Placement

- Hexagonal/clean: ports inside, DTOs and mappers in driving adapters, ACL in driven adapters (`hexagonal-architecture`, `clean-architecture`).
- Strategic placement of contexts and who is upstream/downstream: `ddd-domain-heuristics-debiasing`, `defensive-domain-modeling`.
- Microservices: each service publishes its own contract and consumes others through an ACL rather than sharing a domain library (`microservices-architecture`).

## Reject on Sight

- Entities serialized straight to JSON as the public API.
- One shared `Customer` model across bounded contexts "to avoid mapping".
- Mapper calling repositories or HTTP clients.
- Business rules inside the ACL; foreign types appearing in domain signatures.
- Reflection auto-mapping with silent default/dropped fields.
- A model copy per layer inside a single context with no boundary.

## Quick Decision Checklist

- [ ] Does this data cross a process/trust boundary? If not, skip the DTO.
- [ ] Is there one DTO per use case and direction, with whitelisted inbound fields?
- [ ] Does the mapper live in the adapter owning the foreign shape, and stay pure?
- [ ] Are foreign semantics different enough to justify an ACL, and is its owner and lifetime recorded?
- [ ] Does the domain depend on a port in its own language, not on foreign types?
- [ ] Are there mapping tests (round trip, golden, unmapped-field detection) and ACL contract tests with real payloads?
- [ ] Is the ACL free of business rules?

## Deep references

- [Data Transfer Object and Assembler](references/data-transfer-object-and-assembler.md) — purpose, shape rules, per-use-case DTOs, when not to use.
- [Mapper pattern and translation code](references/mapper-pattern.md) — where mappers live, explicit vs auto-mapping, tests.
- [Anti-Corruption Layer](references/anti-corruption-layer.md) — structure, considerations, lifetime, failure modes.
- [Vendor behind an adapter](references/vendor-behind-an-adapter.md) — port-first design, adapter-only vendor terms and partial-failure handling.