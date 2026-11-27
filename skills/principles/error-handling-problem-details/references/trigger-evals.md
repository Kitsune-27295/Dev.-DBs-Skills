# Trigger Evals

Last verified 2026-11-27

Should trigger `error-handling-problem-details`:
1. "What should our API return for validation errors? We currently send a plain string."
2. "Write a global exception handler that doesn't leak stack traces."
3. "Should this use case return a Result or throw? And how do I chain five fallible steps?"

Near misses (expected skill):
1. "Add allowlists and size limits to the incoming request parsing." -> `validator-input-parser`
2. "Retry a flaky upstream with backoff and a circuit breaker." -> `circuit-breaker-retry-telemetry`
3. "Replace boolean flags in our Order model with a union type." -> `defensive-domain-modeling`
