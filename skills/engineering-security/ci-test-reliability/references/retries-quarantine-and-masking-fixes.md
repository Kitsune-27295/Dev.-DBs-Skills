# Retries, Quarantine and Masking Fixes

Sources: https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html · https://martinfowler.com/articles/nonDeterminism.html · https://vitest.dev/config/retry · https://nodejs.org/api/test.html · Last verified 2026-11-27

## Why retries feel good and are dangerous

Google's 2016 post defines a flaky result as a test that shows both pass and fail on the same code. Their figures: about 1.5% of test runs flaky, almost 16% of tests with some flakiness, and about 84% of observed pass-to-fail transitions involving a flaky test (as reported by the authors, for their corpus; do not treat these as universal rates). Two lessons carry over: people learn to ignore alarms with a history of false positives, and mitigation tools can themselves hide problems.

Fowler's reasoning is the same from another angle: when a test goes red and non-determinism is common, the team shrugs, the test stops carrying information, and a few non-deterministic tests make the whole suite fail often enough that attention to failures erodes.

## Retry mechanics in the tools

- **Vitest** `retry` defaults to 0; it accepts a number or an object with `count`, `delay` and `condition` (a regular expression tested against the error message, or a function given in the test file; the object form is documented as available from 4.1.0). It can be set per test or suite in the file.
- **Google's approach** (read from the 2016 post): re-run only failing tests, automatically re-run on failure, and a "flaky" marker that reports failure only after three consecutive failures. The authors note the cost: a 15-minute integration test marked flaky and broken by a change is not discovered until three runs complete (45 minutes), and developers are encouraged to ignore flakiness in their own tests.
- **Node's test runner** documents an experimental tag filter (`--experimental-test-tag-filter`, for example `not flaky`), which is a mechanism for a separate lane rather than a retry. It is marked Stability 1.0 (early development; added v26.2.0), so check the Node version in use before relying on it.

## When a retry is acceptable

| Use | Condition |
|---|---|
| Measure a flake rate | Run N times on purpose and record pass count; the retry is the instrument |
| Documented transient external boundary | A real third-party API, with a `condition` matching only the transient error class (for example a connection reset), a low count, and a note naming the boundary |
| Short bridge during a fix | Owner, ticket and an expiry date; removed with the fix |

Never: a global `retry: N` for the whole suite; retries on deterministic local tests; a retry that makes red-then-green count as a clean pass in reports.

## Quarantine policy

Fowler's advice, summarized: keep non-deterministic tests in a separate suite so healthy tests keep giving clear feedback; do not abandon the quarantined tests because they are no longer protecting regression coverage; prevent them rotting there with a numeric cap (his example: eight tests) or a time limit (his example: a week). A strong team may run the quarantine suite one pipeline stage after the healthy suite to keep pressure on, but he advises most teams to keep it out of the main pipeline. Google's automated quarantine removes a too-flaky test from the critical path and files a bug, and the authors warn it can mask a real race condition in the code under test.

Quarantine record (own template): test id, first-seen date, failure signature, suspected category, owner, ticket, expiry date, how to reproduce.

Rules for the agent:

1. Quarantine only a test with evidence of non-determinism (both outcomes on the same code); a consistent failure is a real failure.
2. Before parking, read the failure: if it could be a product race, route it to `race-condition-fix`.
3. The quarantine suite still runs on a schedule and reports; expiry triggers fix-or-delete with written reasoning.
4. Do not bypass the golden rule in `integration-tests` (no deleting, skipping or loosening to get green).

## The masking list, with the reasoning

| Masking change | What it hides |
|---|---|
| Longer timeout without naming the awaited state | The race remains; failures move to slower hosts |
| Sleep before assert or cleanup | Same race, slower suite (Fowler's two bites) |
| Blanket retries | Failure rate and cause |
| Serializing everything | Missing resource allocation; permanent time cost |
| Swallowing errors or unhandled rejections | The only evidence |
| Weakening or removing assertions | The behavior under test |
| Normalizing unstable output | Real variation in product behavior |
| `--forceExit` or killing the runner | Leaked handles |
| Re-running the pipeline until green | Everything, and teaches the team to ignore red |
| Quarantine with no owner or expiry | The test, permanently |

Not masking: restoring a budget the lane already granted; sizing a bounded retry to contention you measured; serializing a single proven shared resource with a comment saying what it protects.

## How an agent should apply this

- Treat any request to "just retry" or "skip it for now" as a prompt to classify: deterministic failure, non-deterministic test, external boundary, or product race.
- Use retries only for measurement or a documented external boundary, with a narrow condition and a visible report.
- Quarantine with owner, ticket and expiry; keep the quarantined suite running and counted.
- Reject any fix that appears in the masking table unless the report states what awaited state or resource it addresses.
- When reporting, show first-pass results separately from post-retry results.
