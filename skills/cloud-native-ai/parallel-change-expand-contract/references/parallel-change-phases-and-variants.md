# Parallel Change: Phases, Applications and Caveats

Sources: https://martinfowler.com/bliki/ParallelChange.html · Last verified 2026-11-23

## The technique
Parallel change (also expand and contract) makes a backward-incompatible interface change safely in three releasable phases:
1. **Expand**: add the new version beside the old; existing code untouched, old clients keep working.
2. **Migrate**: move clients across incrementally. For external clients this is usually the longest phase.
3. **Contract**: when nothing uses the old version, delete it so only the new one remains.
Each phase can ship on its own, which fits continuous delivery. The fetched page credits Joshua Kerievsky with documenting it as a refactoring strategy in 2006 (talk "The Limited Red Society", 2010).

## Worked example (from the page)
A `Grid` exposes `addCell(x, y)`, `fetchCell(x, y)`, `isEmpty(x, y)`; `x`,`y` is a data clump to become `Coordinate`. Expand: add `Coordinate` overloads backed by a new map while the 2D array stays. Contract: remove the int methods and the array, rename the new field. Even with full control of callers, a short migrate phase beats leaning on the compiler to break every usage at once.

## Where it applies
- Method and class refactoring (variant: old method delegates to new, then inline the callers).
- Database schema changes (migrate = transition between schemas).
- Deployments: canary and blue-green rest on the same idea; in microservices it reduces lockstep deployment orchestration.
- Remote API evolution as an alternative to explicit versioning: widen the payload on the same endpoint (Postel's Law) or add a new endpoint.

## Companions
- **Feature flag** chooses old vs new during migrate; a client-side toggle keeps clients forward-compatible and decouples supplier and client releases.
- **Branch by abstraction** narrows the surface of change when there are many clients; parallel change can be how you introduce the abstraction.

## Caveats and failure modes
- The supplier carries two versions during migrate (more code, more tests).
- People get confused over which is old; mark with deprecation notes, docs, TODOs.
- Skipping contract can leave you worse off than before (the page's warning): two permanent paths that drift apart.
- Expand without a migration owner never ends.

## Sketch (API field split)
```
v1: GET /users -> { "name": "Ada Lovelace" }
expand:   respond { "name": "...", "givenName": "Ada", "familyName": "Lovelace" }
migrate:  track consumers still reading name; notify; flag per consumer
contract: when reads of name == 0 for the agreed window, drop name
```

## How an agent should apply this
- Plan all three phases up front and write the contract step (with its exit metric) into the ticket before starting expand.
- Release after each phase; never combine expand and contract in one deploy.
- Prefer delegating old to new so both paths share behavior and cannot diverge.
- Gate contract on evidence of zero usage, not on a calendar alone.
- Use branch by abstraction instead when callers are numerous and internal.
