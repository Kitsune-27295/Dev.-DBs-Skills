---
name: pragmatic-solid-and-ssot
description: "Apply SOLID pragmatically, without interface boilerplate: what each principle actually asks for, the Liskov and Interface Segregation rules this pack keeps here, the no-ceremony test (no IFoo for a single implementation), and pure-core design with thin I/O wrappers. Points to the owners for the rest: `ssot-and-dry` (DRY, Bounded Context limits), `kiss-yagni-aha` (Rule of Three, AHA), `single-responsibility-cohesion`, `open-closed-principle`, `dependency-inversion-composition-root`. Use when reviewing SOLID or interface overuse, checking a subtype or an interface for fit, or separating a pure core from I/O. Not for deciding whether to share or duplicate code (use ssot-and-dry) or when to abstract (use kiss-yagni-aha)."
---

# Pragmatic SOLID, SSOT & Abstraction Discipline

One idea: treat **DRY** as eliminating duplicate *business knowledge*, not duplicate syntax — and treat every **abstraction** (shared helpers, base classes, `IFoo` interfaces) as carrying real coupling cost until **three** real cases share the same **reason to change** inside the same **Bounded Context**. For evolutionary cost models (the four YAGNI costs, Design Stamina, Sacrificial Architecture), see `yagni-evolutionary-architecture`; for strategic subdomain classification, see `ddd-domain-heuristics-debiasing`. Sources and claims: [references/sources.md](references/sources.md).

---

## 1. DRY as SSOT, and Where It Stops

DRY (*The Pragmatic Programmer*) is about duplication of **knowledge and intent**, not of code structure. Acid test: when one fact changes, do you edit several places or formats (code plus docs, schema plus type)? If yes, it is a real violation; derive or generate from one source. Lookalike code that answers to different rules (`validateAge` vs `validateQuantity`) is **coincidence**: keep it separate.

DRY/SSOT applies *inside* a Bounded Context (Fowler). Never couple two contexts to one shared domain model just to save lines; keep local models and translate at the boundary (Mapper / Anti-Corruption Layer / DTO). The five duplication kinds, the Uniform Access Principle and the context-sharing table live in `ssot-and-dry`.

---

## 2. SOLID Pragmatically (What Each Principle Actually Means)

From Robert C. Martin (*SOLID Relevance*, *SRP*, *OCP*): SOLID principles guide mid-level module and component structure — not mechanical ceremony on trivial scripts.

| Principle | Core rule (what it *means*) | Common misreading to reject |
|---|---|---|
| **S — Single Responsibility (SRP)** | Responsible to one, and only one, actor (stakeholder group); gather what changes for the same actor (`single-responsibility-cohesion`) | "A class/function must only do one tiny thing" (creates over-fragmented pass-through helpers — see `codebase-design`) |
| **O — Open–Closed (OCP)** | Open for extension, closed for modification: add behavior via plugins/adapters/strategies, not edits to tested core policy (`open-closed-principle`) | Over-engineering speculative plugin factories for a single hardcoded implementation |
| **L — Liskov Substitution (LSP)** | Subtypes/implementations must honor the caller's contract (no narrowed preconditions, weakened postconditions, unexpected exceptions, or no-op *Refused Bequest*) | Checking `if (obj instanceof SpecialCase)` at call sites or throwing `NotImplementedError` in an interface method |
| **I — Interface Segregation (ISP)** | Clients should not depend on methods/fields they do not use (avoids unnecessary coupling, fat test mocks, and forced rebuild/redeploy) | Wrapping every concrete `UserService` in a 1-to-1 `IUserService` "for SOLID" |
| **D — Dependency Inversion (DIP)** | High-level policy depends on abstractions it owns, not on DB/HTTP/framework drivers (`dependency-inversion-composition-root`, `clean-architecture`, `hexagonal-architecture`) | Inverting stable standard-library or pure value helpers |

**Anti-ceremony rule (Seam discipline; this is the skill's own guidance, not a claim of Martin's *Interface Considered Harmful*, which is a language-design dialogue about the Java/C# `interface` keyword):** Do **not** create boilerplate `IFoo` interfaces for a concrete `Foo` that has only one implementation and sits behind no I/O boundary or test seam. As `codebase-design` puts it: *"One adapter means a hypothetical seam; two adapters means a real one."* Dynamically typed or structurally typed languages (TypeScript, Python, Go implicit interfaces) often don't need upfront `interface` files at all until a second concrete implementation or external boundary test double exists.

---

## 3. Abstraction Timing: Rule of Three, Wrong Abstraction & AHA

- **Rule of Three:** copy a second time, abstract only on the third real occurrence, and only if all three share the same actor and reason to change.
- **AHA (Avoid Hasty Abstractions):** optimize for ease of change, not fewest lines.
- **Wrong Abstraction (Metz):** duplication is far cheaper than the wrong abstraction. Never add another boolean flag to a shared helper; inline it back into each caller, delete the dead branches, and re-extract only a clean common subset later.

Recovery steps, smells and AHA recipes live in `kiss-yagni-aha`.

---

## 4. KISS, Pure Core & Thin I/O Wrappers

Drawing on the *Harvard Kempner SWE Principles* handbook (KISS, pure core with thin I/O wrapper, default to functions and plain data over deep inheritance, specific error messages) plus this skill's own guidance; items marked *(skill wording)* are not named by that page:

- **KISS:** pick the simplest construct that works (plain functions and data, composition before inheritance); the ordering is in `kiss-yagni-aha`.
- **Functional Core / Imperative Shell:** Keep core calculations and transformations **pure** (deterministic, no I/O, no hidden globals, returning values instead of mutating shared state) and push I/O, retries, logging, and network calls to a **thin outer wrapper**. Pure functions are trivially testable without mocks (`tdd`, `codebase-design`).
- **Fail fast with clarity *(skill wording; the handbook asks for specific, informative error messages)*:** Validate external inputs at boundaries (`defensive-domain-modeling`) and raise explicit contextual errors rather than swallowing exceptions or returning ambiguous defaults.

---

## Quick Decision Checklist

1. **Are two code blocks truly sharing the same business rule/actor, or are they merely coincidental syntax?** If coincidental or across different Bounded Contexts -> keep them separate.
2. **Are there fewer than three callers, or are callers already passing mode flags?** If yes -> duplicate cleanly or re-inline the wrong abstraction; defer unifying.
3. **Does this `interface` / port separate policy from a varying external I/O or test seam (2+ implementations/adapters)?** If it's 1-to-1 ceremony around pure domain code -> delete the indirection.
4. **Can business logic be extracted as a pure function with thin I/O callers?** If yes -> separate policy from side effects rather than passing flags down the stack.

## Deep references

- [Martin SOLID primary-source notes](references/martin-solid-primary-source-notes.md) — read to cite SRP, OCP, LSP, ISP or DIP accurately and see where the skill wording goes beyond the posts.
- For DRY duplication kinds and Bounded Context limits read `ssot-and-dry`; for Metz, Dodds and the YAGNI four costs read `kiss-yagni-aha` and `yagni-evolutionary-architecture`.
- [Interface Considered Harmful: careful reading](references/interface-considered-harmful-reading.md) — read before citing the article against `IFoo` boilerplate; it is a language-design argument.
- [Harvard Kempner design principles notes](references/harvard-kempner-design-principles-notes.md) — read for pure-core, thin-adapter and layering guidance with what the page does and does not say.
