# Trigger Evals: rate-limiter-throttler

Last verified 2026-11-27. Check the description against these before editing it.

## Should trigger

1. "Our public API gets hammered by one tenant; add per-tenant limits and return proper 429s." -> rate-limiter-throttler
2. "Bulk-load 10k records into a database that throttles us; how do I pace the calls?" -> rate-limiter-throttler
3. "Under overload, how do we drop low-priority traffic first without flapping?" -> rate-limiter-throttler

## Near misses

1. "Where in the ASP.NET pipeline does UseRateLimiter go?" -> `middleware-interceptor-chain`
2. "Retry failed calls with jittered backoff." -> `circuit-breaker-retry-telemetry`
3. "Cache expensive query results to cut database load." -> `caching-strategies`
