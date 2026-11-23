# Avoiding Duplication, Pipeline Placement and Test Code Hygiene

Sources: https://martinfowler.com/articles/practical-test-pyramid.html · https://kentcdodds.com/blog/write-tests · Last verified 2026-11-23

## Contents
- Two rules against duplication
- Pipeline placement
- Writing clean test code
- Failure signals and responses
- How an agent should apply this

## Two rules against duplication
Fowler/Vocke give a compact policy for a growing suite:
1. If a high-level test fails and no lower-level test fails, write the lower-level test.
2. Push each test as far down the pyramid as it can go while still proving the behaviour.

Pruning follows: delete high-level tests whose coverage is already provided below, and resist the sunk-cost fallacy about the effort spent on them. A related choice for clients of other services: use a consumer contract test or an integration test for the same client, not both.

## Pipeline placement
Order pipeline stages by speed and scope, not by test label. Fast, narrow integration tests (in-memory or local DB) can run with unit tests in the first stage to shorten feedback; slow, broad ones (deployed E2E, browser) come later. The source notes terminology varies, so name pipeline stages by what they do ("fast checks", "deployed smoke") rather than by "integration".

```
stage 1 (<2 min): static analysis + unit + narrow integration
stage 2: contract verification + component tests
stage 3: deployed smoke of 3-5 journeys
nightly: exploratory findings turned into regression tests
```

## Writing clean test code
- Treat tests as production code: one condition per test, a readable name, Arrange-Act-Assert or Given-When-Then.
- Favour readability (DAMP) over strict DRY; apply the Rule of Three before extracting shared helpers.
- Assert behaviour, not internals (shared with Dodds: tests coupled to implementation details make refactoring costly).
- Keep third-party mocks minimal; each mock removes confidence in the real connection.

## Failure signals and responses
| Signal | Likely cause | Response |
|---|---|---|
| Refactor breaks many tests, behaviour unchanged | tests pinned to internals | rewrite against public behaviour |
| E2E suite slow or flaky | too many top-level tests; timing, animation, popups | move assertions down, keep a few journeys |
| Stub-based tests pass, prod integration fails | stub drift | add contract or real-dependency integration test |
| Bug escapes to production | gap in pipeline | add lowest-layer regression test, record as pipeline feedback |
| 100% coverage mandate, brittle suite | coverage as target | drop the number, target risk areas |

## How an agent should apply this
- When adding a regression test for a bug, first locate the lowest layer that reproduces it, and add it there.
- Before adding an E2E test, check whether an API-level or lower test proves the same thing; if so, skip or delete the E2E.
- Propose a staged pipeline where the first stage includes fast integration tests.
- Review tests for DAMP readability and single-condition focus; avoid premature shared fixtures.
- Report flake rate and runtime per layer as the metrics that justify moving tests.
