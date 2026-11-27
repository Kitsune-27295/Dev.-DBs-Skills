# Trigger evals for caching-strategies

Last verified 2026-11-27 (mental test against the current description; not run against a host).

## Should trigger

1. "The product page hits Postgres 400 times a second. Add Redis in front and tell me how to invalidate it." Expected: `caching-strategies`.
2. "Every five minutes our DB CPU spikes right when the homepage key expires." Expected: `caching-strategies` (stampede).
3. "Set headers so the CDN caches this GET for 60 seconds but never user-specific responses." Expected: `caching-strategies` (RFC 9111).

## Near misses

1. "Limit each API key to 100 requests per minute and return 429." Expected: `rate-limiter-throttler`.
2. "When Redis times out, retry with backoff and open a breaker." Expected: `circuit-breaker-retry-telemetry` (the cache-down policy only links back here).
3. "Move image resizing out of the request into a queue worker." Expected: `background-worker-job-scheduler`.

Also a near miss: "Configure the gateway routes and upstream timeouts." Expected: `api-gateway-reverse-proxy`.
