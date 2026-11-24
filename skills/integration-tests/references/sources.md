# Sources — Integration tests

Every source below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed to SKILL.md |
|---|---|---|
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk, chapter "Testes de integração: a garantia do seu projeto" (24:07 to about 31:40, including the run-order summary from about 30:07) | Page 200 OK; transcript read in full (local export) | Unit vs end-to-end vs integration comparison, behavior sentences in `describe` / `it`, the duplicate-webhook example, same-engine local test database, never production, run the tests after every AI change, the "AI bypasses or deletes tests" warning, the golden rule |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "5. Teste de integração" and its prompt | Page 200 OK; handout read in full (local export) | The eight-step prompt (flows, sentence groups a to e, human confirms sentences, separate test database, mock only external services, concurrent cases, optional single E2E smoke test, single run command), the illustrative Vitest example |
| Vitest guide, https://vitest.dev/guide/ | 200 OK; read via WebFetch (summary) | Confirms Vitest is a Vite-based test runner, installed as a dev dependency, test files named `*.test.*` or `*.spec.*`, `vitest run` for a single run, requires Node 22.12+ and Vite 6.4+ at the time of reading |
| Playwright, https://playwright.dev/ | 200 OK; read via WebFetch (summary) | Confirms Playwright is a browser-automation framework (Chromium, Firefox, WebKit; auto-wait; trace viewer; TypeScript, Python, .NET, Java), which fits its role as the end-to-end option |

## Claims and caveats

- The video says Kent Beck is "the creator of BDD" and says he warned that AI agents bypass or delete tests. Kent Beck is generally associated with TDD and Extreme Programming; BDD is usually credited to Dan North. Treat the attribution as the video's claim; SKILL.md does not repeat it. The warning itself is the speaker's observation from experience.
- The video says the end-to-end option is exemplified by Cypress; the handout names Playwright. SKILL.md names both; fine.
- The video's "run `npm run dev`" for running tests appears to be a slip in the transcript (elsewhere it says `npm test`); SKILL.md uses "the single command that runs all tests". Not a conflict.
- The Vitest page, as fetched, uses `test` and `expect` in its example and does not document `describe`/`it`, concurrency (`test.concurrent`) or integration testing. SKILL.md's example uses `describe`/`it` and `Promise.all`; the handout calls it illustrative. This is a documented-elsewhere API, not confirmed by that page.
- The Playwright home page does not mention API-level (request) testing; SKILL.md only recommends Playwright for an optional smoke test, which is consistent.
- The video's claim that integration tests are "the only test needed" is opinion; `testing-pyramid-and-shapes` in this repository offers the broader view.
