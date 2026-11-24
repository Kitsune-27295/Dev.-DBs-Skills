# Stack Adapters

Sources: general practice unless a row says otherwise. Playwright-side facts (webServer, projects, `request` fixture, storage state) are covered in `isolation-fixtures-auth-and-environments.md` and `ci-reporters-and-test-level-choice.md`; the config key `webServer` itself was not fetched from its own docs page during authoring, so treat its option names as unverified and confirm them against the installed version. Last reviewed 2026-11-24.

The browser side of an E2E suite is the same for every web app. What changes per stack is five things: how the app starts, how data is reset, how a test logs in, where the base URL comes from, and which backend hook is fast enough for setup. This file is the only place for stack-specific advice; the rules in the registry (ENV, AUTH, ISO, LEVEL) apply unchanged.

## 1. Universal adapter table

Fill one row per project during discovery (see `project-discovery-checklist.md`). A cell you cannot fill from a file or a live check is "unknown".

| Question | What to find | Where it usually lives (general practice) |
|---|---|---|
| Start command | The command that serves the app for tests, and its readiness URL | package scripts, Makefile, Procfile, compose file, CI workflow |
| Server ownership | Does the test config start it, or is it already running or deployed? | Playwright config, CI workflow |
| Base URL | Env var name and local default | config, `.env.example` |
| Seed or reset | A command, endpoint or fixture that creates known data and removes it | seed scripts, migrations, factories, admin API |
| Login | Form, token endpoint, SSO, test-only login route | auth module, README |
| Fast setup hook | API route, CLI command or DB fixture usable from a fixture | API docs, routes file |
| Third parties | Payment, email, OAuth, analytics that must be stubbed | env config, integration code (MOCK) |
| Safe target | Local or staging URL the user confirmed | the user (ENV) |

Pattern for every stack: put the answers in the Playwright config and one fixtures file, not in each test.

```ts
// playwright.config.ts (excerpt, stack-neutral; confirm option names for your version)
use: { baseURL: process.env.BASE_URL ?? 'http://localhost:3000' },
webServer: process.env.BASE_URL ? undefined : {
  command: process.env.APP_START_CMD!,   // from discovery, never guessed
  url: 'http://localhost:3000',
  reuseExistingServer: !process.env.CI,
},
```

## 2. Per-stack notes (all general practice, not verified against a source)

| Stack | Start for tests | Seed and reset | Auth fixture | API helper for setup | Typical flaky causes |
|---|---|---|---|---|---|
| Next.js, React SPA, Vite | Production-like build served locally is steadier than the dev server; dev server is acceptable for local runs | Seed through the backend the SPA calls, or a test-only API route; never through the UI | Log in via the API or auth-provider test mode, save storage state once per role | Call the backend endpoints the SPA uses | Hydration not finished when the first click lands; client-side data fetch racing an assertion; dev-server recompilation or HMR overlays; route transitions replacing the element mid-action |
| Node or Express API (with or without a UI) | `node` or `npm start` with a test env file and a dedicated database | Truncate or recreate tables per run; transaction-per-test where the framework allows; unique data per worker | Token endpoint, then reuse the token in `request` or storage state | The API is the helper: test rules with `request`, UI only for journeys | Shared database rows between workers; unawaited async jobs finishing after the assertion; port clashes; rate limits |
| Django, Flask, FastAPI | Management or run command against a test settings module or test database | Fixtures or factories, migrations on a throwaway database; management command for seeding | Session login via a form once and save state, or a token endpoint | Admin or API routes; a test-only management command | Database not reset between workers; background tasks or Celery workers not running in the test environment; CSRF token expiry; template caching |
| Laravel or PHP | `php artisan serve` or the container's web server with a testing environment file | Migrate-fresh plus seeders on a test database; factories | Form login saved as state, or a token route; keep any test-only login route out of production builds | JSON API routes; artisan commands | Queue workers not running or running synchronously in only one environment; session driver differences; asset build not compiled; database not isolated per worker |
| Rails | `rails server` in the test environment | Fixtures or factory seeds, database cleaning between runs | Session login via the form once; token for API-mode apps | JSON endpoints; rake or runner tasks | Async jobs and Turbo or JS-driven updates finishing after the assertion; shared database state; asset pipeline not precompiled |
| .NET | `dotnet run` with a test environment name and a test database | EF migrations on a throwaway database; seed endpoint or script; reset between runs | Cookie login saved as state, or token endpoint; identity provider test mode | Minimal API or controller endpoints | Cold start slow the first request; migrations racing the first test; antiforgery token expiry; background hosted services not started |
| Static or multi-page sites | A static file server on the build output (any simple server) | Usually nothing to seed; content comes from files | Usually none; for gated pages, use the host's preview auth | Not applicable; check links, forms and rendered content in the browser | Third-party scripts (analytics, ads, embeds) loading late or failing; cookie banners covering elements; lazy-loaded images and fonts shifting layout |

## 3. Reading the table

- Never run a seed or reset command against anything but a local or staging database the user named (ENV). A "reset" is a destructive write.
- If a stack has a test-only login route or seed endpoint, verify it is disabled in production before relying on it and say so in the report; do not add one to application code in Test mode.
- When the stack is not in the table, fill the universal rows from discovery and add the stack's flaky causes to the report as hypotheses, not facts.

## How an agent should apply this

- During discovery, fill the universal table from files first; use the per-stack row only as a checklist of where to look, never as a statement about this project.
- Prefer the API setup hook over UI clicks for data (LEVEL) and keep it in a fixture (FIX).
- Start the server through the Playwright config when a start command is known; otherwise ask once which already-running target to use.
- Treat the "typical flaky causes" column as hypotheses to test with trace evidence (FCLASS), not as a diagnosis.
- Record any stack facts you verified in this project in the report so the next session need not rediscover them.
