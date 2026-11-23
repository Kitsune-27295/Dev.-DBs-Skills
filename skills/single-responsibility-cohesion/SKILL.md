---
name: single-responsibility-cohesion
description: "Deep dive on the Single Responsibility Principle as cohesion by reason to change (the stakeholder/actor who asks for it), including Parnas information hiding, separation of concerns, the Employee calculatePay/reportHours/save example, splitting recipes, change-axis and git co-change detection, and the Common Closure Principle (package-level SRP; background knowledge, source page unavailable). Deep dive; for the overview see `pragmatic-solid-and-ssot`. Use when a class or module is edited for unrelated requests, when splitting a god class, when deciding module or package boundaries, or when SRP is being misread as 'one tiny function per class'."
---

# Single Responsibility & Cohesion by Change Axis

One idea: **gather together the things that change for the same reason, separate the things that change for different reasons** — and a "reason" is a *person or group who asks for the change*, not a count of methods. SRP is cohesion/coupling restated at module scale. Sources and fetch outcomes (including the two slugs and the unreachable CCP page): [references/sources.md](references/sources.md). Deep dive; for the overview row see `pragmatic-solid-and-ssot`.

Boundaries with neighbors: one fact, one home is `ssot-and-dry`; adding variants without edits is `open-closed-principle`; direction of dependencies and wiring is `dependency-inversion-composition-root`; where bounded contexts split is `ddd-domain-heuristics-debiasing`; feature-oriented layout is `package-by-feature-component` and `vertical-slice-architecture`; do not split before the pain is real: `kiss-yagni-aha`.

---

## 1. Definition that works

Martin's article (read in full) reaches SRP through three ideas: Parnas (1972) said decompose by hiding decisions likely to change; Dijkstra named separation of concerns; coupling/cohesion work of the 70s-80s was consolidated into SRP in the late 1990s. His test: *what counts as a reason to change?* Bug fixes and refactorings are the programmer's concern, so they do not count; the real question is **who the program answers to**.

> Module-level rule (article): one business function, i.e. one person or tightly coupled group, as the source of requests to a module.

Note on terminology: the word **"actor"** is the later book formulation; the 2014 article speaks of stakeholders/executives. Use "actor" as a handy label, knowing it is from background knowledge, not from that page.

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

CCP (Martin, package design; **not read from source** since the Fowler bliki page does not exist) is SRP for components: classes that change together for the same reasons and at the same times belong in the same package; classes that change at different times go elsewhere. Effect: a typical change touches one package, so releases and reviews are small. Practical rule: group by *change cadence/actor*, and compare with the reuse and coupling pressures of sibling principles. Treat as background knowledge. Details: [references/cohesion-and-common-closure.md](references/cohesion-and-common-closure.md).

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

- [SRP: actors and reasons to change](references/srp-actors-and-reasons-to-change.md) — read for the Employee walkthrough, Parnas/Dijkstra lineage and the split.
- [Cohesion and the Common Closure Principle](references/cohesion-and-common-closure.md) — read when deciding package/module boundaries (CCP section is labeled background knowledge).
- [SRP refactoring recipes and signals](references/srp-refactoring-recipes.md) — read when splitting a god class step by step.
