# Trigger evals: screaming-architecture

Last verified 2026-11-27

## Should trigger
1. "Looking at src/, you can't tell this is a clinic app, only that it's Next.js. How should we rename things?" - this skill.
2. "Review our folder names and use-case classes: do they say what the business does?" - this skill.
3. "Our rails new tree holds all the rules in controllers; make the repo reflect the domain." - this skill.

## Near-misses
1. "Domain code imports the ORM; enforce the dependency rule." - `clean-architecture`.
2. "Replace controllers/services/repositories with feature or component packaging." - `package-by-feature-component`.
3. "Flat layout vs cmd/ and internal/ for a Go module." - `repository-root-monorepo-architecture`.
