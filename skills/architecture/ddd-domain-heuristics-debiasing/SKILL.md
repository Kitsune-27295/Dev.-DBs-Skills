---
name: ddd-domain-heuristics-debiasing
description: "Decide where to invest in a domain and how to guard the decision against bias: classify subdomains as Core, Supporting or Generic, plot them on a Core Domain Chart (differentiation vs complexity), pick a per-context implementation pattern (Transaction Script, Active Record, Domain Model, Event-Sourced) instead of forcing aggregates everywhere, and run the five-step Debiasing Decisions Checklist before an architecture choice or ADR. Not for the ADR file format (`adr-architecture`), aggregate or value-object design (`defensive-domain-modeling`) or event-store mechanics (`event-sourcing-pattern`). Use when mapping subdomains, choosing how much DDD a module deserves, or reviewing a decision that merely feels right."
---

# DDD Domain Heuristics & Architectural Debiasing

One idea: **do not let tactical DDD patterns (aggregates, entities) dictate every boundary, and do not trust "this feels right" without a structured check.** Separate *where* competitive value lives (strategic: Ubiquitous Language, Bounded Contexts, subdomain classification) from *how* logic is coded inside each context (implementation pattern), and counter known biases at decision time. Sources and their status: [references/sources.md](references/sources.md).

## 1. Apply DDD to DDD (Khononov, 2016)

Khononov classifies DDD's own parts the way DDD classifies a business:

| DDD element | Role he gives it | Why |
|---|---|---|
| Ubiquitous Language | Core domain | The main lever against project failure from poor collaboration |
| Bounded Context | Supporting subdomain | Keeps each term single-meaning, so it supports the language |
| Domain implementation patterns | Generic subdomain | Off-the-shelf (Fowler's PoEAA): Transaction Script, Active Record, Domain Model, Event-Sourced Domain Model |

What the article says about choosing: each pattern fits a level of complexity; it must be expressive enough for the Ubiquitous Language in code; the choice is not permanent and can move to a richer pattern as complexity grows. It gives **no** thresholds per pattern.

Own heuristic (inference, not from the article): start with the simplest pattern that fits and name the signal that triggers an upgrade (rules start to interact, the same conditionals are copied across scripts, audit or "why is it in this state" questions). Pattern details beyond the four names are standard Fowler-style knowledge; event stores are owned by `event-sourcing-pattern`.

## 2. Core Domain Charts (DDD Crew)

Plot each subdomain, capability or Bounded Context on two axes: **business differentiation** and **complexity**. Product and business people judge differentiation; engineers judge complexity. The chart is a discussion aid, not a scoring model. Variants: portfolio, context map with Team Topologies interaction modes, and architecture migration (relabel the y-axis to sequence moves).

- **Complexity clues:** essential domain difficulty, accidental technical complexity (a solution more complex than its function needs), operational complexity outside the software, difficulty discovering new rules, scale, scarce specialist talent, newcomer ramp-up time.
- **Differentiation clues:** how hard a rival would find matching it, advantage now and potential, brand damage from repeated failure, Cynefin domain.

**Inference, not on the DDD Crew page** (it names no quadrants and gives no build/buy advice): a reading many teams use is high/high = Core, build in-house with the strongest people and richer patterns; low differentiation = Generic, buy, adopt or outsource; in between = Supporting, keep simple. Treat it as a starting point for the debate. Pattern placement for the Core context: `clean-architecture`, `hexagonal-architecture`.

## 3. Five-step Debiasing Decisions Checklist (DDD Crew)

The toolkit's premise (its own claim, citing Morewedge et al. and Soll, Milkman and Payne; not independently verified here): awareness alone does not remove bias, structured prompts inside the workflow help. Run it as a **team**, inside an existing ritual (design session, ADR review). Steps and bias tags:

1. **Be Decision-Ready:** Myopic Misery, Status Quo Bias.
2. **Broaden the Frame:** Additive Bias (consider removing), Functional Fixedness (golden hammer).
3. **Seek Independent Advice:** Correlation Neglect, Overconfidence, Authority Bias.
4. **Test Your Assumptions:** Authority Bias (what was this tool built for?), Illusion of Control (plan for when it fails).
5. **Establish Simple Rules:** Law of Triviality (two-way door: decide fast; one-way door: deliberate), False Consensus.

Questions per step, the ten-bias table and a paste-ready ADR block: [references/debiasing-checklist-in-depth.md](references/debiasing-checklist-in-depth.md). ADR structure and lifecycle: `adr-architecture`.

## Mistakes to Catch

- Heavy aggregate and repository ceremony in Generic or Supporting CRUD modules while the Core stagnates.
- Building commodities (auth, billing, notifications) in-house with Core-team capacity.
- Mistaking an echoing design meeting or repeated blog posts for independent verification; never proposing a subtractive option.
- Running the checklist alone, or on every trivial two-way decision.

## Quick Decision Checklist

- [ ] Strategic value (where) separated from implementation pattern (how)?
- [ ] Each subdomain classified, with product input on differentiation?
- [ ] Simplest fitting pattern chosen per context, with a named upgrade signal?
- [ ] Generic subdomains bought or adopted rather than built?
- [ ] A removal option and a failure plan considered?
- [ ] Sources independent? Reversibility (one-way or two-way door) decided before choosing process weight?

## Deep references

- [Subdomain roles and implementation patterns](references/subdomains-and-implementation-patterns.md): read when classifying subdomains, placing them on a chart or choosing Transaction Script vs Domain Model.
- [Debiasing checklist in depth](references/debiasing-checklist-in-depth.md): read when running the five steps or pasting the check into an ADR.
- [Trigger evals](references/trigger-evals.md): should-trigger and near-miss prompts.
