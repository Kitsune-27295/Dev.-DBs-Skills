# Retries, Flakiness, Traces and Debugging

Sources: https://playwright.dev/docs/test-retries · https://playwright.dev/docs/trace-viewer-intro · https://playwright.dev/docs/api/class-testoptions · https://playwright.dev/docs/best-practices · https://playwright.dev/docs/debug · https://playwright.dev/docs/codegen-intro · https://playwright.dev/docs/test-ui-mode · Last verified 2026-11-27

Doc version reflected: Playwright docs "stable", newest release listed 1.65 (undated).

Owner of rules RETRY and TRACE in `ssot-rule-registry.md`; the failure classes (FCLASS) live in `failure-analysis-and-root-cause-discipline.md` only.

## Retry semantics

Retries are off by default (0). Enable with `--retries=N`, `retries` in config, or `test.describe.configure({ retries })`. Statuses: passed (first attempt), flaky (failed first, passed on a later attempt in the same run), failed (every attempt failed). After a failure the runner discards the worker and starts a fresh one, so `beforeAll` runs again. `testInfo.retry` tells code it is a retry (e.g. to reset server state). In serial groups the whole group retries. The retries page does not cover flaky-run flags, but the CLI page documents `--repeat-each <N>` (run each test N times, default 1) and `--fail-on-flaky-tests`, and the testconfig page lists `failOnFlakyTests` (since 1.52, default not stated).

## Trace recording

`trace` accepts: `off`, `on`, `on-first-retry`, `on-all-retries`, `retain-on-failure`, `retain-on-first-failure`, `retain-on-failure-and-retries` (class-testoptions). The trace-viewer intro's default config uses `trace: 'on-first-retry'` with `retries: process.env.CI ? 2 : 0`; best practices warns that tracing every test (`on`) is performance-heavy and recommends traces on the first retry in CI. Locally use `npx playwright test --trace on`. Traces hold per-step actions with before/after DOM snapshots, log, source, network, errors and console; open them from the HTML report (`npx playwright show-report`).

```ts
// playwright.config.ts (excerpt)
export default defineConfig({
  retries: process.env.CI ? 2 : 0,
  use: { trace: 'on-first-retry', screenshot: 'only-on-failure' },
});
```

## Debugging tools

- `npx playwright test --debug` opens the Inspector, runs headed and removes the default timeout; add `file.spec.ts:10` to focus; `page.pause()` stops at a chosen point.
- `npx playwright test --ui` is UI mode: watch mode, time-travel snapshots, locator picker, filters by project/tag/status. It does not run project setup tests; run them manually.
- `npx playwright codegen <url>` records actions and offers assert-visibility/text/value tools; useful to find candidate locators, not to produce final tests unreviewed.
- `DEBUG=pw:api` prints API logs; `PWDEBUG=console` adds a `playwright` helper object in DevTools.

## Evidence cues that feed classification

Classes and decisions are in `failure-analysis-and-root-cause-discipline.md`. Cues this page's tools add: a flaky label from the runner (failed first, passed on retry), a strict-mode violation or missing await in the log (test side), a trace showing the UI or API really misbehaving (product side), timeouts everywhere or expired auth (environment).

## How an agent should apply this

- Apply RETRY: configure retries as the docs example does and name every flaky test in the report.
- Apply TRACE: use `trace: 'on-first-retry'` (or `retain-on-failure` when retries are 0) and read the trace before editing the test.
- To reproduce a single failing test in isolation, repeat it before and after the fix with `--repeat-each=N`; add `--workers` to expose parallel-only failures.
- Prefer Inspector, UI mode or trace evidence over guesswork when debugging.
- Keep traces and reports out of Git (ARTIFACT).
