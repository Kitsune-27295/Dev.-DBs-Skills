# Trigger evals for circuit-breaker-retry-telemetry

Last verified 2026-11-27 (mental test against the current description; not run against a host).

## Should trigger

1. "Our checkout calls payments, tax and shipping; when shipping hangs, everything stalls. How do we isolate it?" Expected: `circuit-breaker-retry-telemetry`.
2. "A short outage turned into an hour-long one because every service retried three times." Expected: `circuit-breaker-retry-telemetry`.
3. "Add traces and metrics so we can see retries and breaker trips, and keep telemetry during a backend outage." Expected: `circuit-breaker-retry-telemetry`.

## Near misses

1. "Cache the catalog in Redis with a 60 second TTL." Expected: `caching-strategies`.
2. "Allow each tenant 1,000 requests per minute and answer 429." Expected: `rate-limiter-throttler`.
3. "Make the payment webhook safe to deliver twice." Expected: `idempotency-fix`.

Also a near miss: "Define the JSON error body for a 503." Expected: `error-handling-problem-details`.
