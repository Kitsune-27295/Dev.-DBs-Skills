---
name: pragmatic-solid-and-ssot
description: "Apply DRY as Single Source of Truth (SSOT), Bounded Context limits on code sharing, pragmatic SOLID design without interface boilerplate, KISS/pure-core wrappers, Rule of Three, Wrong Abstraction recovery, and AHA Programming. Use when refactoring duplicated logic, designing module abstractions, reviewing SOLID/interface overuse, or deciding whether to share or duplicate code."
---

# Pragmatic SOLID, SSOT & Abstraction Discipline

One idea: treat **DRY** as eliminating duplicate *business knowledge*, not duplicate syntax — and treat every **abstraction** (shared helpers, base classes, `IFoo` interfaces) as carrying real coupling cost until **three** real cases share the same **reason to change** inside the same **Bounded Context**. For evolutionary cost models (the four YAGNI costs, Design Stamina, Sacrificial Architecture), see `yagni-evolutionary-architecture`; for strategic subdomain classification, see `ddd-domain-heuristics-debiasing`. Sources and claims: [references/sources.md](references/sources.md).

---

## 1. DRY as Single Source of Truth (SSOT), Not Identical Lines

From *The Pragmatic Programmer* (Thomas & Hunt): **DRY is about duplication of knowledge and intent, not of code structure.**

| Kind of duplication | Verdict | Action |
|---|---|---|
| **Same business rule in two places** (e.g., two copies of tax/fee calculation or validation rules for the same entity) | Real DRY violation | Extract one authoritative source or derive downstream representations |
| **Different concepts happening to look identical** (e.g., `validateAge(age > 0)` and `validateQuantity(qty > 0)` — or `Account.name` vs. `Product.name` formats) | **Coincidental similarity** (false DRY) | **Keep separate.** When one concept changes rule (`age >= 18`), merging them either breaks the other or forces ugly flag parameters |
| **Stored derived data alongside inputs** (`subtotal`, `tax`, `total` stored separately without recomputation or DB constraints) | Inadvertent data duplication | Compute derived fields behind a uniform access interface, or enforce consistency atomically in the DB (`schema-and-constraints`) |
| **Docs/schemas/ORM/API types drifting apart** | Representational duplication | Generate schemas, types, or docs from one canonical schema/contract (`arc42-api-contracts-architecture`) |
| **Imposed duplication by tooling/process** | Structural friction | Eliminate via code generation or declarative metadata (Uniform Access Principle: callers shouldn't care whether a property is stored or computed) |

---

## 2. Where DRY Stops: Bounded Context Boundaries

From Martin Fowler (`BoundedContext`): a term like **Customer**, **Product**, **Order**, or **User** means different things with different attributes and invariants across subsystems (Sales vs. Support vs. Shipping vs. Billing).

- **Rule:** DRY/SSOT applies *inside* a Bounded Context. **Never couple two Bounded Contexts to one shared domain model just to save lines of code.**
- Attempting a single enterprise-wide `Customer` class creates a bloated God Model whose invariants clash across contexts and whose changes break unrelated teams.
- Instead, keep distinct local models per context (`modular-monolith-architecture`, `microservices-architecture`) and translate explicitly at context boundaries (`Mapper` / Anti-Corruption Layer / DTO).

---

## 3. SOLID Pragmatically (What Each Principle Actually Means)

From Robert C. Martin (*SOLID Relevance*, *SRP*, *OCP*, *Interface Considered Harmful*): SOLID principles guide mid-level module and component structure — not mechanical ceremony on trivial scripts.

| Principle | Core rule (what it *means*) | Common misreading to reject |
|---|---|---|
| **S — Single Responsibility (SRP)** | *"A module should be responsible to one, and only one, actor (stakeholder group)."* Gather things that change for the same actor/reason (`calculatePay()` for CFO, `reportHours()` for COO, `save()` for CTO) | "A class/function must only do one tiny thing" (creates over-fragmented pass-through helpers — see `codebase-design`) |
| **O — Open–Closed (OCP)** | Open for extension, closed for modification: add new behaviors via plugins/adapters/strategies instead of editing tested core policy | Over-engineering speculative plugin factories for a single hardcoded implementation |
| **L — Liskov Substitution (LSP)** | Subtypes/implementations must honor the caller's contract (no narrowed preconditions, weakened postconditions, unexpected exceptions, or no-op *Refused Bequest*) | Checking `if (obj instanceof SpecialCase)` at call sites or throwing `NotImplementedError` in an interface method |
| **I — Interface Segregation (ISP)** | Clients should not depend on methods/fields they do not use (avoids unnecessary coupling, fat test mocks, and forced rebuild/redeploy) | Wrapping every concrete `UserService` in a 1-to-1 `IUserService` "for SOLID" |
| **D — Dependency Inversion (DIP)** | High-level domain policy depends on abstractions owned by the policy, not on low-level DB/HTTP/framework drivers (`clean-architecture`, `hexagonal-architecture`) | Inverting stable standard-library or pure value helpers |

**Anti-ceremony rule (*Interface Considered Harmful* & Seam discipline):** Do **not** create boilerplate `IFoo` interfaces for a concrete `Foo` that has only one implementation and sits behind no I/O boundary or test seam. As `codebase-design` puts it: *"One adapter means a hypothetical seam; two adapters means a real one."* Dynamically typed or structurally typed languages (TypeScript, Python, Go implicit interfaces) often don't need upfront `interface` files at all until a second concrete implementation or external boundary test double exists.

---

## 4. Abstraction Timing: Rule of Three, Wrong Abstraction & AHA

How to avoid premature abstraction while still factoring out real duplication:

1. **Rule of Three** (*Refactoring* / Fowler / Kent C. Dodds): Tolerate writing the pattern once, tolerate copying it a second time, and only consider abstracting on the **third** real occurrence *if* all three share the same actor and reason to change.
2. **AHA — Avoid Hasty Abstractions** (*Kent C. Dodds*): Optimize for **ease of change** first, not minimal line count. Avoid locking into the first shared abstraction that pops into mind before seeing how use cases diverge.
3. **Sandi Metz's Recovery Protocol (*The Wrong Abstraction*):**
   *"Duplication is far cheaper than the wrong abstraction."* When an abstraction already exists and a new requirement doesn't quite fit:
   - **Never** add another boolean flag (`isAdmin`, `skipValidation`) and another `if/else` branch inside the shared helper just to preserve "DRY". That creates tangled, brittle multi-caller code nobody dares delete.
   - **Recover instead:**
     1. Re-introduce duplication: **inline** the abstracted code back into each caller that needs custom behavior.
     2. Delete the caller's dead branches and unused parameters inside that caller.
     3. Wait and observe; only extract again later if a genuinely shared, clean subset emerges.

---

## 5. KISS, Pure Core & Thin I/O Wrappers

Synthesizing *KISS* and *Harvard Kempner SWE Principles*:

- **Choose the simplest construct that works:** Prefer plain functions, flat data structures, and direct control flow over design patterns, metaprogramming, or deep inheritance hierarchies.
- **Composition over inheritance:** Compose small behaviors via functions/objects rather than multi-level subclassing (prevents *Refused Bequest* and fragile base classes).
- **Functional Core / Imperative Shell:** Keep core calculations and transformations **pure** (deterministic, no I/O, no hidden globals, returning values instead of mutating shared state) and push I/O, retries, logging, and network calls to a **thin outer wrapper**. Pure functions are trivially testable without mocks (`tdd`, `codebase-design`).
- **Fail fast with clarity:** Validate external inputs at boundaries (`defensive-domain-modeling`) and raise explicit contextual errors rather than swallowing exceptions or returning ambiguous defaults.

---

## Quick Decision Checklist

1. **Are two code blocks truly sharing the same business rule/actor, or are they merely coincidental syntax?** If coincidental or across different Bounded Contexts -> keep them separate.
2. **Are there fewer than three callers, or are callers already passing mode flags?** If yes -> duplicate cleanly or re-inline the wrong abstraction; defer unifying.
3. **Does this `interface` / port separate policy from a varying external I/O or test seam (2+ implementations/adapters)?** If it's 1-to-1 ceremony around pure domain code -> delete the indirection.
4. **Can business logic be extracted as a pure function with thin I/O callers?** If yes -> separate policy from side effects rather than passing flags down the stack.

## Deep references

- [DRY knowledge-duplication taxonomy](references/dry-knowledge-duplication-taxonomy.md) — read when deciding whether two things are real DRY violations (code, docs, data, representational, inter-developer) and what the book prescribes.
- [Bounded Context limits on sharing](references/bounded-context-limits-on-sharing.md) — read before sharing a domain model or "common" module across services or teams.
- [Martin SOLID primary-source notes](references/martin-solid-primary-source-notes.md) — read to cite SRP, OCP, LSP, ISP or DIP accurately and see where the skill wording goes beyond the posts.
- [Interface Considered Harmful: careful reading](references/interface-considered-harmful-reading.md) — read before citing the article against `IFoo` boilerplate; it is a language-design argument.
- [Abstraction timing: Metz, Dodds, Fowler YAGNI](references/abstraction-timing-metz-dodds-fowler.md) — read when deciding extract vs duplicate, or recovering from a flag-ridden helper.
- [Harvard Kempner design principles notes](references/harvard-kempner-design-principles-notes.md) — read for pure-core, thin-adapter and layering guidance with what the page does and does not say.
