# What to test, real database versus mocks, and tooling notes

Sources: video chapter "Testes de integração: a garantia do seu projeto" (24:07-31:40, https://www.youtube.com/watch?v=G8SeOH0qerk); handout section "5. Teste de integração" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software); https://vitest.dev/guide/; https://playwright.dev/ · Last verified 2026-11-24

## Where integration sits

The video places the test between two familiar kinds. A unit test checks one function and replaces database data with fakes. An end-to-end test drives clicks through the screen and breaks for unrelated reasons. The integration test goes through the route, the way the front end talks to the back end, and is neither fine-grained nor click-driven. External parties (a payment gateway sending a webhook) are simulated so the test controls what arrives. The handout adds the reason it favors this: an AI agent likes unit tests because it mocks everything, so they can pass while testing nothing, and end-to-end tests are slow.

## Behavior sentences

The `it` sentence documents the feature in readable words: "when the same event arrives twice, enable the plan once". The human reads and approves the sentences; the AI fills in the body. The video's two sample sentences (same event twice; both copies together) directly test idempotency and concurrency, linking to `idempotency-fix` and `race-condition-fix`.

The handout lists five groups to cover per flow: happy path, expected errors, repetition, limits, improper access. Critical flows named: signup, login, checkout, webhooks, anything touching money, permission or another user's data.

## Real database, not a mock

Rule in both sources: tests run against the same engine as production, locally (the video: a local copy of the backend service, not a different engine such as SQLite standing in), and never against production data. The handout adds that row-level-security tests are only meaningful against a real database. Mock only what is external.

## Tooling facts from the pages read

- Vitest: Vite-powered; install as a dev dependency; files named `*.test.*` or `*.spec.*`; `vitest run` runs once, plain `vitest` watches; the page states Node 22.12+ and Vite 6.4+. The page did not cover `describe`/`it`, concurrency or integration setups; for those, read the project's installed Vitest docs.
- Playwright: cross-browser (Chromium, Firefox, WebKit) with auto-waiting and a trace viewer; the handout allows at most one smoke test (signup to checkout) and only if approved.

Own sketch of a concurrent case: fire both requests with `Promise.all`, then assert on the database state (one subscription row), not on response codes alone.

## Guarding against test tampering

The video warns that an agent may delete, edit or bypass a failing test to get green; the golden rule forbids deleting, skipping or loosening tests, and the speaker prefers not refactoring passing tests. Failing tests caused by real bugs stay red and go to a bug list.

## How an agent should apply this

- Read the project to list flows, write sentences, and stop for human approval before writing bodies.
- Point the test configuration at a separate database; verify the connection string cannot reach production before running.
- Mock only gateways, email and third-party APIs; run rules and policies for real.
- Include a concurrent and a duplicate case for every money or limited-resource flow.
- Report the single command that runs everything and the pass/fail summary.
