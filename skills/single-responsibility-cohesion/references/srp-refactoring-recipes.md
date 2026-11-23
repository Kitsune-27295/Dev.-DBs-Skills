# SRP Refactoring Recipes and Signals

Sources: https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html · Last verified 2026-11-23
Note: the article gives the principle and example; the stepwise recipes, tooling commands and thresholds below are the author's own inference.

## Recipe 1: actor map

Build a small table before cutting.

| Member | Actor | Evidence |
|---|---|---|
| `calculatePay` | Finance | tickets FIN-*, imports `tax` |
| `reportHours` | Ops | tickets OPS-*, imports `report` |
| `save` | Platform | imports `db` |

Two or more distinct actors = candidate split. One actor = stop.

## Recipe 2: extract class by field cluster

1. Find method groups using disjoint field sets.
2. Create a class for each group; move fields and methods.
3. Original class delegates (temporary) so callers are untouched.
4. Migrate callers, delete delegations (`parallel-change-expand-contract`).

## Recipe 3: pull I/O to the edge

Mixed concern (SQL in a calculator): make the calculator a pure function taking data; the caller (shell) loads and stores. This is the functional-core idea in `pragmatic-solid-and-ssot`.

```python
def pay(hours, rate): return hours * rate           # pure, finance-owned
def run(emp_id, repo): e = repo.load(emp_id); repo.save(e.with_pay(pay(e.hours, e.rate)))
```

## Recipe 4: handle shared helpers

For a function used by two actors: (a) duplicate it in each actor's module if the rules may diverge; (b) otherwise move it to a third module with one named owner and a contract test; never leave it as a private method of one actor's class that the other calls.

## Recipe 5: facade for convenience

A facade delegates to per-actor classes and contains no logic. Review rule: if the facade has an `if`, it is a god class again.

## Signals (tool-assisted)

```bash
git log --follow --format='%an %s' -- path/File.java | head -40   # who/why it changes
git log --name-only --pretty=format: -n 100 | sort | uniq -c | sort -rn | head
```
- High churn file touched by many authors for different tickets: strong signal.
- Large file with low churn and single owner: leave it.
- Test setup needing many unrelated fakes: mixed responsibilities.

## When over-splitting (reverse recipe)

If a split produced classes that always change together and are always instantiated together, merge them back. Pass-through classes and one-method-per-class sprawl are symptoms (`codebase-design`).

## Thresholds (heuristic)

- Two actors with real, recent change history: split.
- One actor, many methods: do not split.
- Hypothetical second actor: wait (`kiss-yagni-aha`).

## How an agent should apply this

- Produce the actor map before proposing a split and cite its evidence.
- Split by data cluster first, behavior second, callers third.
- Keep behavior identical per step; run tests after each move.
- Treat shared helpers as a decision, not an accident.
- Undo splits that created always-co-changing classes.
- Mention which neighboring skill handles the next concern (wiring: `dependency-inversion-composition-root`).
