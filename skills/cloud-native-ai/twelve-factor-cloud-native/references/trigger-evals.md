# Trigger evals: twelve-factor-cloud-native

Last verified 2026-11-27. Mental test set for the description; run it again after any description edit.

## Should trigger

1. "Our Express app keeps carts in memory and breaks when we scale to 3 pods. What should change?" Expected: this skill (VI Processes).
2. "Where should STRIPE_SECRET and a feature-flag default live, and can the frontend read them?" Expected: this skill (variable classification).
3. "Review my Dockerfile and entrypoint for twelve-factor problems; deploys drop requests." Expected: this skill (V, IX, XI).

## Near misses

1. "Add circuit breaker and jittered retries around the payments client." Expected: `circuit-breaker-retry-telemetry`.
2. "Design OAuth login with refresh token rotation." Expected: `authn-authz-guard`.
3. "Scan the repo and its git history for leaked keys." Expected: `security-audit`.
