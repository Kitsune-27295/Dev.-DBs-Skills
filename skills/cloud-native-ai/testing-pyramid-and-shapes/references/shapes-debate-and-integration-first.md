# Test Shapes Debate and the Integration-First View

Sources: https://martinfowler.com/articles/2021-test-shapes.html (dated 2021-06-02) · https://kentcdodds.com/blog/write-tests (page byline 2019-07-13; quotes a 2016-12-10 post by Guillermo Rauch) · https://engineering.atspotify.com/2018/01/testing-of-microservices (2018-01-11) · Last verified 2026-11-27

## Contents
- Why the terms are murky
- What the shapes actually disagree about
- Dodds's trophy reasoning
- Coverage and mocking guidance
- Unread source
- How an agent should apply this

## Why the terms are murky
Fowler (2021) notes "unit test" and "integration test" never had crisp definitions. Originally a unit test checked a team's own code in isolation and an integration test checked it against separately built code. Kent Beck used "unit test" for any test programmers wrote (as opposed to a QA team's), often with real collaborators. Jay Fields named the two styles: **solitary** (collaborators replaced by doubles) and **sociable** (real collaborators), matching the mockist and classicist schools.

## What the shapes disagree about
Pyramid: many unit tests. Honeycomb and trophy: fewer unit tests, more integration tests. Fowler's reading: honeycomb advocates' "unit test" matches his solitary tests, which makes the pyramid-versus-honeycomb argument moot; unclear terminology is his second biggest issue. His biggest is Searls's point: debating percentages per test type is a distraction; aim for tests with clear boundaries that run quickly and reliably. Rule: when someone argues for a shape, ask what they mean by each term. Note: Fowler's text does not name the creator of either picture it shows; the honeycomb comes from the Spotify engineering post, which proposes integration tests as the bulk, implementation-detail tests in smaller numbers, and integrated tests (pass or fail on another system's correctness) in the fewest numbers, ideally none.

## Dodds's trophy reasoning
His headline, attributed to Guillermo Rauch: "Write tests. Not too many. Mostly integration."
- Going up levels, each test buys more confidence but costs more time and money; integration tests are the best balance, so most effort goes there (not all).
- Static analysis (types, linting) is the base of the trophy: cheap, but cannot verify business logic.
- Components can each work and still break together (a missing required prop), which isolated tests miss.
- **Mock less** is the practical route to more integration tests; unavoidable mocks include sending real email or charging real cards. In React this means avoiding shallow rendering.
- Do not test implementation details: little confidence, makes refactors expensive; good tests rarely change on refactor.
- Coverage: the article calls mandating 100% a bad idea and says returns diminish "much beyond 70%" (the author admits he made the number up; his own open source projects often sit at 100%).
- Context note: his argument is tied to modern front-end tooling making integration tests cheap; it is not a universal statement for every architecture.

| Shape | Weight | Best fit (this skill's mapping) |
|---|---|---|
| Pyramid | unit-heavy | rich domain logic, engines |
| Trophy | integration-heavy over static base | SPAs, full-stack apps |
| Honeycomb | integration and contract between services | microservice fleets |

## Unread source
A Medium article ("The Test Pyramid Is Outdated") returned HTTP 403 on both fetch attempts (2026-11-22 and 2026-11-27) and is not used as evidence. Choosing the next test from incident history is this skill's own suggestion.

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
