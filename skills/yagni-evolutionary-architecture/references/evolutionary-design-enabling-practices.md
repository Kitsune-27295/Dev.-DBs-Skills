# Evolutionary Design: Enabling Practices, Reversibility and the Will to Design

Sources: https://www.martinfowler.com/articles/designDead.html · Last verified 2026-11-23

## Three modes of design

- **Code-and-fix:** ad hoc decisions accumulate and code gets harder to change (software entropy).
- **Planned design:** up-front drawings handed to builders; struggles with issues found during coding and changing requirements.
- **Evolutionary design:** design grows continuously, viable only when the change curve is flattened.

## Change curve and enabling practices

The classic curve says change cost rises exponentially over the project. XP tries to flatten it using **testing, continuous integration and refactoring**. Fowler's complaint: critics reject XP's practices without adopting these enablers. Jim Highsmith's scales metaphor: as refactoring gets cheaper the balance shifts from up-front design towards refactoring, with the balance point unclear.

## Simplicity

Beck's four rules in priority order: all tests pass; no duplication; reveals intention; fewest classes/methods. "Reveals intention" is subjective. Refactoring does not violate YAGNI because it is how simplicity is maintained.

## Patterns

Learn them, apply only when needed, implement in simplest form first, remove if unpaid.

## Growing an architecture

Architecture is the set of core elements that are hard to change. Pick a broad modest starting shape (layering, persistence, web handling), hold it loosely, correct early errors, simplify when a part adds no value (anecdote: removing EJB late via refactoring). Hard-to-retrofit concerns: internationalization is the example; databases can be evolved incrementally (Sadalage). Add anticipatory structure only with relevant team experience. Order stories by value and technical risk, but shipping the first release comes first.

## Reversibility and will

- Zaninotto's view: complexity largely arises from irreversible decisions. Defer decisions, make them reversible, use source control, prototype to measure future change cost.
- **Will to design:** convergence needs one or two people watching the code and ensuring problems get fixed.
- Signals that design is happening: technical staff complaints, and code being deleted by healthy refactoring. Metrics can be gamed; informed judgment wins.

## Architect role and diagrams

Architect becomes coach, not lone decider. Diagrams communicate; sketch briefly, throw away, keep only cheap-to-maintain ones. Handover documentation is a story judged by business value.

## Failure modes

Dropping tests and CI while "evolving"; keeping every abstraction forever; no one owns convergence; decisions made irreversible without cause.

## How an agent should apply this

- Before cutting design effort, check that tests, CI and refactoring are in place; if not, add them first.
- Record decisions that are hard to reverse and delay them to the last responsible moment.
- When code is stale, delete it; treat steady deletion as a health signal.
- Start with the simplest pattern implementation and evolve.
- Propose short-lived diagrams in PRs, not a maintained UML archive.
