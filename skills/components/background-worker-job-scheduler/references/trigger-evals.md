# Trigger Evals: background-worker-job-scheduler

Last verified 2026-11-27. Check the description against these before editing it.

## Should trigger

1. "Our nightly report cron runs twice because we have three replicas; how do we stop that?" -> background-worker-job-scheduler
2. "Build a queue consumer that survives restarts and doesn't loop forever on a bad message." -> background-worker-job-scheduler
3. "Do I need leader election for this scheduler, or is a lock enough?" -> background-worker-job-scheduler

## Near misses

1. "Cap each tenant to 100 requests per second with 429s." -> `rate-limiter-throttler`
2. "Add exponential backoff and a circuit breaker around the payment call." -> `circuit-breaker-retry-telemetry`
3. "Publish an event reliably after the database commit." -> `saga-transactional-outbox-pattern`
