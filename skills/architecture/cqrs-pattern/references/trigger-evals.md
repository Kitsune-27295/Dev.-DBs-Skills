# Trigger Evals

Last verified 2026-11-27. Descriptions are checked by reading, not by a scripted run.

## Should trigger (`cqrs-pattern`)
1. "Our orders module has one huge entity for edits and the list screens; should we split read and write models?"
2. "Review this PR: query handlers load the aggregate and map to a DTO. Is that real CQRS?"
3. "After saving, the user lands on a list page that still shows old data; we use a separate read store. How do we handle it?"

## Near-miss (belongs elsewhere)
1. "Store every order change as an append-only event stream and rebuild state by replay" -> `event-sourcing-pattern`.
2. "Publish an OrderCreated event reliably after the DB commit, without losing it on crash" -> `saga-transactional-outbox-pattern`.
3. "Where do repositories and the unit of work go for this aggregate?" -> `repository-unit-of-work`.
