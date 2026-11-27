---
name: single-responsibility-cohesion
description: "Decide where to cut a module by who asks for changes: the Single Responsibility Principle as cohesion by reason to change (the stakeholder, later called the actor), Parnas information hiding and separation of concerns as its lineage, a split recipe with a change-axis map and git co-change evidence, shared-helper hazards, and the Common Closure Principle for package boundaries (background knowledge, no readable primary page). Deep dive; the overview is `pragmatic-solid-and-ssot`; folder layout is `package-by-feature-component`, variants without edits are `open-closed-principle`. Use when a class or module is edited for unrelated requests, when splitting a god class, when drawing module or package boundaries, or when SRP is being misread as one tiny function per class."
---

# Single Responsibility & Cohesion by Change Axis

One idea: **gather together the things that change for the same reason, separate the things that change for different reasons** — and a "reason" is a *person or group who asks for the change*, not a count of methods. SRP is cohesion/coupling restated at module scale. Sources, fetch outcomes (the two slugs, the missing CCP page) and unadopted claims: [references/sources.md](references/sources.md). Deep dive; for the overview row see `pragmatic-solid-and-ssot`.

Boundaries with neighbors: one fact, one home is `ssot-and-dry`; adding variants without edits is `open-closed-principle`; direction of dependencies and wiring is `dependency-inversion-composition-root`; where bounded contexts split is `ddd-domain-heuristics-debiasing`; feature-oriented layout is `package-by-feature-component` and `vertical-slice-architecture`; do not split before the pain is real: `kiss-yagni-aha`.

---

## 1. Definition that works

Martin's article (8 May 2014, read in full) reaches SRP through three ideas: Parnas (1972) said decompose by hiding decisions likely to change, not by flowchart steps; Dijkstra, two years later, named separation of concerns; Constantine's coupling and cohesion of the 70s-80s were consolidated into SRP in the late 1990s. His test: *what counts as a reason to change?* Bug fixes and refactorings are the programmer's concern, so they do not count; the real question is **who the program answers to**.

> Module-level rule (article): one business function, i.e. one person or tightly coupled group, as the source of requests to a module.

Note on terminology: the word **"actor"** (a group of stakeholders or users who require a change in the module) comes from Martin's later book *Clean Architecture*, per Wikipedia's account; I did not read the book. The 2014 article speaks of people, executives and business functions. Use "actor" as a handy label.

## 2. The canonical example, and what it teaches

`Employee` with `calculatePay()` (CFO's organization), `reportHours()` (COO's, auditing) and `save()` (CTO's, persistence). Three stakeholders edit one file; a change for one can silently break another's behavior, and trust is lost ("mechanic fixes the window, breaks the engine"). Other symptoms the article lists: SQL inside JSPs, HTML built in calculation modules, business rules that know the DB schema. Full walkthrough and split: [references/srp-actors-and-reasons-to-change.md](references/srp-actors-and-reasons-to-change.md).

## 3. Common misreadings to reject

| Misreading | Correction |
|---|---|
| "A class should do one thing" | A module should answer to one actor; it may do many things for that actor |
| One method per class | Over-fragmentation; pass-through helpers (see `codebase-design`) |
| Split by technical layer only | Layers are actors only if different people ask for changes there |
| Split because the file is long | Length is not a reason to change; cohesion is |
| Split before a second actor exists | Speculative; wait for the second axis (`kiss-yagni-aha`) |

## 4. Procedure: find the axes, then cut

1. **List the actors** who request changes to this module (finance, ops, security, product, compliance, DBA, vendor APIs).
2. **Tag each public method/field** with its actor. Tags that cluster = responsibilities.
3. **Check git history**: files/functions that change in different commits for different tickets confirm axes; things that always change together belong together.
4. **Choose a cut**: shared data structure plus one class per actor, or a facade over per-actor classes.
5. **Move behavior**, keep tests green, then delete the old entry points.
6. **Check the arrows**: the actors' modules must not import each other; shared data flows by value.

```python
@dataclass
class EmployeeData: id: str; rate: Money; hours: Hours   # data only, shared
class PayCalculator:  def pay(self, e: EmployeeData): ...        # CFO axis
class HourReporter:   def report(self, e: EmployeeData): ...     # COO axis
class EmployeeRepository: def save(self, e: EmployeeData): ...   # CTO axis
class EmployeeFacade:  # optional single entry point for callers
    ...
```
The hazard to avoid is *shared helper code between actors* (e.g. `regular_hours()` used by pay and reports): a change for one silently changes the other. Duplicate it per actor or give it an explicit owner and contract (`ssot-and-dry` coincidence test).

## 5. Package scale: Common Closure Principle (CCP)

CCP (Martin's package design principles; **not read from a primary source**: the Fowler bliki URL is a 404, and Wikipedia's package-principles page only points to Martin's 1996 "Granularity" article) is SRP for components: classes that change together for the same reasons belong in one package; classes that change at different times go elsewhere, so a typical change touches one package. Treat as background knowledge. Details and the co-change measurement: [references/cohesion-and-common-closure.md](references/cohesion-and-common-closure.md). This skill owns CCP; `package-by-feature-component` points here.

## 6. Detection heuristics

- Merge conflicts in one file from unrelated teams.
- Commit messages for one file mention several unrelated features.
- Imports from both persistence/HTTP and pricing/validation in one module.
- Class name with `Manager`, `Handler`, `Util`, `Service` doing everything.
- Tests need many unrelated fakes to instantiate one object.
- Method clusters sharing disjoint subsets of fields.
- Change in one stakeholder's feature causes regressions in another's.

## 7. Anti-patterns

| Anti-pattern | Fix |
|---|---|
| God class serving several actors | Split by actor, share data by value |
| Shotgun-split: 15 one-method classes | Merge back; cohesion by actor |
| Facade that re-couples everything | Keep facade as pure delegation |
| Shared helper between actors | Duplicate or own explicitly |
| Mixed concerns (SQL in view, HTML in calc) | Move I/O to the edge (`pragmatic-solid-and-ssot` core/shell) |

## Quick Decision Checklist

1. Who asks for changes to this module? One actor or several?
2. Do git history and tickets show different reasons for edits?
3. Are the methods clustered by disjoint fields/imports?
4. Is the split justified by a second actor today, not "someday"?
5. Do the new modules share only data, not helper code across actors?
6. Does a typical change now touch one module/package?

## Deep references

- [Trigger evals](references/trigger-evals.md) — read when tuning the description.
- [SRP: actors and reasons to change](references/srp-actors-and-reasons-to-change.md) — read for the Employee walkthrough, Parnas/Dijkstra lineage and the split.
- [Cohesion and the Common Closure Principle](references/cohesion-and-common-closure.md) — read when deciding package/module boundaries (CCP section is labeled background knowledge).
- [SRP refactoring recipes and signals](references/srp-refactoring-recipes.md) — read when splitting a god class step by step.
