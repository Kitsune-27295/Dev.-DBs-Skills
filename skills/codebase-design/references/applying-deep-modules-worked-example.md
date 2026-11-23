# Applying Deep Modules: Worked Example and Review Checklist

Sources: https://github.com/mattpocock/skills/tree/main/skills/engineering/codebase-design (listing read: SKILL.md, DEEPENING.md, DESIGN-IT-TWICE.md and an `agents/` folder whose contents were not visible) · local skill files · Ousterhout and Feathers are cited by the upstream skill (their books were not read here; no claims below come from them beyond what the skill states) · Last verified 2026-11-23

This file adds a worked application of vocabulary already defined in `SKILL.md`, `DEEPENING.md` and `DESIGN-IT-TWICE.md`; it does not restate them.

## Example: three shallow modules become one deep one

Before: `parseCoupon`, `validateCoupon`, `applyCoupon`, each exported, callers must call them in order, and every checkout caller repeats the sequence.

```ts
// before: callers must know ordering (interface is wide)
const c = parseCoupon(raw); if (!validateCoupon(c, cart)) return; applyCoupon(c, cart);

// after: one deep entry point; parse/validate/apply become internal
export function priceWithCoupon(cart: Cart, raw: string, clock: Clock): PricedCart | CouponError
```

Deletion test on the old trio: removing `validateCoupon` makes complexity reappear at each caller, so the logic earned its keep, but the split interface did not; merging yields locality (one fix site) and leverage (callers learn one function).

## Classifying dependencies for the merge

| Dependency | Category (DEEPENING) | Test approach |
|---|---|---|
| Pure rules, `Clock` value | In-process | Test directly through `priceWithCoupon` |
| Coupon table in Postgres | Local-substitutable | Real test DB or in-memory stand-in; no external port |
| Loyalty service owned by team | Remote but owned | Port plus HTTP and in-memory adapters (two adapters, so the seam is real) |
| Stripe | True external | Injected port with mock adapter |

## Test migration

1. Write behaviour tests at `priceWithCoupon`.
2. Delete the old per-function tests once covered.
3. Run a refactor of internals; tests must stay green unchanged. If one breaks, it tests past the interface.

## Review checklist

- Can the interface be described in one sentence including invariants and error modes?
- Does a caller need to know call order? If yes, interface leaks.
- Is each port backed by at least two adapters?
- Are internal seams private to the module's own tests?
- Is "boundary" used instead of seam/interface? Rename.

## When Design It Twice earns its cost

Use it when the interface will have many callers or crosses an ownership line; skip for private helpers. Brief each fresh-context sub-agent with separate constraints (minimal, flexible, common-case, ports) as DESIGN-IT-TWICE.md prescribes, then choose or hybridize with an explicit recommendation.

## How an agent should apply this

- Before splitting code into more modules, apply the deletion test to existing ones.
- Pick the dependency category first; it dictates the test seam.
- Replace shallow-module tests with interface tests; never keep both.
- Refuse single-adapter ports; offer a direct dependency instead.
- Use the glossary words exactly in summaries and PR descriptions.
