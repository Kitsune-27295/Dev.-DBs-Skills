# Parallel Change: Phases, Applications and Caveats

Sources: https://martinfowler.com/bliki/ParallelChange.html · Last verified 2026-11-27

## The technique
The article is by Danilo Sato, published on Martin Fowler's site on 13 May 2014. Parallel change (also expand and contract) makes a backward-incompatible interface change in three releasable phases:
1. **Expand**: add the new version beside the old; existing code is untouched and old clients keep working.
2. **Migrate**: move clients across incrementally. For external clients this is usually the longest phase.
3. **Contract**: when nothing uses the old version, remove it and reshape the interface so only the new one remains.
Each phase can ship on its own, which suits continuous delivery. The page credits Joshua Kerievsky with first documenting it as a refactoring strategy in 2006, and with presenting it in his 2010 talk "The Limited Red Society".

## Worked example (from the page)
A `Grid` stores cells in a 2D array and exposes `addCell(x, y)`, `fetchCell(x, y)` and `isEmpty(x, y)`; `x` and `y` form a data clump to become `Coordinate`. Expand: add a map keyed by `Coordinate` and overloads taking it, leaving the array and old methods. Migrate: clients switch one at a time. Contract: delete the int methods and the array, rename the map back. Even with full control of every caller, a short migrate phase beats relying on the compiler to break every usage at once.

## Where it applies
- Method and class refactoring. Variant: the old method delegates to the new API, then Inline Method updates callers, so the implementation changes first and two implementations never coexist.
- Database schema changes (migrate is the transition period between schemas).
- Deployments: canary and blue-green releases rest on the same idea; in microservices it can reduce lockstep orchestration between services.
- Remote API evolution as an alternative to explicit versioning: widen the payload or add a new endpoint; Postel's Law (be liberal in what you accept) keeps consumers from breaking when a payload grows.

## Companions
- **Feature flag** chooses old or new during migrate; a client-side toggle keeps the client forward-compatible with the new supplier and decouples the two release schedules.
- **Branch by abstraction** narrows the surface of change when there are many clients; parallel change can be how you introduce the abstraction.

## Caveats and failure modes
- The supplier carries two versions during migrate: more code and more tests.
- Clients can be unsure which version is old; mark it with deprecation notes, documentation or TODOs.
- If contract is never completed, the codebase can end up worse than before (the page's warning).
- Inference, not from the page: expand without a named owner and an exit metric tends never to finish.

## Sketch (API field split; my own example)
```
v1: GET /users -> { "name": "Ada Lovelace" }
expand:   respond { "name": "...", "givenName": "Ada", "familyName": "Lovelace" }
migrate:  track consumers still reading name; notify; flag per consumer
contract: when reads of name == 0 for the agreed window, drop name
```

## How an agent should apply this
- Plan all three phases up front and write the contract step with its exit metric into the ticket before expand.
- Release after each phase; never combine expand and contract in one deploy.
- Prefer delegating old to new so both paths share behavior and cannot diverge.
- Gate contract on evidence of zero use, not on a calendar alone.
- Use branch by abstraction instead when callers are numerous and internal; for choosing between delete, deprecate and parallel change see `simplification-audit`.
