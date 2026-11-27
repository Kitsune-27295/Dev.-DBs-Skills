# Trigger evals: mvc-architecture

Last verified 2026-11-27. Starting-point prompts, not a measured trigger rate.

## Should trigger

1. "My Rails controller actions are 300 lines of validation and pricing math. How do I clean this up?"
2. "Our Jinja templates run ORM queries and compute discounts. Where should that go?"
3. "How do I make this desktop form testable without launching the UI? Presenter or view model?"

## Near misses (expected skill)

1. "Structure the backend so the domain doesn't depend on Express or the DB." -> `hexagonal-architecture`
2. "Reorganize src/ into feature folders instead of controllers/ and services/." -> `package-by-feature-component`
3. "Split the UI into independently deployed micro frontends." -> `micro-frontends-architecture`
