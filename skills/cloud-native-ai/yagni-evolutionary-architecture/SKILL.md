---
name: yagni-evolutionary-architecture
description: "Decide whether to build a speculative feature, abstraction, future-proofing layer or distributed scale now, using Martin Fowler's four YAGNI costs (build, delay, carry, repair), the \"imagine the refactoring\" test, the enabling practices of evolutionary design (tests, continuous integration, refactoring), the Design Stamina Hypothesis and Sacrificial Architecture. Not for per-edit parameter and helper decisions (`kiss-yagni-aha`) or for choosing monolith versus services (`monolithic-architecture`, `microservices-architecture`). Use when a design review asks \"should we build for this future need\", when YAGNI is cited to skip tests or cleanup, or when weighing deadline pressure against design quality or planned replacement."
---

# YAGNI & Evolutionary Architecture

One idea: **never build speculative features or future-proofing abstractions today for tomorrow's guessed needs — instead, keep the codebase simple and malleable through automated tests, CI, and continuous refactoring so you can evolve cleanly (or gracefully sacrifice components) when real scale and requirements arrive**. Sources, retrieved statuses and unadopted claims: [references/sources.md](references/sources.md).

## Vocabulary (Martin Fowler)

| Term | Meaning | Test sentence |
|---|---|---|
| YAGNI ("You Aren't Gonna Need It") | do not build a **presumptive feature** or speculative abstraction before it is actually needed for current use | "if no live caller uses this hook or flag today, delete or defer it" |
| Presumptive Feature | code or parameterization added now strictly for a presumed future capability not yet exposed or needed | "untested hooks built 'just in case' incur ongoing carry cost from day one" |
| Enabling Practices (`Is Design Dead?`) | **Self-Testing Code**, **Continuous Integration**, and disciplined **Refactoring** that flatten the exponential cost-of-change curve | "without tests and refactoring, YAGNI degenerates into reckless 'code-and-fix'" |
| Design Payoff Line (`Design Stamina Hypothesis`) | cumulative-delivery crossover point beyond which good design beats "no-design" hacking in net delivery speed | "Fowler estimates this crossover arrives in *weeks, not months* (`*claim*`)" |
| Sacrificial Architecture | deliberately building an early system or module cleanly enough to move fast *and* expecting to discard/replace it when growth exceeds ~10x | "modular boundaries make sacrificing an obsolete layer painless later" |

## The 4 Costs of Ignoring YAGNI (Fowler)

Even when building speculative code feels "cheap right now", every presumptive feature incurs up to four compounding costs:

1. **Cost of Build:** Effort spent analyzing, coding, and testing a capability that may never be used (Fowler cites Kohavi et al. at Microsoft: only about a third of features improved their target metrics, so he puts the odds a presumptive feature is unneeded at two thirds or higher `*claim*`).
2. **Cost of Delay (Opportunity Cost):** Time spent building future capability delays shipping high-value current features and learning from real users.
3. **Cost of Carry:** Speculative abstractions and dead branches increase cognitive load, debugging time, and modification friction for *every* feature built between today and the day (if ever) the guess pays off.
4. **Cost of Repair:** When the future requirement finally arrives, domain understanding and libraries have evolved — meaning a feature built the wrong way must be fixed or worked around; presumptive features are often built wrong.

> **Decision Test — *"Imagine the Refactoring"*:** Before adding an abstraction or extension point for a future case, mentally sketch how you would refactor the simple version into the generalized one when the second real use case actually arrives. If refactoring later is straightforward (or cheap once tests exist), **defer it**. Only do up-front prep when it adds virtually **zero complexity** now while preventing massive rework later (e.g., error messages in a lookup table rather than inline literals).

## What YAGNI Is NOT (Boundary Conditions)

- **YAGNI does NOT skip clean design, tests, CI, or refactoring:** Effort that makes code *easier to understand and modify* (renaming, eliminating duplication, modular boundaries, `integration-tests`) **enables** YAGNI and **is never a violation of it**.
- **YAGNI ≠ Zero Starting Architecture:** Establish a clean initial skeleton (`monolithic-architecture`, basic data persistence when multi-user data needs are obvious, clear internal module boundaries), while keeping decisions **reversible** (*Enrico Zaninotto's Reversibility principle*) and deferring premature distribution (`microservices-architecture`).
- **Simple design:** Beck's four rules (tests pass, no duplication, reveals intention, fewest elements) and the Rule of Three are owned by `kiss-yagni-aha`; refactoring is how simplicity is kept, so it never violates YAGNI.
- **Will to Design:** Design happens only when someone keeps deleting dead code and refactoring mess early. Healthy refactoring *deletes* code steadily.

## Design Stamina Hypothesis vs. Sacrificial Architecture

- **Above the Design Payoff Line (Nearly all real products, > weeks):** Neglecting internal quality ("we must skip cleanup to hit next month's launch") creates an illusory short-term boost followed by crippling slowdowns. Keep internal modularity and tests strong from week one.
- **Below the Design Payoff Line / High Uncertainty Prototypes:** A **Sacrificial Architecture** (`monolithic-architecture` over distributed microservices) optimizes for *fast product discovery* while keeping **internal module boundaries clean** so you can later replace an individual module rather than rewriting the whole codebase.
- **Jeff Dean's Order-of-Magnitude Rule (`*claim*`):** *"Design for ~10x current needs, plan to rewrite before ~100x"* — building 100x distributed machinery on day one slows 1x iteration to a crawl and solves the wrong scaling bottlenecks.
- **Avoid Sunk-Cost / Accounting Lock-In:** Expect the team that built version 1 to decide calmly when to retire it (unlike a new team blindly hating legacy code it never understood), and challenge enterprise amortization accounting that punishes replacing obsolete software.

## Mistakes to Catch

- **Using "YAGNI" as an Excuse for Zero Tests or Tangled Code:** Skipping refactoring and tests flattens *nothing* — the exponential change curve will punish the next feature.
- **Speculative Generalization ("Rule of One"):** Creating abstract base factories, plugin buses, multi-tenant routers, or message queues for a single concrete requirement. Wait for real variations before generalizing (procedure in `kiss-yagni-aha`).
- **Building Unrequested Distributed Infrastructure ("100x on Day 1"):** Adopting Kubernetes, Kafka, Event Sourcing, and 12 microservices for an unproven domain instead of a modular `monolithic-architecture` ready to evolve.
- **Stagnant Codebases Where Nothing Is Ever Deleted:** Growing code monotonically with abandoned flags, unused interfaces, and backward-compatibility shims because nobody dares remove obsolete paths.

## Quick Decision Checklist

- [ ] Does a live caller use this hook, flag or abstraction today, or should I delete or defer it?
- [ ] Did I imagine the refactoring from the simple version, and is it cheap enough to defer?
- [ ] Am I keeping tests, CI, refactoring and clean module boundaries rather than calling that YAGNI?
- [ ] Is the up-front prep nearly zero complexity while preventing large rework?
- [ ] Am I waiting for real variations before generalizing a single requirement?
- [ ] Am I avoiding day-one distributed infrastructure in favor of a modular monolith?
- [ ] Am I designing for about 10x current needs, not 100x, with decisions kept reversible?

## Deep references

- [YAGNI costs and boundaries](references/yagni-costs-and-boundaries.md) — when rejecting or defending speculative features and abstractions
- [Evolutionary design enabling practices](references/evolutionary-design-enabling-practices.md) — when checking tests/CI/refactoring readiness, reversibility and the will to design
- [Design stamina and sacrificial architecture](references/design-stamina-and-sacrificial-architecture.md) — when trading design quality against deadlines or planning replacement
- [Trigger evals](references/trigger-evals.md) — should-trigger and near-miss prompts for the description
- [Sources](references/sources.md) — URLs, retrieved statuses, reading limits, claims not adopted
