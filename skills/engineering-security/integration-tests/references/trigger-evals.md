# Trigger evals — integration-tests

Should trigger (expected skill: `integration-tests`):
1. "My app has zero tests and we take payments. Where do I start?"
2. "Cover signup, login and the payment webhook with tests against a real Postgres, not mocks."
3. "The AI agent keeps deleting failing tests to get green. What is the rule?"

Near misses (expected skill in brackets):
1. "Build this discount feature test-first, red-green-refactor." [`tdd`]
2. "Our checkout browser test passes locally and fails on CI shards." [`ci-test-reliability`, or `playwright-qa-orchestrator` for locators and traces]
3. "Should we follow the pyramid, trophy or honeycomb?" [`testing-pyramid-and-shapes`]

Last verified 2026-11-27 (reasoned against the description; not run on a host).
