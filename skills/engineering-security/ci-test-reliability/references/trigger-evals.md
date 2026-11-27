# Trigger evals

Last verified 2026-11-27. Starting points for tuning the description, not laws.

Should trigger:
1. "Our CI fails about one run in ten on a port-in-use error, but never locally." -> `ci-test-reliability`
2. "Tests pass alone but fail with `--shard` and four workers; they share a temp folder." -> `ci-test-reliability`
3. "Should I add `retry: 3` to the Vitest config so the build goes green?" -> `ci-test-reliability`

Near-misses:
1. "Which tests should I write for this new service: unit, integration or end to end?" -> `testing-pyramid-and-shapes`
2. "Playwright test needs traces and a retry policy for a flaky locator." -> `playwright-qa-orchestrator`
3. "Two requests update the same order row at once and one write is lost." -> `race-condition-fix`
