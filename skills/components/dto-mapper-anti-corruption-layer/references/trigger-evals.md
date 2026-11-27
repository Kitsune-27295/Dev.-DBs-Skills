# Trigger Evals: dto-mapper-anti-corruption-layer

Last verified 2026-11-27. Hand-written prompts; not run against a host.

## Should trigger
1. "Our REST controller returns the ORM entity directly; design proper response shapes and where the conversion code should live." -> this skill
2. "We are replacing a legacy billing system in stages and must keep calling it. How do we stop its field names and codes spreading into our domain?" -> this skill
3. "Our auto-mapper silently drops a renamed field; how do we make mapping safe?" -> this skill

## Near-miss (belongs to a neighbor)
1. "What checks should run on this request body before we parse it (size, allowlist, regex)?" -> `validator-input-parser`
2. "What should the 422 error body look like?" -> `error-handling-problem-details`
3. "Should this repository commit several aggregates in one transaction?" -> `repository-unit-of-work`
