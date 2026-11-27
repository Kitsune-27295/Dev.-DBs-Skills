# Trigger evals — bff-pattern

Last verified 2026-11-27. Hand-written prompts; not run against a host.

Should trigger (expected skill: `bff-pattern`):
1. "Our iOS, Android and web apps all hit one REST backend and every release waits on the platform team. Should we split it?"
2. "How many BFFs should we run if one mobile team builds the same app for both platforms?"
3. "Write a route that takes the orders payload from our backend and returns only what the order screen shows."

Near-miss (expected skill in brackets):
1. "Put TLS termination, JWT validation and throttling in front of all our services." [`api-gateway-reverse-proxy`]
2. "Route /v1 and /v2 traffic to different service versions with a canary." [`router-front-controller-routing`]
3. "Add retries with jitter and a circuit breaker around our downstream calls." [`circuit-breaker-retry-telemetry`]
