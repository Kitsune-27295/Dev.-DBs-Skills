---
name: value-objects-type-invariants
description: "Deep dive on designing Value Objects (equality by value, immutability, side-effect-free operations, aliasing bugs), the Money pattern (currency, minor units, rounding, allocation without losing cents) and modelling states with types so illegal states are unrepresentable (sum types, state-per-type, union instead of optional-field soup). Complements the overview in `defensive-domain-modeling`, which owns Parse-Don't-Validate. Use when replacing primitive obsession, designing Money/Range/Address types, adding equals/hashCode or immutability, splitting a record with flags and optional fields into per-state types, or reviewing business-rule encoding in a type system."
---

# Value Objects & Type-Level Invariants

One idea: put the **rules** of a domain concept into a small immutable type (equal by value, no side effects) and put the **legal combinations** of a concept's states into the shape of its type, so most invariants are enforced by construction and by the compiler instead of by scattered `if` statements. Sources and fetch status: [references/sources.md](references/sources.md).

Boundaries (do not redo here): parsing untrusted input into types (Parse, Don't Validate), Tell-Don't-Ask, CQS and ROP overview live in `defensive-domain-modeling`; database-level constraints in `schema-and-constraints`; error contracts for failed construction in `error-handling-problem-details`; the "make it simple" question in `kiss-yagni-aha`.

---

## 1. Value Object design rules

| Rule | Mechanics | Violation symptom |
|---|---|---|
| **Equality by value** | Two instances with equal properties are equal; implement `equals/hashCode` (or `==`, structural record equality) | `includes`/`Set`/map lookups fail for "same" data; JS reference equality surprises |
| **Immutable** | No setters; operations return a **new** instance; freeze if the team is not disciplined | Aliasing bug: changing a shared date also changes someone else's date |
| **Side-effect-free operations** | Methods compute and return; never mutate arguments, never do I/O | Hidden state, order-dependent tests |
| **Self-validating** | Constructor/factory enforces invariants (range, format, currency present) | Invalid instances flow through the domain |
| **Small and concept-sized** | A phone number, money, quantity, date range, coordinates — not a bag of unrelated fields | "ValueObject" that is a DTO in disguise |
| **No identity** | Never carries a surrogate ID as part of equality | Confusion with entities |

Value vs reference is **contextual**: an address is a value in an invoicing system, an entity in a mapping system with hierarchy. Decide per bounded context. The old J2EE sense of "value object" (a data transfer object) is a different thing; do not conflate.

Details, equality pitfalls per language and Range example: [references/value-object-mechanics.md](references/value-object-mechanics.md).

## 2. Replace primitives (what to wrap, what not to)

Wrap when the primitive (a) has rules (phone, email, IBAN), (b) can be confused with another primitive of the same type (`userId` vs `orderId`), (c) has meaningless operations (adding two IDs), or (d) is repeated with the same validation. Skip for throwaway locals, loop counters and values with no rules anywhere in the codebase (YAGNI: `kiss-yagni-aha`).

## 3. Money

Money is not a built-in type, and floating-point arithmetic on it is wrong. The Money pattern addresses two problems: **currency** (do not add dollars to yen; mixed currencies need an explicit conversion) and **rounding** (amounts round to the smallest currency unit and cents can be lost or created).

Checklist for a Money type:

1. Store an **integer amount in minor units** (or a decimal type) **plus a currency code**; never a bare float.
2. `add`/`subtract` require the **same currency** and fail otherwise (error or type error), never silently coerce.
3. Multiplication by a rate takes an explicit **rounding mode** and rounds once, at a defined point.
4. **Allocation**: splitting an amount into parts must conserve the total (distribute the remainder cents deterministically).
5. Currency decimals differ (JPY 0, EUR 2, KWD 3): derive the scale from the currency.
6. Comparison across currencies is undefined; conversion needs a rate (and date) from outside the type.

Note: the catalogue page itself is a brief overview; the allocation algorithm and minor-unit details in the reference file are marked as background knowledge or own synthesis, not read from that page. See [references/money-allocation-and-rounding.md](references/money-allocation-and-rounding.md).

## 4. Make illegal states unrepresentable

The phrase (attributed in the article to Yaron Minsky) means: shape the types so that a state the business forbids cannot be constructed.

Worked rule from the article: a contact must have an email **or** a postal address (or both). Required-both is too strict; optional-both allows neither. The right model enumerates the legal cases as a union:

```fsharp
type ContactInfo =
  | EmailOnly of EmailContactInfo
  | PostOnly  of PostalContactInfo
  | EmailAndPost of EmailContactInfo * PostalContactInfo
```

TypeScript equivalent:

```ts
type ContactInfo =
  | { kind: "emailOnly"; email: Email }
  | { kind: "postOnly"; post: PostalAddress }
  | { kind: "both"; email: Email; post: PostalAddress };
```

Rules:

- Enumerate the **valid cases** first; each becomes a union case with exactly the data it needs.
- Prefer **state-per-type** (`UnverifiedEmail`, `VerifiedEmail`) over `isVerified` + nullable fields when a state carries different data or permits different operations.
- Operations that change state take the old state type and return the new one; every case must be handled (exhaustive match), so a business-rule change becomes a **compile-time break** — a feature, not a cost.
- The apparent extra complexity is the real complexity of the rule; simpler-looking code is usually skipping cases.
- Never unwrap optionals with unsafe accessors in production code; match all cases.

Patterns, anti-patterns and conversion recipes: [references/states-as-types.md](references/states-as-types.md).

## 5. Detection heuristics (what to refactor)

- A record with `isX: boolean` plus fields only meaningful when `isX` is true.
- Two nullable fields where "exactly one" or "at least one" is required.
- Functions with `if (x.status === ...)` checks guarding property reads.
- Same primitive regex-validated in several layers.
- `equals` missing or reference-compared in sets/maps/tests.
- Setters on money, dates, ranges.
- Float arithmetic on amounts; `round()` sprinkled through calculation code.
- Splitting an invoice into N shares by dividing and rounding each share.

## 6. Limits and trade-offs

- Types guarantee invariants only **in memory**; back them with DB constraints (`schema-and-constraints`).
- Too many tiny types create ceremony; stop where the rule is real and repeated (`kiss-yagni-aha`).
- Deep union explosion (combinatorial states) signals a missing sub-model or a state machine; split the concept.
- Serialization: unions need a discriminator on the wire; define it in the API contract (`arc42-api-contracts-architecture`).
- Languages without sum types (older Java, plain JS): use sealed hierarchies, discriminated unions with a runtime check at the boundary, or private constructors with named factories.

## Quick Decision Checklist

1. Does this primitive have rules, confusable siblings or meaningless operations? Wrap it in an immutable value type.
2. Is equality by value implemented (and used by collections/tests)?
3. Does any operation mutate? Return a new instance instead.
4. Money: integer minor units + currency, explicit rounding, conserving allocation?
5. Does a record carry flags or optional fields that only matter in some states? Split into a union / state-per-type.
6. Are all legal combinations enumerated and all illegal ones impossible to construct?
7. Is every invariant also backed at the DB/API boundary where data enters?

## Deep references

- [Value Object mechanics](references/value-object-mechanics.md) — when writing equality/immutability, deciding value vs entity, or building a Range type.
- [Money, allocation and rounding](references/money-allocation-and-rounding.md) — when implementing or reviewing monetary arithmetic, tax/discount splits or multi-currency code.
- [States as types](references/states-as-types.md) — when a record has flags/optionals, or a business rule says "A or B or both".
- [Sources](references/sources.md) — fetch status per URL.
