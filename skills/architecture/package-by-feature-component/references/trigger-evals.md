# Trigger evals: package-by-feature-component

Last verified 2026-11-27

## Should trigger
1. "Our repo has controllers/, services/, repositories/ and every ticket touches all three. How do we reorganize?" - this skill.
2. "Should we use feature folders or one component per business capability in our .NET API?" - this skill.
3. "Make repositories internal so other modules cannot bypass the service; how do I enforce it?" - this skill.

## Near-misses
1. "One file per request with CQRS handlers and no shared services." - `vertical-slice-architecture`.
2. "Rename top-level folders so the repo screams that it is a clinic system." - `screaming-architecture`.
3. "Set up apps/ and packages/ with CODEOWNERS for a monorepo." - `repository-root-monorepo-architecture`.
