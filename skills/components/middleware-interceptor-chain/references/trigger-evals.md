# Trigger Evals: middleware-interceptor-chain

Last verified 2026-11-27. Check the description against these before editing it.

## Should trigger

1. "My CORS preflight returns 401 in ASP.NET Core; where should UseCors go relative to UseAuthentication?" -> middleware-interceptor-chain
2. "I need a custom middleware that logs a correlation id before and after every request." -> middleware-interceptor-chain
3. "Should I model these validation steps as a chain of handlers, decorators or filters?" -> middleware-interceptor-chain

## Near misses

1. "Pick which handler gets this command based on its type." -> `router-front-controller-routing`
2. "Terminate TLS and aggregate three backends at the edge." -> `api-gateway-reverse-proxy`
3. "Choose a token bucket vs sliding window for the API." -> `rate-limiter-throttler`
