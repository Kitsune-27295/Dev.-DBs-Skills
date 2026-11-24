# Isolation, Fixtures, Projects, Authentication and Environments

Sources: https://playwright.dev/docs/browser-contexts · https://playwright.dev/docs/test-fixtures · https://playwright.dev/docs/test-projects · https://playwright.dev/docs/auth · https://playwright.dev/docs/test-parallel · https://playwright.dev/docs/best-practices · Last verified 2026-11-24

Doc version reflected: Playwright docs "stable", newest release listed 1.65 (undated). Note: `https://playwright.dev/docs/test-isolation` returned 404; the isolation material lives on the browser-contexts page.

## Isolation

The test runner creates a fresh BrowserContext (an incognito-like profile with its own cookies, local and session storage) and page per test. Two strategies exist: start every test from scratch, or clean up after. The docs favor starting fresh because cleanup misses things and leaked state makes failures depend on other tests. Benefits stated: order independence, no failure carry-over, easy single-test reproduction, safe parallelism and sharding. A test can open several contexts for multi-user scenarios.

Isolation stops at the browser: server-side data is shared. The parallelism page suggests unique data per test via `testInfo.testId`, unique paths via `testInfo.outputPath()`, and per-worker data via a worker-scoped fixture using `testInfo.workerIndex`. `serial` describe mode exists but the page discourages it.

## Fixtures

Fixtures build only the environment a test needs, are isolated per test, can depend on each other and keep setup and teardown together (code before `use()` is setup, after it teardown). Built-ins: `page`, `context`, `browser`, `browserName`, `request`. Extras: `{ auto: true }` for always-on fixtures, `{ scope: 'worker' }` for once-per-worker, `{ option: true }` for configurable values, `{ box: true }` to hide steps in reports, `mergeTests` to combine modules.

```ts
import { test as base } from '@playwright/test';
export const test = base.extend<{ cart: CartPage }>({
  cart: async ({ page }, use) => {
    const cart = new CartPage(page);
    await use(cart);          // test runs here
    await cart.empty();       // teardown
  },
});
```

## Projects, dependencies, environments

Projects group tests sharing config (browser, device, baseURL, retries, timeout). `--project=<name>` selects one. `dependencies` run first; if a dependency fails, dependents do not run. A project's `teardown` runs after all dependents. Filters (`--grep`, `--shard`, file paths) still pull in dependencies; `--no-deps` skips them. `testMatch`/`testIgnore` split suites (e.g. smoke vs default). Environment split (inference, not stated in one place): make `baseURL` come from an env var per project so the same specs run against local, staging or CI; best practices also says to test against a stable staging environment and stub third parties with `page.route()` + `route.fulfill()`.

## Authentication and storage state

Log in once, save the browser state, reuse it: the state holds cookies, local storage and passkey sessions (IndexedDB only with `indexedDB: true`). Docs recommend saving it under `playwright/.auth` and adding that directory to `.gitignore`, because the file can hold cookies and headers that could impersonate the user. Patterns: (1) a `setup` project writes the file and other projects depend on it and set `storageState`; (2) worker-scoped fixture with one account per worker (`testInfo.parallelIndex`) when tests mutate shared server state; (3) API login through `request` then `request.storageState()`; (4) several roles via several state files; (5) reset with `test.use({ storageState: { cookies: [], origins: [] } })`. Session storage is not persisted by Playwright; UI mode does not run setup projects automatically.

```ts
// playwright.config.ts (excerpt)
projects: [
  { name: 'setup', testMatch: /.*\.setup\.ts/ },
  { name: 'chromium', dependencies: ['setup'],
    use: { storageState: 'playwright/.auth/user.json' } },
],
```

## How an agent should apply this

- Apply ISO, FIX, MOCK and AUTH (registry) with the mechanics above; avoid `serial` unless the user insists.
- Put login in a setup project or worker fixture; add `playwright/.auth/` to `.gitignore` before the first state file exists.
- Use the `request` fixture for fast setup instead of UI clicks (LEVEL).
- Run `--project` per environment (ENV decides which targets are allowed).
- Remember dependencies re-run with filters; use `--no-deps` only when the stored state is known valid.
