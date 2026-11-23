# Toggle Point Implementation Patterns

Sources: https://martinfowler.com/articles/feature-toggles.html · https://openfeature.dev/docs/reference/intro/ · Last verified 2026-11-23

Source claims are from the Fowler article; code and sizing advice are our illustrations.

## Pattern 1: decouple decision point from decision logic

Raw checks with magic keys spread through code mean every change of scope or reason touches every call site. Put each decision behind a named method in one module (`features.useNewPricing(ctx)`); callers know the question, not the flag key. Changing from release flag to permission rule then edits one place.

## Pattern 2: inversion of decision

Instead of the component asking the flag system, inject the chosen behavior through its constructor or config; a factory (or DI container) wires it at composition time. The component is unaware of flagging and tests need no flag infrastructure.

```ts
interface PriceCalculator { total(cart: Cart): Money }
const calc: PriceCalculator = features.useNewPricing(ctx) ? new TieredPricing() : new LegacyPricing();
const checkout = new Checkout(calc);        // Checkout never sees a flag
```

## Pattern 3: avoid conditionals (Strategy)

When a feature spans several toggle points or lives long, pass alternative behavior (a function) and use a **no-op** for "off". Keeps the number of branching sites at one, the wiring.

## Pattern 4: edge vs core placement

Per-request decisions (show/hide UI element) belong at the edge, keeping conditionals out of the core. Technical toggles (which cache layer) are local to the service they affect.

## Pattern 5: cohort assignment (experiment, canary)

Assignment must be **consistent per user**: derive from a stable ID, e.g. `hash(userId + flagKey) % 100 < percent`. Salting with the flag key avoids the same users always landing in every canary (our inference). In OpenFeature, supply the stable `targetingKey` and let the provider do deterministic bucketing. Do not change percentages of an experiment mid-run.

## Pattern 6: kill switch (ops)

Long-lived ops toggle behaving like a manual circuit breaker: reads from a runtime store, default = feature on (or safe degraded mode, decided per feature), flipped without deploy. Automatic tripping belongs to `circuit-breaker-retry-telemetry`.

## Pattern 7: removal-friendly structure

Keep both paths behind the same interface so deleting the flag means deleting one implementation and the wiring line. Avoid sharing mutable state between the old and new paths.

```ts
// at removal: delete LegacyPricing + the ternary, keep TieredPricing
```

## Trade-offs

| Choice | Benefit | Cost |
|---|---|---|
| Strategy via DI | Testable, one branch | More types for short-lived flags (overkill for a 2-week release toggle: a plain `if` is fine) |
| Central decision module | Single change point | Another module to keep tidy; becomes a God file without ownership per feature |
| Dynamic runtime store | Instant control | Operational dependency; stale-cache and propagation questions |

Use plain `if/else` for short-lived toggles; adopt Strategy/inversion for long-lived or multi-point ones (Fowler's guidance by category).

## Failure modes

Flag evaluated in many places with inconsistent context (user sees new UI but old API); flag checked deep in a loop (performance, hidden coupling); evaluating once per request but caching globally (cohort leakage); both paths writing to the same data with different formats (use `parallel-change-expand-contract`).

## How an agent should apply this

- Evaluate the flag once per request/unit of work, at the wiring point, and pass the result or behavior down.
- Use a named decision function; reject raw flag-key strings in business code.
- Short-lived release flag: plain `if`; long-lived or multi-point: strategy with no-op.
- Make both paths implement one interface so removal is deletion.
- For cohorts, require a stable targeting key and do not edit running experiments.
