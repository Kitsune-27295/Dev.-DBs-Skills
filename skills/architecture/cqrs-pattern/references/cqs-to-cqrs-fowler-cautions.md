# From CQS to CQRS: Fowler's Cautions

Sources: https://martinfowler.com/bliki/CommandQuerySeparation.html, https://martinfowler.com/bliki/CQRS.html · Last verified 2026-11-27

## Command Query Separation (method level)

Bertrand Meyer's rule, summarized by Fowler (2005): split methods into **queries** (return a result, no observable state change) and **commands/modifiers** (change state, return nothing). Payoff: queries can be called anywhere, in any order, any number of times; only modifiers need care. Fowler (5 Dec 2005) prefers "modifiers" because "command" is used in other senses.

Return type is the usual signal. Violations: Java's iterator `next()` (returns and advances; he would split `advance` and `current`) and stack `pop`, which he tolerates as a useful idiom. Language support is rare because "observable state" is hard to detect automatically; C++ `const` is the only real marking example he knows (he has not used C++ in years).

## CQRS (model level)

Origin: Greg Young (Fowler's article is dated 14 Jul 2011). Start from CRUD with one model; as needs grow (multiple views, validation restricting stored data, derived data) the single model strains. CQRS splits it into a command (update) model and a query (display) model.

Implementation shapes the article describes (the ordering is this skill's reading, not Fowler's ranking):
1. Separate object models, possibly different processes or hardware; changes propagate command to query side.
2. The two models share one database, or use separate databases where the query side can act as a near-real-time reporting store; a communication mechanism is needed between separate ones.
3. Same objects behind different interfaces (like database views); rare and barely "CQRS" since it implies clearly separate models.

Frequent companions: task-based UIs, event collaboration, Event Sourcing, eventual consistency, DDD.

## The warnings (the reason this page matters)

- Be "very cautious"; it is hard to apply well and misuse can strip important design qualities.
- It is a significant mental shift for the whole team; adopt only if the benefit justifies it.
- Fowler writes that "for most systems CQRS adds risky complexity", that most cases he met "have not been so good", and that wrong-domain use costs productivity and raises risk even with a strong team. The article gives no statistics.
- Many information systems are better with one model for reading and updating.

## When it fits

- A specific bounded context, never the whole system.
- A minority of complex domains where command and query needs differ so much one model serves neither.
- High-performance systems with large read/write disparity, scaling and tuning each side separately.
- If the main problem is heavy reporting queries, a ReportingDatabase solves it without CQRS. Where command and query sides overlap heavily, a shared model is easier.

## Ladder (this skill's synthesis of Fowler and Azure)

Method CQS -> separate query code or reporting DB -> separate models, one store -> separate stores. Climb only when a measured problem demands the next rung.

## Example: CQS at method level

```python
class Account:
    def balance(self) -> Money: ...        # query: no side effects
    def deposit(self, amt: Money) -> None: # command: no return value
        self._entries.append(Credit(amt))
```

## How an agent should apply this

- First check whether method-level CQS or a reporting database answers the stated pain.
- Scope any CQRS proposal to one bounded context and say what stays CRUD.
- Warn explicitly about team cost and the "most projects struggled" experience before recommending it.
- Do not conflate CQRS with Event Sourcing or messaging; each needs its own justification.
- When reviewing code, flag query methods that mutate state as CQS violations unless they match an accepted idiom like `pop`.
