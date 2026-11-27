# Design Stamina Hypothesis and Sacrificial Architecture

Sources: https://martinfowler.com/bliki/DesignStaminaHypothesis.html ; https://martinfowler.com/bliki/SacrificialArchitecture.html · Last verified 2026-11-27

## Design Stamina Hypothesis (2007)

Claim: design is not a trade against speed; it pays by keeping software easy to evolve. Skipping it gives short-term speed and later technical-debt slowdown.

Graph (cumulative functionality over time): the no-design project starts faster, then its slope falls as the code deteriorates; the good-design project starts slower with roughly constant slope. They cross at the **design payoff line**.

- Delivery target below the line: trading design for speed may be worth it.
- Above the line: the trade is illusory and you ship later.
- Fowler: the line is "usually weeks not months" (judgment, not measurement).
- He calls it a conjecture with no objective proof, yet an axiom for him and many others; he holds the line is much earlier than most assume.
- Technical debt framing: borrowing makes sense only below the line and when value exceeds interest.

## Sacrificial architecture (2014)

Idea: code you expect to discard in a few years can be the best code to write now; replacement can signal success.

- eBay (Fowler relays this from Randy Shoup, no primary source): Perl scripts over a weekend in 1995, C++ in 1997, Java in 2002. An architecture fitted to one scale does not fit one far larger, and the larger one would be too complex early.
- Jeff Dean, quoted in a footnote (the linked keynote PDF could not be opened): design for ~10X growth, but plan to rewrite before ~100X.
- Priorities shift: early on, flexibility for changing features beats performance and availability; later, performance and reliability dominate. Performance trade-offs are often business decisions.
- Keep internal modularity: poor modularity hurts faster than replacement cycles. A good first version reveals the right module boundaries for the next.
- Replace module by module as the system grows.
- Accounting: amortization can make teams reluctant to replace a clearly unviable system, mostly in large enterprises (credited to Jonny Leroy).
- Release new features to a user subset first, built disposably.
- Fowler is cautious about microservices as a sacrificial architecture: distribution and asynchrony add complexity; a monolith first, services extracted later, is often better.
- The authoring team is best placed to decide when to retire code, unlike a new team that dislikes code it did not write.

## How the two combine (inference)

Stamina says keep internal quality from week one; sacrificial says do not over-build for scale you do not have. Together: clean modules, simple deployment, planned replacement.

## How an agent should apply this

- Reject "skip tests to hit the date" for anything lasting longer than a few weeks.
- For prototypes below the payoff line, say so explicitly and still keep module boundaries.
- Size scalability work for about 10x current load, not 100x.
- Recommend a modular monolith as the first shape unless there is evidence for services.
- Flag amortization or sunk-cost reasoning when a team resists replacing a module.
