# Trigger Evals

Last verified 2026-11-27. Starting-point set (3 + 3), not a scored run.

| Prompt | Expected skill |
|---|---|
| "New SaaS, two developers, unclear domain. Should we start with microservices?" | `monolithic-architecture` |
| "Our single container falls over when users hit one page; do we split the app now?" | `monolithic-architecture` |
| "How do we keep sessions and uploads off local disk so we can run 4 replicas?" | `monolithic-architecture` |
| "Enforce module boundaries and separate schemas inside one deployable." | `modular-monolith-architecture` |
| "We have 12 teams blocked by shared deploys; what must exist before extracting services?" | `microservices-architecture` |
| "How long should a throwaway MVP architecture live, and when to rewrite?" | `yagni-evolutionary-architecture` |
