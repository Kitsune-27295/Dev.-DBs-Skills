# Trigger Evals

Last verified 2026-11-27. Starting points for a description check, not a measured result.

## Should trigger (this skill)
1. "Add a flag so the new checkout ships dark and I can turn it on for 5 percent of users."
2. "We have 140 flags and nobody knows which are live. How do we retire them safely?"
3. "Wrap LaunchDarkly behind OpenFeature so business code never imports the vendor SDK."

## Near-misses (other skill)
1. "Rename a column without downtime using expand/contract." -> `parallel-change-expand-contract`
2. "Stop calling the payment API automatically after 5 failures." -> `circuit-breaker-retry-telemetry`
3. "Only admins may export invoices; enforce it per request." -> `authn-authz-guard`
