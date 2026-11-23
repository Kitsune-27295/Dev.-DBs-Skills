---
name: defensive-domain-modeling
description: "Model domains safely in code using Parse Don't Validate, Making Illegal States Unrepresentable, Value Objects, Tell Don't Ask, Law of Demeter, method-level CQS, Guard Clauses, and Railway-Oriented Programming (Result/Either). Use when eliminating primitive obsession, shotgun parsing, train-wreck navigation, or exception-heavy business flows."
---

# Defensive Domain Modeling & Type-Safe Flows

One idea: enforce domain invariants **once at the boundary** by parsing untrusted inputs into constrained Value Objects and sum types where illegal states cannot exist, co-locating invariants with behavior (**Tell, Don't Ask** / **Law of Demeter**), separating commands from queries (**CQS**), and composing fallible domain steps through explicit **`Result` pipelines**. For store/read separation across services, see `cqrs-pattern`; for SQL/database-level constraints, see `schema-and-constraints`; for module/SSOT boundaries, see `pragmatic-solid-and-ssot`. Sources and claims: [references/sources.md](references/sources.md).

---

## 1. Parse, Don't Validate (Eliminate Shotgun Parsing)

From Alexis King (*Parse, Don't Validate*):

| Approach | Signature & behavior | Hidden cost |
|---|---|---|
| **Validate** | `validateEmail(raw: string): void` or `isValid(raw): boolean` | Checks run, then **throws away the proof** — callers still hold raw `string`, forcing repeated `if (!raw)` checks downstream (*shotgun parsing*) or risky assumptions |
| **Parse** | `parseEmail(raw: string): Result<EmailAddress, EmailError>` | Transforms weak, untrusted data into a **stronger domain type** carrying compile-time proof that invariants hold everywhere downstream |

**Rules of boundary parsing:**
1. **Push parsing upward** to system edges (HTTP request DTOs, CLI args, webhook payloads, file reads, DB deserializers) so internal domain functions take already-parsed types (`NonEmptyArray<T>`, `PositiveMoney`, `VerifiedEmail`) and are **total** (no defensive `throw` for impossible nulls).
2. **Avoid boolean blindness:** Do not check `if (items.length === 0) return;` and then index `items[0]` inside helpers. Pattern-match or parse into a type that preserves the refined case (`NonEmptyArray<T>`).
3. **Never write `validateFoo(): void` when a refined return type is possible:** Return the parsed type or `Result<ParsedFoo, ValidationError>`.

---

## 2. Make Illegal States Unrepresentable & Value Objects

From Scott Wlaschin (*Designing with Types*) and Martin Fowler (*ValueObject*, *Primitive Obsession*):

### Sum Types / Discriminated Unions over Flag Soup
- **Smell (illegal state representable):** `{ email: string; isVerified: boolean; verifiedAt?: Date; token?: string }` allows `{ isVerified: true, verifiedAt: undefined }` or verified states missing tokens.
- **Fix (discriminated union):**
  ```typescript
  type CustomerEmail =
    | { kind: "unverified"; email: EmailAddress; verificationToken: Token }
    | { kind: "verified"; email: EmailAddress; verifiedAt: Instant };
  ```
- **Single-case wrappers:** Wrap raw primitives (`CustomerId`, `EmailAddress`, `CurrencyCode`, `String50`) so `charge(userId, orderId)` cannot swap two `string` arguments at compile time.
- **Legacy/dirty database records:** When reading unvalidated historical rows, model a separate choice state (e.g., `VerifiedEmail | UnverifiedEmail | LegacyMalformedEmail`) at the repository boundary rather than crashing on read or silently loosening domain invariants.

### Value Objects (`Money`, `DateRange`, `Quantity`)
- **Structural equality:** Two Value Objects with identical field values are equal (`Money(10, "USD")` equals `Money(10, "USD")`), unlike Entities whose identity is an ID across mutations.
- **Immutability:** Value Objects must be **immutable** — operations return a *new* Value Object (`money.add(other)`), eliminating **aliasing bugs** when two entities reference the same `Date` or `Address`.
- **Self-validating construction:** Validate invariants inside the Value Object's factory/parser (`parseMoney`), so no invalid `Money` instance can exist anywhere in the domain. Remember type guarantees hold only in memory; still back them with SQL constraints (`schema-and-constraints`).

---

## 3. Tell, Don't Ask & Law of Demeter (Behavioral Locality)

From Martin Fowler (*TellDontAsk*) and Lieberherr & Holland (*Law of Demeter*, C2 Wiki):

| Principle | Core rule | Practical boundary / exception |
|---|---|---|
| **Tell, Don't Ask** | Co-locate invariants and state transitions with the data they govern (`order.cancel(reason)` instead of `if (order.status === "paid" && ...) { order.status = "cancelled"; ... }`) | **Do not become a "Getter Eradicator":** Querying read-only properties for UI views, reports, logs, or serialization DTOs is normal; what you forbid is *querying state only to make decisions and mutate the owner from outside* |
| **Law of Demeter (Principle of Least Knowledge)** | Inside method `M` of object `O`, invoke methods **only** on: (1) `O` itself, (2) parameters of `M`, (3) objects instantiated inside `M`, (4) `O`'s direct component fields. Avoid *train wrecks* (`customer.getWallet().getBank().withdraw(amt)`) | **Fluency & Value/Collection exception (Nat Pryce):** Chaining `.map().filter()`, builder calls, or navigating pure immutable **Value Objects / DTOs** does *not* violate LoD; LoD prohibits reaching through service/entity collaborators to mutate or depend on deep structural chains |

---

## 4. Method-Level CQS & Guard Clauses

- **Command–Query Separation (Meyer / Fowler):**
  - **Queries** return a result and produce **zero observable side effects** (safe to inspect, retry, or reorder in tests/debugging).
  - **Commands** mutate state or emit effects and ideally return `void` (or a `Result<Receipt, DomainError>` acknowledgment), never disguising mutations inside read getters.
  - Note: *Meyer's canonical rare exception* (e.g. `stack.pop()`) is an edge case; at application/module scale, keep mutations and reads cleanly separated (for architecture-level read/write stores, see `cqrs-pattern`).
- **Guard Clauses over Nested Conditionals** (*Replace Nested Conditional with Guard Clauses*):
  Check failure/edge preconditions at the top of a function and return early (`if (!order.isPayable()) return err("ALREADY_PAID");`), leaving the main happy path flat at minimum indentation instead of deep nested `if/else` pyramids.

---

## 5. Railway-Oriented Programming (`Result<TOk, TErr>`)

From Scott Wlaschin (*Railway Oriented Programming*):

Model multi-step fallible use cases as a **two-track railway** (`Ok(value)` on the success track, `Err(error)` on the failure track), replacing ad-hoc `try/catch` and silent `null` returns with explicit composable error flows.

| Combinator / Adapter | Purpose in the pipeline |
|---|---|
| `bind` (`flatMap` / `>>=`) | Connects a two-track function (`A -> Result<B, E>`) after the previous step; short-circuits immediately if already on the failure track |
| `map` | Lifts a pure single-track function (`A -> B`) onto the two-track `Result<A, E> -> Result<B, E>` |
| `tee` (dead-end void effect) | Executes a void side-effect step (audit log, metric emission) while keeping the `Ok(value)` flowing forward |
| `tryCatch` | Wraps throwing third-party/I/O calls at the outer boundary into explicit `Result` failures |
| `doubleMap` (`bimap`) | Translates domain error variants into boundary HTTP/CLI/UI responses at the edge |
| **`plus` (applicative / parallel validation)** | Runs independent field parsers in parallel and **accumulates all errors** (`Err(Error[])`) instead of short-circuiting on the first bad input field |

**Crucial scoping rule (Wlaschin's warning):** Use Railway-Oriented Programming for sequential application workflows and boundary validation pipelines where explicit domain failures matter. **Do NOT wrap every tiny pure helper function in `Result<T, E>`** — pure math/transformations inside the core stay single-track (`A -> B`) and lift with `map` only when wired into the pipeline.

---

## Refactoring Smells This Skill Fixes

1. **`validateX(): boolean/void` followed by non-null assertions `!` downstream** → Replace with `parseX(): Result<StrongType, DomainError>` at the entrypoint.
2. **Repeated `if (status === "a" && flagB && date != null)` across 5 modules** → Replace with a discriminated union making illegal flag combinations unrepresentable, plus Value Objects.
3. **External callers computing totals/state transitions via `obj.setX(obj.getY()...)`** → Move logic onto the owning entity/module (*Tell, Don't Ask*) or use pure Value Object methods.
4. **3–4 chained getters (`a.getB().getC().updateD()`)** → Add a single intention-revealing method on `a` (preserving Value Object/collection fluency).
5. **Deeply nested `try { if { if { ... } } }` blocks** → Flatten preconditions with Guard Clauses and chain workflow steps cleanly via `Result` (`bind`/`map`/`tee`).

## Deep references

- [Parse, Don't Validate: Mechanics and Limits](references/parse-dont-validate-mechanics.md) — read for head/NonEmpty reasoning, two-phase design, and the author's own caveats.
- [Illegal States, Union Types and Value Objects](references/illegal-states-and-value-objects.md) — read when modeling a rule as a union or choosing value vs reference object.
- [Tell-Don't-Ask, Law of Demeter, CQS and Guard Clauses: Source Detail](references/tell-dont-ask-demeter-cqs-guards.md) — read for what each source actually says, including Fowler's caveats.
- [Railway-Oriented Pipelines: Composition, Validation and Limits](references/railway-pipeline-composition.md) — read when building or reviewing a Result pipeline with parallel validation.
