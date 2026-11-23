# YAGNI: Four Costs, Presumptive Features and Boundaries

Sources: https://martinfowler.com/bliki/Yagni.html · Last verified 2026-11-23

## Definition and origin

"You Aren't Gonna Need It" is an XP mantra: do not build capability now for a need you merely expect. It came from Kent Beck rejecting features Chet Hendrickson proposed on the C3 project. Fowler treats it as part of XP Simple Design (incremental design in the second edition of the White Book). A **presumptive feature** is any code supporting a feature that users cannot yet use.

## The four costs of ignoring it

| Cost | Meaning |
|---|---|
| Build | effort on a feature that turns out useless |
| Delay | value lost because effort went to the presumptive feature (the example: two months of storm-insurance revenue) |
| Carry | extra complexity slowing every later change until removed |
| Repair | debt when the feature was built in a way later seen as wrong |

Example: a shipping-insurance startup has separate pricing and sales components. It is adding storm-risk pricing and expects piracy pricing in six months. Building piracy pricing now delays sales work and may never be used.

"Cheaper to build now" arguments must include delay cost and the chance the feature is never needed. Fowler cites Kohavi et al. (Microsoft): about a third of features improved their target metrics, and uses roughly two thirds as the odds a presumptive feature goes unused (practitioner claim).

## Technique: imagine the refactoring

Ask what refactoring would be required to add the capability later. Often the future cost is not much higher. Cheap, complexity-free steps are fine (error messages in a lookup table rather than inline literals).

## Scope

- Applies to speculative abstractions and parameterization: an abstraction that makes today's code harder to read is presumed guilty.
- Applies at small scale: do not add fields or methods before use.
- Only triggers when the choice adds complexity now.

## Boundaries (what YAGNI is not)

- Not a license to skip refactoring, self-testing code or continuous delivery; these are enabling practices.
- Depends on a malleable codebase, and also enables one; without malleability it turns harmful.
- Failures happen (an early change would have been much cheaper) but are memorable through availability bias and rare.

## Anti-patterns

Speculative plugin buses, generic frameworks for one case, config flags nobody reads, "future-proof" layers; also the opposite: using YAGNI to justify tangled code and no tests.

## How an agent should apply this

- Before adding an extension point, name the concrete request that needs it; if none exists, do not add it.
- List the four costs in a review comment when rejecting speculative code.
- Keep tests and refactoring out of YAGNI cuts.
- Prefer zero-complexity preparations (named constants, lookup tables) over abstraction.
- When asked "what if we need X later," estimate the refactoring path instead of building X.
