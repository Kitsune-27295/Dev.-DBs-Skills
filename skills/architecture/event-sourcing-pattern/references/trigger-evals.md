# Trigger Evals

Last verified 2026-11-27. Descriptions are checked by reading, not by a scripted run.

## Should trigger (`event-sourcing-pattern`)
1. "We need a full audit trail and the ability to see an account's state on any past date; is an event store worth it?"
2. "Our aggregate's apply method calls the tax API and replays are crashing. What went wrong?"
3. "We renamed a field in OrderPlaced; how do old events still load?"

## Near-miss (belongs elsewhere)
1. "Split our read and write models but keep plain tables" -> `cqrs-pattern`.
2. "Make sure the event reaches Kafka exactly when the DB commit succeeds" -> `saga-transactional-outbox-pattern`.
3. "Design the pub/sub topology and consumer groups" -> `event-driven-architecture`.
