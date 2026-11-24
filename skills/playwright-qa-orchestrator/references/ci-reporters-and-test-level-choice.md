# CI, Workers, Sharding, Reporters and Choosing the Test Level

Sources: https://playwright.dev/docs/ci-intro · https://playwright.dev/docs/test-parallel · https://playwright.dev/docs/test-sharding · https://playwright.dev/docs/test-reporters · https://playwright.dev/docs/api-testing · https://playwright.dev/docs/best-practices · https://playwright.dev/docs/api/class-testconfig · Last verified 2026-11-24

Doc version reflected: Playwright docs "stable", newest release listed 1.65 (undated).

## CI basics

`npm init playwright@latest` can create `.github/workflows/playwright.yml`: checkout, Node, `npm ci`, `npx playwright install --with-deps`, run tests, upload `playwright-report/` (step guarded by `if: ${{ !cancelled() }}`, 30-day retention). The docs suggest a `globalTimeout` (example 60 minutes) in config rather than a job timeout so reporters still emit a report. Best practices: run on every commit/PR, prefer Linux runners, install only needed browsers (`npx playwright install chromium --with-deps`), keep `@playwright/test` current, run `tsc --noEmit` and ESLint with `@typescript-eslint/no-floating-promises`.

## Workers and parallelism

Files run in parallel across worker processes; tests inside a file run in order unless `fullyParallel: true` or describe mode `parallel`. Default workers: half of the logical cores (testconfig page); `--workers=N` or `workers` overrides; the parallelism page's CI example sets 2. `maxFailures`/`--max-failures` stops a run early (default 0, unlimited). Workers cannot talk to each other.

## Sharding and merging

`npx playwright test --shard=2/4` runs a slice. Use the `blob` reporter on CI, upload each shard's blob, then `npx playwright merge-reports --reporter html ./all-blob-reports`. Matrix in GitHub Actions: `shardIndex: [1,2,3,4]`, `shardTotal: [4]`; the merge job should run even if shards fail. With `fullyParallel: true` shards balance per test, otherwise per file.

## Reporters

Built-ins: `list` (local default), `dot` (CI default), `line`, `html` (open default `on-failure`), `json`, `junit`, `github` (annotations), `blob`. Several at once via an array.

```ts
reporter: process.env.CI
  ? [['github'], ['html', { open: 'never' }], ['junit', { outputFile: 'results.xml' }]]
  : 'list',
```

## Choosing the test level (own synthesis, grounded in the API-testing page)

The API-testing page says `request` (APIRequestContext) suits three jobs: testing the server API itself, preparing server state before a UI test, and verifying server state after browser actions. `page.request`/`context.request` share cookies with the browser context; `playwright.request.newContext()` keeps separate cookies.

| Question | Level |
|---|---|
| Business rule, validation, status codes | API test with `request` |
| Needs data to exist before the flow | seed via API in a fixture, then UI |
| Rendering, navigation, accessibility, user journey | UI test |
| Did the UI action really persist? | UI action, then API read |
| Pure logic with no browser | unit test outside Playwright |
| Third-party dependency | stub with `page.route()`; do not test it |

## How an agent should apply this

- This file owns LEVEL: cover rules at the API level, keep UI tests to critical journeys, use API for setup and teardown.
- Scaffold CI with explicit `retries`, `workers`, `trace: 'on-first-retry'` (RETRY, TRACE), `forbidOnly` (inferred best practice: block committed `test.only` on CI) and an uploaded report artifact.
- Shard only when suite time justifies it; use `blob` plus `merge-reports`.
- Use the `github` reporter plus `html` with `open: 'never'` in CI (HEADLESS).
