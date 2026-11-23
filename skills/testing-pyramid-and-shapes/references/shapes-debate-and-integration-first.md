# Test Shapes Debate and the Integration-First View

Sources: https://martinfowler.com/articles/2021-test-shapes.html · https://kentcdodds.com/blog/write-tests · https://medium.com/@tonainagarg/the-test-pyramid-is-outdated-heres-what-replaced-it-f9795e5f2615 (NOT readable: HTTP 403 via WebFetch; curl fallback was blocked) · Last verified 2026-11-23

## Contents
- Why the terms are murky
- What the shapes actually disagree about
- Dodds's trophy reasoning
- Coverage and mocking guidance
- Unread source: Medium article
- How an agent should apply this

## Why the terms are murky
Fowler (2021) notes "unit test" and "integration test" never had crisp definitions. Originally a unit test checked a team's own code in isolation and an integration test checked it against separately built code. Kent Beck used "unit test" for any test programmers wrote (as opposed to a QA team's), often with real collaborators. Jay Fields named the two styles: **solitary** (collaborators replaced by doubles) and **sociable** (real collaborators), matching the mockist and classicist schools.

## What the shapes disagree about
Pyramid: many unit tests. Honeycomb and trophy: fewer unit tests, more integration tests. Fowler's reading: honeycomb advocates criticize heavy mocking, so their "unit test" means solitary and their "integration test" effectively means sociable. The disagreement is therefore largely semantic. Rule from the article: when someone argues for a shape, ask what they mean by each term. Searls's point: percentage debates distract; the real failure is tests without clear boundaries that are slow, flaky, or fail for uninteresting reasons.

## Dodds's trophy reasoning
His headline, attributed to Guillermo Rauch: "Write tests. Not too many. Mostly integration."
- Going up levels, each test buys more confidence but costs more time and money; integration tests are the best balance, so most effort goes there (not all).
- Static analysis (types, linting) is the base: cheap, but cannot verify business logic.
- Components can each work and still break together (a missing required prop), which isolated tests miss.
- **Mock less** is the practical route to more integration tests; unavoidable mocks include sending real email or charging real cards. In React this means avoiding shallow rendering.
- Do not test implementation details: little confidence, makes refactors expensive; good tests rarely change on refactor.
- Coverage: mandating 100% is "a really bad idea"; returns diminish somewhere past ~70% (the author admits the number is invented). Chasing it produces trivial and implementation-coupled tests.
- Context note: his argument is tied to modern front-end tooling making integration tests cheap; it is not a universal statement for every architecture.

| Shape | Weight | Best fit (this skill's mapping) |
|---|---|---|
| Pyramid | unit-heavy | rich domain logic, engines |
| Trophy | integration-heavy over static base | SPAs, full-stack apps |
| Honeycomb | integration and contract between services | microservice fleets |

## Unread source
The Medium article ("The Test Pyramid Is Outdated") could not be fetched. Per the existing `references/sources.md`, it argues for integration-heavy and risk-based models and for auditing incident history to target boundary bugs (HTTP contracts, schemas, migrations), with author adoption figures that should be treated as claims. Not read from source in this pass.

```
# incident-driven test placement (own illustration)
for bug in last_90_days_incidents:
    layer = lowest_layer_that_reproduces(bug)      # contract? integration? unit?
    add_regression_test(bug, layer)
```

## How an agent should apply this
- Define "unit" and "integration" explicitly in the repo's test docs before debating ratios.
- Prefer sociable tests over heavy mocking; mock only external effects (email, payments, third-party APIs).
- Assert on behavior users or callers observe; reject tests that pin internals.
- Do not set a blanket coverage target; use incident history to decide where the next test goes.
- Pick the shape from architecture (domain engine, SPA, service fleet), and state the reason.
