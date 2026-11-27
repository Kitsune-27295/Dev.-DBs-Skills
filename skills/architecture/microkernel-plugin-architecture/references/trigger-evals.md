# Trigger evals: microkernel-plugin-architecture

Last verified 2026-11-27. Starting-point prompts, not a measured trigger rate.

## Should trigger

1. "We're building a CI runner where customers write their own steps. How should the core and extensions be structured?"
2. "Our payroll engine has a tax-rule if/else per country and customers want their own rules without forking."
3. "Do third-party extensions to our editor need a subprocess sandbox, or is in-process fine?"

## Near misses (expected skill)

1. "Swap our Postgres adapter for an in-memory one behind a port." -> `hexagonal-architecture`
2. "We have two pricing variants that never change; how do we model them?" -> a plain Strategy, no plug-in system (this skill's skip rule)
3. "Retry and circuit-breaker settings for an HTTP client." -> `circuit-breaker-retry-telemetry`
