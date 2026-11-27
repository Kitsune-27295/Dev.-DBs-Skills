# Sources — Playwright QA Orchestrator

Every URL below was re-fetched on 2026-11-27 unless a row says otherwise (first authored 2026-11-24). All fetches were summarizing (WebFetch); Firecrawl was not available.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://playwright.dev/docs/test-agents | 200 OK | init-agents loops (vscode, claude, codex, opencode), planner/generator/healer, `tests/seed.spec.ts`, healer may leave a skipped test, VS Code 1.105 needed; the page's Claude example prints `--loop=vscode` and its layout shows `.github/` |
| https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/generateAgents.ts | 200 OK | Claude loop writes `.claude/agents/<name>.md`, `.mcp.json` with server `playwright-test` (Windows via `cmd /c`), `specs/README.md`, a default seed if none, `.claude/prompts` only when a prompts option is on |
| https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/playwright-test-healer.agent.md | 200 OK | Healer: run suite, debug each failure, one fix at a time, no `networkidle`, no questions to the user, `test.fixme()` when confident the app is wrong, loops until green |
| https://api.github.com/repos/microsoft/playwright/contents/packages/playwright/src/agents | 200 OK | Eleven files incl. planner, generator and healer `.agent.md`, three `.prompt.md` templates, `generateAgents.ts` |
| https://playwright.dev/docs/release-notes | 200 OK; first 100k of about 215k characters read | 1.65 newest listed, no dates; agents introduced in 1.56; `--shuffle` (1.64), `--add-reporter` (1.63) |
| https://playwright.dev/docs/test-cli | 200 OK (added 2026-11-27) | `--repeat-each`, `--fail-on-flaky-tests`, `--max-failures`, `--shard`, `--workers`, `--retries`, `--trace`, `--project`, `--no-deps`, `--last-failed` |
| https://playwright.dev/docs/test-webserver | 200 OK (added) | webServer option names and defaults, array form, baseURL interplay |
| https://playwright.dev/docs/best-practices | 200 OK | Locators, web-first assertions, isolation, stub third parties, trace on first retry not `on`, Linux CI, install needed browsers only, `no-floating-promises` lint, `tsc --noEmit` |
| https://playwright.dev/docs/locators | 200 OK | Locator order, test id attribute, strictness, `filter`, `and`, `or`, `first`/`nth` discouraged |
| https://playwright.dev/docs/test-assertions | 200 OK | Expect timeout 5 s, `expect.poll` 5 s and intervals, `toPass` timeout 0, `expect.soft`, messages, non-retrying matcher list |
| https://playwright.dev/docs/actionability | 200 OK | Checks per action; `force` skips non-essential checks |
| https://playwright.dev/docs/api/class-page (waitForTimeout section, offset 300000) | 200 OK | waitForTimeout marked Discouraged, "added before v1.9" |
| https://playwright.dev/docs/browser-contexts | 200 OK | Fresh context per test, two isolation strategies, benefits, multi-context tests |
| https://playwright.dev/docs/test-isolation | 404 again | Not available; isolation read from browser-contexts |
| https://playwright.dev/docs/test-fixtures | 200 OK | auto, worker scope, option, box, `mergeTests`, setup and teardown around `use()`, built-in fixtures |
| https://playwright.dev/docs/test-projects | 200 OK | dependencies, teardown, filters pull dependencies, `--no-deps`, `testMatch`/`testIgnore` |
| https://playwright.dev/docs/auth | 200 OK | Storage state, `playwright/.auth` ignored in Git, setup project, per-worker accounts, API login, roles, session storage, `indexedDB`, UI mode caveat |
| https://playwright.dev/docs/test-retries | 200 OK | Retry default 0, passed/flaky/failed, worker restart, `testInfo.retry`, serial group retries |
| https://playwright.dev/docs/trace-viewer-intro | 200 OK | `trace: 'on-first-retry'` with `retries: process.env.CI ? 2 : 0`, `--trace on`, trace contents, `show-report`; `show-trace` not covered |
| https://playwright.dev/docs/api/class-testoptions | 200 OK | Seven trace/video modes (default off), screenshot modes, `testIdAttribute` |
| https://playwright.dev/docs/api/class-testconfig | 200 OK | workers half the logical cores, retries 0, timeout 30 s, expect 5 s, `maxFailures` 0, `globalTimeout` 0, `failOnFlakyTests` (since 1.52), reporter default dot on CI else list |
| https://playwright.dev/docs/debug | 200 OK | `--debug` headed and no timeout, `page.pause`, `PWDEBUG=console`, `DEBUG=pw:api` |
| https://playwright.dev/docs/codegen-intro | 200 OK | codegen, assertion tools, locator picker favors role, text, test id |
| https://playwright.dev/docs/test-ui-mode | 200 OK | `--ui`, watch mode, locator picker, setup projects not run |
| https://playwright.dev/docs/ci-intro | 200 OK | Workflow steps, `install --with-deps`, report artifact with `if: !cancelled()` and 30-day retention (`upload-artifact@v5`), `globalTimeout` recommended over job timeout |
| https://playwright.dev/docs/test-sharding | 200 OK | `--shard`, blob reporter, `merge-reports`, matrix, per-test balance with `fullyParallel` |
| https://playwright.dev/docs/test-reporters | 200 OK | Reporters: list, line, dot, failures, html, blob, json, junit, perfetto, github; html `open` values; github reporter discouraged with matrix |
| https://playwright.dev/docs/test-parallel | 200 OK | `fullyParallel`, describe modes, CI `workers: 2` example, `testInfo` isolation helpers, serial not recommended; default worker count not stated here |
| https://playwright.dev/docs/api-testing | 200 OK | Three jobs for `request`, cookie sharing of `page.request` vs `newContext()` |
| https://playwright.dev/docs/getting-started-mcp | 200 OK | MCP install, Claude Code command, snapshots with refs, Node 20+, unsafe code tool, WebMCP tools untrusted |
| https://playwright.dev/agent-cli/introduction | 200 OK | `@playwright/cli`, install command, command groups, snapshot refs, docs claim fewer tokens than MCP (no figures) |
| https://playwright.dev/ | 200 OK | Product overview |
| https://github.com/lackeyjb/playwright-skill | 200 OK; MIT | Visible browser by default (rejected for unattended runs); server detection, env credentials |
| https://github.com/currents-dev/playwright-best-practices-skill | 200 OK; MIT | 57 reference documents; README shows an install command with the full repo URL; flaky-tests page: four flakiness families, decision tree, retries for diagnosis only, burn-in with `--repeat-each` |
| https://github.com/microsoft/playwright-cli | 200 OK; Apache-2.0 | Skills folder, tracing, storage state commands |
| https://github.com/Ycsyyds/codebase-analysis-skill | 200 OK; MIT | Nine-phase documentation method (rejected as too heavy); evidence-only idea kept; the page's install commands name a different account |
| https://github.com/obra/superpowers (root, systematic-debugging and verification-before-completion SKILL.md raw) | 200 OK; MIT | Four-phase debugging, stop at the third failed fix, one change at a time; verification gate (fresh command, read output, no hedged claims) |
| https://playwright.dev/docs/intro | not re-fetched | Version context only (2026-11-24: 200 OK, nav links not extractable) |

## Licenses of the compared repos

Behavior restated in our own words; no repository text is copied. MIT: lackeyjb/playwright-skill, currents-dev/playwright-best-practices-skill, Ycsyyds/codebase-analysis-skill, obra/superpowers. Apache-2.0: microsoft/playwright-cli, microsoft/playwright (Test Agents source). Licenses are those shown on the repo pages on 2026-11-27 (earlier LICENSE-file reads on 2026-11-24 agree).

## Reading limits

- The release-notes page was read only in its first 100k of about 215k characters.
- Several pages were summarized, not read verbatim; wording-sensitive points are flagged as source-based in the references.
- The `.claude/agents` and `.mcp.json` outputs come from repository source, not a docs page.
- Nothing was cloned or executed. Code snippets in the references are own examples and were not run.
- The deleted draft-claims reference and the removed per-stack table are covered under claims not adopted below.

## Claims not adopted as fact

- Extra `init-agents` flags beyond `--loop`: the agents page documents none; the CLI parsing file was not read.
- The healer's "do whatever passes" behavior and `test.fixme()` ending: documented behavior, rejected as policy (INTEG, REPAIRCAP).
- Token-saving claims for the CLI over MCP: the Playwright page asserts it with no measurements.
- Per-stack start, seed, auth and flaky-cause advice (Next.js, Express, Django, Laravel, Rails, .NET, static sites): general practice, never source-checked; removed from `stack-adapters.md`.
- The third-party install command `npx skills add ...`: shown in the currents README, never required here and not run.
- `.claude/prompts` output of `init-agents`: needs a prompts option whose CLI exposure was not seen.
