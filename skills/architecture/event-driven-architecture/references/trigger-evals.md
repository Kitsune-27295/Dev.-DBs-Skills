# Trigger evals for event-driven-architecture

Last verified 2026-11-27. Starting set, not a scored eval.

Should trigger (expected: this skill)
1. "Our team wants to go event-driven. Should OrderPlaced carry the whole order or just the id?"
2. "Kafka or a plain queue for fanning out a sale to billing, marketing and miles?"
3. "Removing the email subscriber broke checkout. Why does an event listener control our flow?"

Near-miss (expected: neighbor)
1. "Rebuild an aggregate by replaying its stored events, with snapshots" -> `event-sourcing-pattern`
2. "Make payment and stock reservation consistent across services, with compensation" -> `saga-transactional-outbox-pattern`
3. "Worker pool draining a job queue with retries and a poison-message park" -> `background-worker-job-scheduler`
