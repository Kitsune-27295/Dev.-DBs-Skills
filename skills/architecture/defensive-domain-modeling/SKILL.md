---
name: defensive-domain-modeling
description: "Model the domain core so invalid states cannot exist: parse raw data into stronger types once, replace flag soup with unions, move invariants to the owning object (Tell Don't Ask, Law of Demeter), flatten nesting with guard clauses and compose fallible steps with Result. Fixes primitive obsession, shotgun parsing, train-wreck getter chains and exception-heavy flows. Not for request validation at the edge (`validator-input-parser`), the HTTP error contract (`error-handling-problem-details`), Value Object or Money detail (`value-objects-type-invariants`) or CQS/CQRS (`cqrs-pattern`). Use when designing or refactoring domain code for type-safe invariants."
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

From Scott Wlaschin (*Designing with Types*, crediting Yaron Minsky for the phrase) and Martin Fowler (*ValueObject*):

### Sum Types / Discriminated Unions over Flag Soup
- **Smell (illegal state representable):** `{ email: string; isVerified: boolean; verifiedAt?: Date; token?: string }` allows `{ isVerified: true, verifiedAt: undefined }` or verified states missing tokens.
- **Fix (discriminated union):**
  ```typescript
  type CustomerEmail =
    | { kind: "unverified"; email: EmailAddress; verificationToken: Token }
    | { kind: "verified"; email: EmailAddress; verifiedAt: Instant };
  ```
- **Single-case wrappers:** Wrap raw primitives (`CustomerId`, `EmailAddress`, `CurrencyCode`) so `charge(userId, orderId)` cannot swap two `string` arguments at compile time (a common practice; the Wlaschin page read here shows validated `create` functions but not this technique itself).
- **Legacy/dirty records (own advice, not from a cited source):** model a separate state such as `LegacyMalformedEmail` at the repository boundary instead of crashing on read or loosening the invariant.

### Value Objects
Equality by value, immutability and self-validating construction are owned by `value-objects-type-invariants`; here they are only the tool for wrapping ids, emails and quantities. Fowler's page describes replacing common primitives with value objects (the term "primitive obsession" itself is not on that page). Type guarantees hold only in memory: back them with database constraints (`schema-and-constraints`).

---

## 3. Tell, Don't Ask & Law of Demeter (Behavioral Locality)

From Martin Fowler (*TellDontAsk*, who himself treats it as a stepping stone) and Lieberherr & Holland (*Law of Demeter*):

| Principle | Core rule | Practical boundary / exception |
|---|---|---|
| **Tell, Don't Ask** | Co-locate invariants and state transitions with the data they govern (`order.cancel(reason)` instead of `if (order.status === "paid" && ...) { order.status = "cancelled"; ... }`) | **Do not become a "Getter Eradicator":** Querying read-only properties for UI views, reports, logs, or serialization DTOs is normal; what you forbid is *querying state only to make decisions and mutate the owner from outside* |
| **Law of Demeter (Principle of Least Knowledge)** | Class form: a method may send messages only to its own class, its argument classes, its immediate parts (stored fields or computed return types) and objects it creates. Avoid *train wrecks* (`customer.getWallet().getBank().withdraw(amt)`) | **Fluency exception (common reading, not verified here):** Chaining `.map().filter()`, builder calls, or navigating pure immutable **Value Objects / DTOs** does *not* violate LoD; LoD prohibits reaching through service/entity collaborators to mutate or depend on deep structural chains |

---

## 4. Method-Level CQS & Guard Clauses

- **Command-Query Separation:** queries return a result without changing observable state; commands change state and return nothing. Fowler follows it "whenever I can" and keeps stack `pop` as a useful exception. Method-level rule, the CQRS ladder and the `pop` caveat are owned by `cqrs-pattern`.
- **Guard Clauses over Nested Conditionals** (*Replace Nested Conditional with Guard Clauses*):
  Check failure/edge preconditions at the top of a function and return early (`if (!order.isPayable()) return err("ALREADY_PAID");`), leaving the main happy path flat at minimum indentation instead of deep nested `if/else` pyramids.

---

## 5. Railway-Oriented Programming (`Result<TOk, TErr>`)

From Scott Wlaschin (*Railway Oriented Programming*):

Model multi-step fallible use cases as a **two-track railway** (`Ok(value)` on the success track, `Err(error)` on the failure track), replacing ad-hoc `try/catch` and silent `null` returns with explicit composable error flows.

Adapters (`bind`, `map`, `tee`, `tryCatch`, `doubleMap`, `plus`) and their TypeScript sketch are owned by `error-handling-problem-details` (`references/railway-result-composition.md`).

**Scoping rule (the ROP page warns "don't take it to extremes"):** Use Railway-Oriented Programming for sequential application workflows and boundary validation pipelines where explicit domain failures matter. **Do NOT wrap every tiny pure helper function in `Result<T, E>`** — pure math/transformations inside the core stay single-track (`A -> B`) and lift with `map` only when wired into the pipeline.

---

## Refactoring Smells This Skill Fixes

1. **`validateX(): boolean/void` followed by non-null assertions `!` downstream** → Replace with `parseX(): Result<StrongType, DomainError>` at the entrypoint.
2. **Repeated `if (status === "a" && flagB && date != null)` across 5 modules** → Replace with a discriminated union making illegal flag combinations unrepresentable, plus Value Objects.
3. **External callers computing totals/state transitions via `obj.setX(obj.getY()...)`** → Move logic onto the owning entity/module (*Tell, Don't Ask*) or use pure Value Object methods.
4. **3–4 chained getters (`a.getB().getC().updateD()`)** → Add a single intention-revealing method on `a` (preserving Value Object/collection fluency).
5. **Deeply nested `try { if { if { ... } } }` blocks** → Flatten preconditions with Guard Clauses and chain workflow steps cleanly via `Result` (`bind`/`map`/`tee`).

## Quick Decision Checklist

- [ ] Is untrusted input parsed into a stronger type at the edge, not just validated and discarded?
- [ ] Could a union type replace this flag combination so illegal states cannot be represented?
- [ ] Are raw primitives like ids, emails and money wrapped in self-validating, immutable Value Objects?
- [ ] Do the type guarantees also have matching database constraints?
- [ ] Does the owning object enforce its state transitions (Tell, Don't Ask) instead of callers chaining getters?
- [ ] Do queries stay free of side effects, with commands kept separate?
- [ ] Am I using Result pipelines only for fallible workflows, not wrapping every tiny pure helper?
- [ ] Do independent field parsers accumulate all errors (mechanics in `error-handling-problem-details`)?

## Deep references

- [Parse, Don't Validate: Mechanics and Limits](references/parse-dont-validate-mechanics.md) — read for head/NonEmpty reasoning, two-phase design, and the author's own caveats.
- [Trigger evals](references/trigger-evals.md) — three should-trigger and three near-miss prompts.
- For worked union examples and Value Object mechanics read `value-objects-type-invariants`.
- [Tell-Don't-Ask, Law of Demeter, CQS and Guard Clauses: Source Detail](references/tell-dont-ask-demeter-cqs-guards.md) — read for what each source actually says, including Fowler's caveats.
