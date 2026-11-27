# Sources — Integration tests

Every URL below was re-fetched on 2026-11-27 unless a row says otherwise (first authored 2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "5. Teste de integração" | 200 OK, 2026-11-27 (summarizing fetch) | The eight-step prompt (flows, sentence groups, human confirms sentences, separate test database, mock only external services, simultaneous cases, optional single E2E smoke test, one run command), "never point at production", failing real-bug tests stay red on a bug list |
| Video "Fundamentos de Engenharia de Software para Vibe Coders", channel "mano deyvin", published 2026-10-27, https://www.youtube.com/watch?v=G8SeOH0qerk, chapter 24:07 to about 31:40 | Not re-fetched 2026-11-27 (no transcript tool); content read 2026-11-24 from a local export | Unit vs end-to-end vs integration comparison, the duplicate-webhook example, same-engine local database, run tests after every AI change, the warning that agents bypass or delete tests |
| https://api-security.owasp.org/editions/2023/en/0xa1-broken-object-level-authorization | 200 OK, 2026-11-27 | BOLA; "write tests to evaluate the authorization mechanism, do not deploy changes that make the tests fail"; unpredictable ids as an extra, not a substitute |
| https://www.postgresql.org/docs/current/ddl-rowsecurity.html | 200 OK, 2026-11-27 | Superusers and BYPASSRLS roles always bypass RLS; owners normally do; FORCE ROW LEVEL SECURITY subjects owners to policies |
| https://martinfowler.com/bliki/PresentationDomainDataLayering.html | 200 OK, 2026-11-27 | Layer seams help testing; doubles around the data layer make domain tests fast (implied, not stated as "without a database") |
| https://vitest.dev/guide/ | 200 OK, 2026-11-27 | `npm install -D vitest`, `.test.`/`.spec.` naming, `vitest run`, Node 22.12+ and Vite 6.4+, `bun run test` caveat |
| https://playwright.dev/ | 200 OK, 2026-11-27 | One API for three browser engines, auto-wait, trace viewer: fits the optional E2E smoke test |
| https://martinfowler.com/articles/practical-test-pyramid.html | 200 OK, 2026-11-27 | In-memory database of another type is risky; supports the same-engine rule |
| Internal project skill, read for method only; no text, names or figures reused | read locally 2026-11-24, not re-read | The negative tenant test and the logic-in-the-wrong-layer heuristic |

## Reading limits

- Pages were read through summarizing fetches, not raw HTML; wording-sensitive points are paraphrased.
- The video was not re-read; points that only the video makes are labeled as such in the references.
- No scripts, SQL or data files are in this skill; none were run.

## Claims not adopted as fact

- The video calls Kent Beck "the creator of BDD" and says he warned that agents bypass tests. BDD is usually credited to Dan North; the body does not repeat the attribution.
- The video's "integration tests are the only test needed" is opinion; the broader view is `testing-pyramid-and-shapes`.
- The handout's claim that agents prefer unit tests because they mock everything is the author's observation, not measured.
- The Vitest page does not document `describe`/`it`, `test.concurrent` or integration setups; the example in SKILL.md is illustrative and runner-agnostic.
- The video's "run `npm run dev`" for tests looks like a slip; SKILL.md says "the single command that runs all tests".
