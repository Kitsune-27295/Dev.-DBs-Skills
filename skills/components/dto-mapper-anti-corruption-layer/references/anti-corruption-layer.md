# Anti-Corruption Layer (ACL)

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer · Last verified 2026-11-27

## Definition
Microsoft's Azure Architecture Center (page dated 2026-05-28, re-read 2026-11-27) describes the ACL as a facade or adapter layer between subsystems that do not share the same semantics. It translates requests from one subsystem to the other so outside dependencies do not limit the application's design. Eric Evans first described it in *Domain-Driven Design*. The trigger: legacy or third-party systems with convoluted schemas, obsolete APIs or different protocols force a new system to adopt those semantics and "corrupt" a clean design.

## Mechanics
- Subsystem A always talks to the ACL in A's own model; the ACL talks to B in B's model; it holds all translation logic. Neither side learns the other's internals.
- Deployable as a component inside the app or as an independent service.
- Can be synchronous (facade/adapter) or asynchronous (Service Bus, Event Grid, Event Hubs) to decouple A from B's throughput limits.
- Azure example: API Management for external exposure and protocol concerns, Azure Functions for domain mapping (REST DTO to domain model to legacy DTO), Azure Monitor/Application Insights for tracing translation success and latency.

## Components inside an ACL (general structure, my inference)
1. **Facade**: a narrow interface in the local language (a port) that the domain uses.
2. **Adapter**: speaks the foreign protocol.
3. **Translator/mapper**: converts foreign model to local model and back (see `mapper-pattern.md`).
4. Optional anti-corruption extras: caching, retries/circuit breaking (`circuit-breaker-retry-telemetry`), idempotency.

```
class LegacyBillingGateway(BillingPort):     # local port, domain vocabulary
    def invoice_for(self, order: Order) -> Invoice:
        raw = self.client.call("CRT_INV", to_legacy(order))   # foreign protocol
        return from_legacy(raw)                               # translation
```

## Considerations (from the page)
The operative list (latency, extra component, scope, lifetime, consistency, validation, observability) is rule set 5 in `SKILL.md`. Two page points not repeated there: decide whether one ACL or several are needed when the target spans technologies or languages, and the pattern also applies to legacy code inside a monolith, not only between services.

## When to use / avoid
Use for multi-stage migrations needing integration with legacy, or when subsystems have different semantics but must communicate (strangler-style migration; see `parallel-change-expand-contract`). The page says it may not suit cases with no significant semantic difference; there, keep the layer to pure translation and never place business rules or orchestration in it. Between contexts you own and that agree on a model, a plain shared contract or published language is cheaper (my inference; see `ddd-domain-heuristics-debiasing`).

## Failure modes
Business rules hiding inside the ACL; ACL that leaks foreign types into the domain; no tests with real legacy samples; leaving a "temporary" ACL undocumented and unowned; translating everything instead of the subset the domain needs; inconsistent state across a two-system write.

## How an agent should apply this
- Draw the boundary: what foreign model, what local model, who owns the ACL.
- Define the local port first in domain vocabulary, then adapt the foreign system to it.
- Keep the ACL translation-only; relocate any rule into the domain.
- Add contract tests with recorded foreign payloads, plus correlation IDs and metrics.
- State lifetime and owner (transitional vs permanent) in the ADR (`adr-architecture`).
