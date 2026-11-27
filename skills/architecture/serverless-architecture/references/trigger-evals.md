# Trigger Evals

Last verified 2026-11-27. Expected skill per prompt.

Should trigger `serverless-architecture`:
1. "Our Lambda behind API Gateway times out and opens a new Postgres connection each call; how do we fix it?"
2. "Would moving our nightly webhook processing to Cloud Functions make sense cost-wise?"
3. "Kinesis consumer keeps retrying one bad record and the shard is stuck."

Near-misses:
1. "Tune retry backoff and circuit breaker for a REST client" -> `circuit-breaker-retry-telemetry`
2. "Split our order system into services" -> `microservices-architecture`
3. "Explain event sourcing versus event notification" -> `event-driven-architecture`
