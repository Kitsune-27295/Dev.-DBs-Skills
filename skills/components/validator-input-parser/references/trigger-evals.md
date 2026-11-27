# Trigger Evals: validator-input-parser

Last verified 2026-11-27. Hand-written prompts; not run against a host.

## Should trigger
1. "Our signup endpoint throws on the first bad field. Make it return every problem in one response." -> this skill
2. "Review this webhook handler: where should size limits, unknown-field handling and regex checks go?" -> this skill
3. "Password reset links are built from the request Host header; is that a problem and how do we fix it?" -> this skill

## Near-miss (belongs to a neighbor)
1. "Model Email and Quantity as types so illegal states cannot be constructed." -> `defensive-domain-modeling`
2. "Define the JSON shape and status code for validation failures across all services." -> `error-handling-problem-details`
3. "Which cookie flags and session timeouts should login use?" -> `authn-authz-guard`
