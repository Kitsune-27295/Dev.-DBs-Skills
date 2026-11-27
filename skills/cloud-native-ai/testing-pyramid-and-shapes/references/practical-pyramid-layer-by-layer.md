# The Practical Test Pyramid, Layer by Layer

Sources: https://martinfowler.com/articles/practical-test-pyramid.html · Last verified 2026-11-23

## Contents
- Principle and naming caveat
- Unit tests
- Integration tests
- Contract tests (consumer-driven)
- UI, end-to-end, acceptance, exploratory
- How an agent should apply this

## Principle
Group tests by granularity: many fast tests at the bottom, fewer broad ones above, very few end-to-end at the top. The inverse (ice-cream cone) is slow and brittle. Layer names (unit/service/UI) are loose; teams may rename them if they stay consistent. "Integration", "component" and "service" tests have no settled meaning, so agree on scope locally.

## Unit tests
- A "unit" varies: a function in functional code, a class or method in OO. Sociable tests use real collaborators; solitary tests stub all of them. Use either, chosen for confidence.
- Stubs return canned answers; mocks verify interactions. Different tools.
- Must be fast: no DB, filesystem or HTTP; thousands should finish in minutes.
- Test the public interface, roughly one test class per production class. Needing to test a private method signals too many responsibilities: extract a class.
- Assert observable behavior (input -> output), not call sequences; skip trivial getters/setters and branch-free code.
- Structure: Arrange-Act-Assert or Given-When-Then.
- Framework wrinkle: a controller unit-tested by plain method call misses routing, annotations and binding; use the framework's mock-MVC style test.

```python
def test_unknown_person_returns_fallback():
    repo = StubRepo(find=lambda name: None)          # stub, not mock
    assert Greeter(repo).hello("Pan") == "Who is this 'Pan'?"
```

## Integration tests
Check one external integration point at a time (DB, filesystem, other service) with the rest doubled. Required wherever data is serialized or deserialized: REST calls, DB access, queues, file I/O. Run real dependencies locally or a dedicated test instance, never production. Use the production database type where feasible: the source warns that an in-memory substitute of a different engine carries risk. For outbound HTTP, stub the remote with a local stub server and point the client's base URL config at it. Limitation: the stub can drift from the real service, which is why contract tests exist.

## Consumer-driven contract tests
Problem: handing a spec over the fence plus a big manual system test is slow and fragile. CDC flips it: the consumer writes tests stating what it needs; these are published as a contract file; the provider replays them in its own pipeline; a failure starts a conversation between teams, and the provider builds only what is consumed. Mechanics with Pact: consumer test emits a pact file; provider test loads it and implements each named "state"; provider names and state strings must match exactly. Share pacts via version control first, an artifact store or broker later. For a given client use a consumer test **or** an integration test, not both.

## UI, end-to-end, acceptance, exploratory
- "UI" includes REST APIs and CLIs. SPAs: unit-level JS test tools; server-rendered: browser automation; layout regressions: screenshot comparison; usability cannot be automated (exploratory, hallway tests, demos). UI testing is not the same as end-to-end testing.
- **End-to-end:** whole deployed system, max confidence, max cost, flaky (timing, animation, popups). In microservices nobody owns cross-service E2E and a central QA team is an anti-pattern. Keep to a few journeys (search, basket, checkout). A "subcutaneous" API-level variant skips the browser.
- **Acceptance:** black-box, user perspective, given/when/then; can live at any layer, prefer the lowest that proves it. Pick one of "functional" or "acceptance" and stick to it.
- **Exploratory:** scheduled, destructive, creative manual sessions; automate each finding as a regression test; escaped bugs are feedback on the pipeline.

## How an agent should apply this
- Classify each proposed test by integration point crossed, then place it at the lowest layer that can catch the bug.
- Unit tests: no I/O, assert outputs, refuse tests of private methods (suggest extraction).
- Add an integration test for every serialization or persistence boundary, against the real engine type.
- Between teams, propose consumer-driven contracts instead of a shared E2E environment.
- Cap E2E at a handful of critical journeys and track their flake rate.
