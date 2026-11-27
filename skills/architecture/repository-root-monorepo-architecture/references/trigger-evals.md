# Trigger evals: repository-root-monorepo-architecture

Last verified 2026-11-27

## Should trigger
1. "Should this new Go CLI start with cmd/ and pkg/ or stay flat?" - this skill.
2. "We have 6 services in separate repos and keep breaking shared contracts; monorepo or not?" - this skill.
3. "Set up apps/ and packages/ with CODEOWNERS and CI that only runs affected tests." - this skill.

## Near-misses
1. "Rename src/ folders so they show it is a billing system." - `screaming-architecture`.
2. "Reorganize controllers/services/repositories inside our API." - `package-by-feature-component`.
3. "Enforce module boundaries and schema isolation inside one deployable." - `modular-monolith-architecture`.
