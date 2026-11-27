# Trigger Evals

Last verified 2026-11-27. Descriptions are checked by reading, not by a scripted run.

## Should trigger (`saga-transactional-outbox-pattern`)
1. "Order service saves to Postgres then publishes to RabbitMQ; sometimes the event is lost after a crash. Fix it."
2. "Payment succeeded but inventory reservation failed across two services; how do we roll back?"
3. "Consumers are processing the same message twice after the relay restarted."

## Near-miss (belongs elsewhere)
1. "Wrap these three table updates in one database transaction safely" -> `transaction-fix`.
2. "Choose between pub/sub and event streaming for our notifications" -> `event-driven-architecture`.
3. "Store the order's history as events and replay it" -> `event-sourcing-pattern`.
