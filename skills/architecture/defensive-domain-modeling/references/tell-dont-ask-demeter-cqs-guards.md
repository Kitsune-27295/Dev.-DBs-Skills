# Tell-Don't-Ask, Law of Demeter, CQS and Guard Clauses: Source Detail

Sources: https://martinfowler.com/bliki/TellDontAsk.html · https://www2.ccs.neu.edu/research/demeter/demeter-method/LawOfDemeter/general-formulation.html · https://martinfowler.com/bliki/CommandQuerySeparation.html · https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html · https://wiki.c2.com/?LawOfDemeter (not readable, see below; re-tried 2026-11-27, still only a JavaScript-required shell) · Last verified 2026-11-27

## Tell, Don't Ask (Fowler, 2013)
- Idea: bundle data with the functions that use it; tell the object what to do instead of pulling its data out and deciding outside. Fowler's contrast: an "ask" monitor exposes value, limit and alarm for callers to compare; a "tell" monitor's `setValue` compares and warns internally.
- Rationale: tightly coupled things belong in the same component.
- Fowler's own stance is cooler than the slogan: he does not use TDA as a rule, aims at co-locating data and behavior, and calls TDA a stepping stone. He warns about "GetterEradicators", about tangled code from forcing "tell" where a responsible query would be simpler, and says co-location can yield to other concerns such as layering ("good design is all about trade-offs").
- Origin credited to Andy Hunt and Dave Thomas.

## Law of Demeter (Lieberherr/Holland page)
- Motto: only talk to immediate friends; each unit knows limited details about closely related units. A special case of low coupling; found by Holland at Northeastern in fall 1987.
- Motivation: limiting information overload (short-term memory).
- **Class form**: for a method, closely related classes are the class of `this`, argument classes, classes of stored data members and computed return types, and classes of objects created in the method. Cheap to check, but not the ideal rule.
- **Object form**: the style rule the author actually wants; not statically decidable, so check at run time (suggested as an aspect-oriented exercise).
- Consequence: method-level interfaces become narrow, class-level interfaces wide (many forwarding methods). The page's remedy is an aspect-oriented approach rather than hand-written wrappers.
- Limit of this reading: the page does not list "preferred supplier" objects, and the C2 Wiki page (Nat Pryce on train wrecks versus fluent chains) could not be read: it returns only a "JavaScript required" shell to both WebFetch and curl. SKILL.md's Pryce-based exception is therefore not re-verified here (not read from source).

## Command-Query Separation (Fowler, 2005)
Queries return a result and leave observable state alone; modifiers change state and return nothing. Fowler follows it whenever he can and accepts `pop` as an exception. Full treatment lives in `cqrs-pattern`.

## Guard clauses (refactoring.com catalog)
The page is only a before/after example: three nested `if/else` blocks assigning to a `result` variable become three top-level early returns (`isDead`, `isSeparated`, `isRetired`) then the normal case. No motivation or mechanics text appears there, so the "special cases first, happy path last" guidance is the common reading, not page prose.

```ts
function payAmount(e: Employee): Money {
  if (e.isDead) return deadAmount(e);
  if (e.isSeparated) return separatedAmount(e);
  if (e.isRetired) return retiredAmount(e);
  return normalPayAmount(e);
}
```

## Trade-offs and failure modes
- Over-applying TDA yields god-objects with forwarding methods; keep read-only query methods for views, reports and serialization.
- Demeter-by-wrappers inflates class interfaces; apply it to collaborators with behavior, not to immutable data.
- Guard clauses read best when the branches are genuine exceptional cases of equal weight; for two equally normal outcomes, a plain if/else is clearer (inference).

## How an agent should apply this
- Move decisions to the owner only when the same ask-then-mutate sequence repeats or an invariant is at risk; leave plain read access alone.
- Replace a 3+ getter chain over entities/services with one named method on the first object; leave chains over immutable values alone.
- Flatten nested conditionals into top-level early returns with one result per line.
- Do not cite the C2 Wiki claims as verified; cite them as secondary.
