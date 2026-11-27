# Stack Adapters

Sources: https://playwright.dev/docs/test-webserver · https://playwright.dev/docs/api-testing · https://playwright.dev/docs/auth · Last verified 2026-11-27

The browser side of an E2E suite is the same for every web app. What differs per stack is five things: how the app starts, how data is reset, how a test logs in, where the base URL comes from, and which backend hook is fast enough for setup. Those answers go in the Playwright config and one fixtures file, not in each test. Rules ENV, AUTH, ISO and LEVEL apply unchanged. Stack-specific recipes (per-framework commands, seed tools, typical flaky causes) were not verified against a source and are deliberately not listed; derive them from the project's own files during discovery.

## 1. Universal adapter table

Fill one row per project during discovery (`project-discovery-checklist.md`). A cell you cannot fill from a file or a live check is "unknown".

| Question | What to find | Where it usually lives |
|---|---|---|
| Start command | The command that serves the app for tests, and its readiness URL | package scripts, Makefile, Procfile, compose file, CI workflow |
| Server ownership | Does the test config start it, or is it already running or deployed? | Playwright config, CI workflow |
| Base URL | Env var name and local default | config, `.env.example` |
| Seed or reset | A command, endpoint or fixture that creates known data and removes it | seed scripts, migrations, factories, admin API |
| Login | Form, token endpoint, SSO, test-only login route | auth module, README |
| Fast setup hook | API route, CLI command or DB fixture usable from a fixture | API docs, routes file |
| Third parties | Payment, email, OAuth, analytics to stub (MOCK) | env config, integration code |
| Safe target | Local or staging URL the user confirmed (ENV) | the user |

## 2. Starting the server from the config

The `webServer` option (docs page re-read 2026-11-27) takes `command`, `url` (polled until ready; `port` is deprecated in its favor), `reuseExistingServer`, `timeout` (default 60000 ms), `cwd`, `env`, `stdout`/`stderr`, `gracefulShutdown` and others, and accepts an array to launch several processes. Keep `baseURL` under `use` aligned with the server `url`.

```ts
// playwright.config.ts (excerpt, stack-neutral)
use: { baseURL: process.env.BASE_URL ?? 'http://localhost:3000' },
webServer: process.env.BASE_URL ? undefined : {
  command: process.env.APP_START_CMD!,   // from discovery, never guessed
  url: 'http://localhost:3000',
  reuseExistingServer: !process.env.CI,
},
```

## 3. Reading the table

- Never run a seed or reset command against anything but a local or staging database the user named (ENV): a reset is a destructive write.
- If a stack has a test-only login route or seed endpoint, verify it is disabled in production before relying on it and say so in the report; do not add one to application code in Test mode.
- For a stack with no known pattern, fill the universal rows from discovery and report any suspected flaky causes as hypotheses.

## How an agent should apply this

- Fill the table from files first; ask once, with the full list of unknowns.
- Prefer the API setup hook over UI clicks for data (LEVEL) and keep it in a fixture (FIX).
- Start the server through the config when a start command is known; otherwise ask which running target to use.
- Record verified stack facts in the report so the next session need not rediscover them.
