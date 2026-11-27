# Trigger evals for pipes-and-filters-pattern

Last verified 2026-11-27. Starting set, not a scored eval.

Should trigger (expected: this skill)
1. "Our PDF ingest is one 900-line function: parse, chunk, embed, index. Help me split it up."
2. "Should each stage of the image pipeline get its own queue or can they run in one process?"
3. "Can I move the validation step after the publish step in this ETL chain?"

Near-miss (expected: neighbor)
1. "Webhook fired twice and the customer was charged twice" -> `idempotency-fix`
2. "Design the worker pool and poison-message handling for this job queue" -> `background-worker-job-scheduler`
3. "Keep stock and payment consistent across two services with compensation" -> `saga-transactional-outbox-pattern`
