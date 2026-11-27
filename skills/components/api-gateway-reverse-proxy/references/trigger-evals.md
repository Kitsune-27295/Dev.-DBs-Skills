# Trigger evals — api-gateway-reverse-proxy

Last verified 2026-11-27. Hand-written prompts; not run against a host.

Should trigger (expected skill: `api-gateway-reverse-proxy`):
1. "We terminate TLS at an nginx in front of five services. What should the proxy do, and what should stay in the services?"
2. "Our custom proxy returns 500 whenever the backend is slow, and it retries POSTs. What should it return and retry?"
3. "Backends see the proxy's IP instead of the client's. How do we pass the client context safely?"

Near-miss (expected skill in brackets):
1. "Mobile and web need different payloads from the same services; who should own the API?" [`bff-pattern`]
2. "Route /orders/* to the orders service and send unmatched messages to a dead-letter channel." [`router-front-controller-routing`]
3. "Pick a token bucket or a sliding window for per-user limits." [`rate-limiter-throttler`]
