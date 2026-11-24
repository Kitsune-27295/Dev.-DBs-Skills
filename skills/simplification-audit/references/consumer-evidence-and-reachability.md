# Consumer Evidence and Reachability

Sources: https://www.hyrumslaw.com · https://abseil.io/resources/swe-book/html/ch15.html · https://refactoring.guru/smells/dead-code · https://martinfowler.com/bliki/ParallelChange.html · Last verified 2026-11-24

## The rule

Do not recommend a deletion unless you have either (a) evidence that no producer or consumer exists, or (b) an explicit, named capability loss that the decision-maker accepts. "I found no callers" is evidence only to the extent the search could have found them.

## Hyrum's Law as the reason

Hyrum's Law, as stated on its site: with a sufficient number of users of an API, it does not matter what you promise in the contract, because all observable behaviors of your system will be depended on by somebody. Consequences for an audit:
- Undocumented and unintended behavior can have consumers; removing or altering it can break them.
- A change must satisfy the documented contract and the implicit one formed by real usage.
- Unstated qualities such as performance or ordering can be depended on too.
- Tests can reveal new dependencies but do not make breaking them acceptable.
- The more widely used the surface, the more you must examine usage before changing it. For a small private helper in one repository, the risk is low; for a published interface it is high.

## Search forms

Search every form a consumer can take, not just the symbol:
1. The identifier itself, and renamed or aliased imports.
2. Property reads and writes (`obj.field`, `obj["field"]`), destructuring, and spread.
3. Both `.method(` and `method(` call forms; method references passed as values.
4. Discriminants and string constants: event names, enum values, wire strings, status codes, config keys, environment variable names, CLI flags, route paths.
5. Dynamic construction: names built from strings, reflection, registries, dependency injection by name, plugin manifests, framework conventions (a file name or decorator that registers code).
6. Generated code and artifacts: generators that read the thing, catalogs and schemas derived from it, docs generated from it.
7. Non-code consumers: scripts, shell, CI, infrastructure files, dashboards, queries over stored data, documentation examples users copy.
8. Constructors and emitters as well as callers: the value may be produced somewhere you have not looked.

Practice: search broad text first (the plain-text search of the whole tree, including hidden folders), then read each hit; do not rely on a type-aware tool alone because it will miss strings and manifests. Combine both.

## Where consumers live

Include every package and app, scripts and runtime wrappers, shipped profiles and overlays, manifests and public exports, loader and resolver behavior, generated runtime assets, examples and fixtures (classified by actual entry point, since an example directory can be the entry point of a product), documentation consumers, and installed-package or downstream users. A generated catalog read by a dynamic mount is a product API; a documentation-only listing is not a fixed caller. If the surface is published, zero in-repo callers does not mean zero consumers.

## What each kind of evidence proves

| Evidence | Proves | Does not prove |
|---|---|---|
| Static search finds no reference | No static reference in the searched tree | No dynamic, external or future use |
| Tests reference it | Something expects the behavior | A shipped producer or consumer exists |
| Declarations or types mention it | A contract exists | Anyone uses it |
| Runtime logs or counters over a representative window | Observed use or non-use in that environment and period | Rare paths outside the window (month-end jobs, annual events) |
| Passing the full suite after removal | The suite's covered consumers are fine | Consumers outside the suite |
| A temporary rename of an implementation-only symbol, or a planned brownout, followed by watching for breakage | Hidden dependents surface | A safe state for all time; keep the window and rollback in mind |

The deprecation chapter lists the same mix: static discovery (code search and dependency graphs), runtime logging and sampling for dynamic dependencies, the global test suite as an oracle that references are gone, and probing with planned outages or renames, plus static analysis to stop new uses appearing after the decision.

## Own checklist for runtime evidence

1. Pick a window that covers the longest business cycle that could use the thing.
2. Count reads or calls with a harmless counter or log line (no personal data).
3. Include every environment that might differ (staging is not production).
4. Record the window and result in the candidate record; mark as "insufficient evidence" if the window is short.
5. Keep the rollback ready until the window after removal has passed.

## Failure modes

- A static tool declares a symbol unused when a manifest or a string loads it.
- Treating a fixture or example as dead because it sits under a test-like directory.
- Treating a declared type as proof of a caller.
- Concluding "unused" from a repository that is only one of several consumers.
- A mixed proposal where one rejected part is read as rejecting all parts.
- Removing an exported helper "everyone knows is internal" that a downstream package imports.

## How an agent should apply this

- Write down the search forms used and the places searched for each candidate; list what was not searched.
- Escalate a candidate from "no static refs" to "safe" only with runtime evidence or a named accepted loss.
- Treat published surfaces as consumers-unknown and route them to a deprecation path.
- Re-run the search at the moment of removal; evidence goes stale as the code changes.
- Say plainly when evidence is insufficient instead of rounding up.
