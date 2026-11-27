---
name: ddd-domain-heuristics-debiasing
description: Use when mapping business subdomains into Core, Supporting, and Generic classifications, decoupling strategic DDD (Ubiquitous Language + Bounded Contexts) from tactical implementation patterns (Transaction Script, Active Record, Domain Model, Event-Sourced), plotting Core Domain Charts (Differentiation vs. Complexity), or running a 5-step Debiasing Decisions Checklist in architecture reviews and ADRs.
---

# DDD Domain Heuristics & Architectural Debiasing

One idea: **do not let DDD tactical patterns (Aggregates/Entities) dictate every service boundary, and do not trust architectural gut feelings ("this just feels right") without structured debiasing**. Separate *where* competitive value lives (**Strategic DDD & Core Domain Charts**) from *how* logic is coded inside each boundary (**Tactical Patterns**), and counter cognitive biases explicitly at decision time. Sources and their claims: [references/sources.md](references/sources.md).

## 1. Decoupling Strategic DDD from Tactical Implementation (Vlad Khononov)

Applying DDD to DDD itself clarifies what is irreplaceable vs. interchangeable:

| DDD Layer | Subdomain Role | Purpose & Invariant |
|---|---|---|
| **Ubiquitous Language** | **Core Domain** | Shared, unambiguous business-domain terminology spoken consistently in workshops, docs, tests, and code |
| **Bounded Context** | **Supporting Subdomain** | Explicit linguistic & boundary perimeter inside which a Ubiquitous Language term holds **exactly one meaning** |
| **Domain Implementation Pattern** | **Generic Subdomain** | Interchangeable code pattern implementing domain logic inside a Bounded Context (**Transaction Script**, **Active Record**, **Domain Model**, **Event-Sourced Domain Model**) |

### Pattern-to-Complexity Fit Inside a Bounded Context
1. **Simple domain / low invariant complexity:** Start with **Transaction Script** or **Active Record** (even inside a DDD project). A Bounded Context with a strict Ubiquitous Language does **not** need Aggregates or Value Objects when business rules are simple CRUD.
2. **Complex state invariants / rich lifecycle:** Use **Domain Model** (Aggregates protecting invariants) or **Event-Sourced Domain Model** (`event-sourcing-pattern`).
3. **Evolution Rule:** Business complexity usually *grows* rather than shrinks. Upgrade an individual Bounded Context's implementation pattern independently as its Ubiquitous Language deepens — without rewriting sibling contexts.

## 2. Strategic Portfolio Mapping: Core Domain Charts (DDD Crew)

Plot every subdomain or Bounded Context on a 2D strategic chart (**X-axis: Business Differentiation**, **Y-axis: Domain/Model Complexity**) — calibrating Business Differentiation with product/business stakeholders and Complexity with engineers:

| Quadrant | Business Differentiation | Complexity | Architectural & Sourcing Strategy |
|---|---|---|---|
| **Core Domain** (Top-Right) | High (direct competitive advantage / ROI) | High (hard for competitors to copy) | **Build in-house** with top domain talent; invest in Domain Model / Event Sourcing (`clean-architecture`, `hexagonal-architecture`) and highest test rigor |
| **Supporting Subdomain** (Bottom-Left/Mid) | Moderate / niche differentiation | Low–Moderate | **Keep simple in-house** (Transaction Script / Active Record / minimal services); avoid over-engineering |
| **Generic Subdomain** (Bottom-Left) | Zero differentiation (commoditized) | Low–High (solved externally) | **Buy SaaS, adopt Open Source, or outsource** (auth, billing, notifications, generic CMS) instead of burning Core team capacity |
| **Migration Variant** | Swap Y-axis to **Migration Effort / Risk** | — | Prioritize migrating high-differentiation + tractable-effort contexts first |

### Clues for Calibrating Differentiation & Complexity
- **Differentiation:** How hard would a new entrant or rival find copying this? What direct revenue/brand/engagement leverage comes from it? What brand damage results if it fails repeatedly?
- **Essential vs. Accidental vs. Operational Complexity:** Separate genuine rule/discovery complexity and scale from *accidental* technical bloat (legacy over-engineering) and manual off-system workarounds.

## 3. Five-Step Debiasing Decisions Checklist (DDD Crew Toolkit)

Research shows **knowing about biases does not eliminate them** (`*claim*`: Morewedge et al. / Soll, Milkman & Payne); embed behavioral prompts directly into ADRs (`adr-architecture`) and architecture sessions whenever a choice triggers *"this just feels right"*:

1. **Be Decision-Ready (Mental State & Inertia):**
   - *Myopic Misery / Action Bias:* Are we deciding under incident stress or sprint panic just to do *something*?
   - *Status Quo Bias:* Is high cognitive load pushing us to keep a broken boundary untouched without evaluating alternatives?
2. **Broaden the Frame (Solution Space):**
   - *Additive Bias (Subtraction Neglect):* Did we consider **removing** a layer, service, or rule instead of always adding a new one?
   - *Functional Fixedness (Golden Hammer):* When hearing *"service"*, *"manager"*, or *"handler"*, did we examine what the concept actually *knows* and *does* instead of reaching for our default pattern?
3. **Seek Independent Advice (True Diversity):**
   - *Correlation Neglect:* Are we hearing 5 independent validations or 5 echoes of the same Slack thread / blog post?
   - *Overconfidence & Authority Bias:* Would we ask the exact same skeptical questions if a junior teammate—rather than a senior architect or AI—proposed this? Did we examine strong dissenting views?
4. **Test Assumptions Against Reality:**
   - *Authority Bias (Tech Hype):* What problem was this pattern/tool originally designed to solve, and do we *actually* have that problem?
   - *Illusion of Control:* What happens **when** (not *if*) this component fails or scales poorly in production?
5. **Establish Simple Rules (Proportional Effort):**
   - *Law of Triviality (Bikeshedding):* Is this a **Two-Way Door** (easily reversible)? If yes, delegate quickly instead of spending hours in group consensus; reserve deep ADR deliberation for **One-Way Doors**.
   - *False Consensus Effect:* Did the *group* check assumptions explicitly with psychological safety to disagree, rather than assuming silence means agreement?

## Mistakes to Catch

- **Forcing Tactical Aggregates Everywhere ("All-DDD Domain Model"):** Implementing heavy DDD Aggregate + Repository ceremony for Generic or Supporting CRUD modules, delaying delivery on the actual Core Domain.
- **Building Generic Commodities In-House:** Spending top engineering bandwidth building custom auth, scheduling, or payment ledgers while the true Core differentiator stagnates.
- **Solo Gut-Check Architecture Reviews:** Confusing team consensus (echoed enthusiasm in a design meeting) with independent verification, or skipping subtractive alternatives when refactoring complex monoliths.

## Quick Decision Checklist

- [ ] Have I separated where competitive value lives (strategic) from how logic is coded (tactical)?
- [ ] Is each subdomain classified as Core, Supporting or Generic, using differentiation and complexity?
- [ ] Do I start simple (Transaction Script or Active Record) and use Aggregates only for complex invariants?
- [ ] Will Generic subdomains be bought, adopted or outsourced instead of built in-house?
- [ ] Did I consider removing a layer, service or rule, not only adding one?
- [ ] Do I have independent advice rather than echoes, and did I test the pattern's original purpose?
- [ ] Is this a Two-Way Door to decide quickly, or a One-Way Door that needs an ADR?

## Deep references

- [Subdomain roles and implementation patterns](references/subdomains-and-implementation-patterns.md) — read when classifying subdomains or choosing Transaction Script vs Domain Model
- [Debiasing checklist in depth](references/debiasing-checklist-in-depth.md) — read when running the five-step check or pasting it into an ADR
