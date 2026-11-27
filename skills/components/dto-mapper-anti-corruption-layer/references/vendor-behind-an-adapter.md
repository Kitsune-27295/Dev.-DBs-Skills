# Vendor Behind an Adapter: Ports and Partial Failure

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer · https://alistair.cockburn.us/hexagonal-architecture/ · Last verified 2026-11-27

Abstracted from an internal integration procedure for an external data source; no vendor or product names are reused. The Azure ACL page (re-read 2026-11-27) supports the translation, ownership and monitoring points; the partial-failure rules are the author's method, not a cited standard.

## The rule
A vendor lives behind an adapter at the edge; the domain knows ports. A port is an interface in the domain's own words, defined before any client code. If a port mentions the vendor's identifiers, enum integers or field names, the design has already leaked.

```text
adapters/<vendor>/   client (transport) · adapter (meaning) · mapping (vendor vocabulary)
domain/ports         SourcePort, Severity enum        <- no vendor term anywhere here
```

- **Client** does transport only: endpoint, auth, an explicit timeout (never "none"), bounded retries with backoff and jitter. It raises typed errors: one for "the vendor answered with an error", one for "no answer".
- **Adapter** translates vendor payload to domain types: unit conversions, enum mappings, renamed fields.
- **Mapping** holds the vendor vocabulary (identity tags, item keys, priorities). An item that matches nothing is reported, not dropped; silently dropping is how an entity vanishes from a screen.
- Acceptance check: no vendor field, code or identifier outside the adapter folder.

## Partial failure is normal
With several sources, one will be down. State what happened to each.
1. **A failed read raises.** No port method returns an empty list to mean "I do not know".
2. **Carry a per-source outcome** (not ready, error type, empty, ok) so the caller can tell the cases apart.
3. **Distinguish "no signal" from "zero".** A dead source that yields an empty result renders as "everything is healthy", which is silent and the worst failure mode here.
4. **Return an explicit unavailable state** with a stable reason key when a block cannot be read, instead of an empty value.
5. **Freshness travels with the sample.** Each reading carries its own timestamp so a stale cache is not shown as live.
6. **Do not make it worse.** Retry with a budget and jitter; add a circuit breaker when polling on a schedule (`circuit-breaker-retry-telemetry`).

```python
class SourcePort(Protocol):
    def collect(self, entity: str) -> list[Reading]: ...   # raises SourceUnavailable; never []-as-unknown

results = {s.name: attempt(s, entity) for s in sources}    # {"a": Ok(...), "b": Failed("timeout")}
return Report(readings=merge_ok(results), unavailable=[n for n, r in results.items() if r.failed])
```

## Testing
Use canned payloads through a mock transport, never a live vendor: cover the empty response, a malformed field, an unmapped entity and a timeout. A test that needs the vendor up will be skipped. Pin read-only behavior of the client if the contract is read-only.

## Retiring the layer
Record whether the adapter is permanent (a third party you cannot change) or transitional (a legacy migration). If the multi-source design later shrinks, keep the port rules: they outlive any one adapter.

## How an agent should apply this
- Define the port in domain terms first; refuse a port whose names come from a vendor.
- Put translation only in the adapter; business scoring stays in the domain services.
- Make every failure path explicit: raise, per-source outcome, unavailable state; reject empty-list-as-unknown.
- Test with canned payloads covering empty, malformed, unmapped and timeout cases.
