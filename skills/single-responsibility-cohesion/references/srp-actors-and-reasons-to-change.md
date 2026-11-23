# SRP: Reasons to Change, Stakeholders and the Employee Example

Sources: https://blog.cleancoder.com/uncle-bob/2014/05/08/SingleReponsibilityPrinciple.html (canonical slug; the `SingleResponsibilityPrinciple.html` slug returned 404) · Last verified 2026-11-23

## Lineage in the article

1. **Parnas, 1972:** do not decompose a system by flowchart steps; design each module to hide a decision likely to change.
2. **Dijkstra, two years later:** names "separation of concerns".
3. **1970s-80s:** coupling and cohesion are developed.
4. **Late 1990s:** Martin consolidates these into SRP; he says he may have borrowed the name from Meyer, unconfirmed.

Statement: each module should have one reason to change. Martin then asks what a "reason to change" is. Bug fixes and refactorings are the programmer's responsibility and do not count; the useful question is **who the program answers to**.

## The "who"

A company has a CEO and C-level officers: CFO (finance), COO (operations), CTO (technology). Each module should respond to requests from one business function, represented by one person or a tightly coupled group. The article does not use the word "actor"; that term comes from later writing (background knowledge) and is used in this skill as shorthand.

## The Employee example

| Method | Concern | Requests come from |
|---|---|---|
| `calculatePay()` | Financial | CFO's organisation |
| `reportHours()` | Operations, auditing | COO's organisation |
| `save()` | Technology, persistence | CTO's organisation |

The article's argument: a catastrophic error in each method reflects on a different executive, so each serves a different stakeholder; a footnote concedes the firing scenarios are hyperbole but organisations still care about different concerns.

## Why violating it hurts

Changing one method can break another that a different stakeholder depends on. The harm is **trust**: people are upset when something they did not ask to change malfunctions (the mechanic who fixes the window and breaks the engine). Symptoms listed: SQL in JSPs, HTML generated inside computation modules, business rules that know the database schema.

## The remedy

Martin's restatement: gather things that change for the same reasons; separate those that change for different reasons. Equivalent to **raise cohesion** among things with one reason to change and **lower coupling** among things with different reasons. The reasons are *people*, so code that many people care about for different reasons should not be mixed.

## Worked decomposition (author's inference, standard technique)

```
Before: Employee { calculatePay, reportHours, save }
After:  EmployeeData  (fields only)
        PayCalculator, HourReporter, EmployeeRepository   # one actor each
        EmployeeFacade (optional): delegates, no logic
```
Pitfall inside the example: if `calculatePay` and `reportHours` both call a private `regularHours()`, a CFO-driven tweak to overtime silently alters the COO's report. Resolve by giving each class its own version or by making the shared function an explicit, tested contract with one owner.

## Forces and trade-offs

- More classes and wiring versus isolation of change and lower regression risk.
- Facade restores convenience but must stay logic-free, else it becomes the new god class.
- Correct boundaries depend on the organisation: the same code may have one actor in a startup and three in an enterprise (inference). Re-check when team structure changes.

## Use when / avoid when

Use when a module is edited for requests from different business functions, or tests/regressions cross concerns. Avoid when a single actor owns the whole module, however large; splitting adds indirection without isolating anything.

## How an agent should apply this

- Ask "who asks for changes to this?" before reading the code structure.
- Tag methods by actor; split only along clusters with different actors.
- Share data structures by value; do not share logic between actors without ownership.
- Keep I/O and persistence out of business modules (SQL in views, HTML in calculators).
- State the actors explicitly in the PR description.
- Do not justify a split by "single purpose" wording alone.
