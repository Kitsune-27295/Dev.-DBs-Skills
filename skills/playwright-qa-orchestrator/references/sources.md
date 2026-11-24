# Sources — Playwright QA Orchestrator

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://github.com/lackeyjb/playwright-skill (README.md, skills/playwright-skill/SKILL.md, LICENSE via raw.githubusercontent.com) | 200 OK; MIT | Dev-server detection with ask-first, env-based credentials, no-sleep locator guidance; visible-browser default rejected |
| https://github.com/currents-dev/playwright-best-practices-skill (README, SKILL.md, core/locators, assertions-waiting, fixtures-hooks, configuration, test-data, global-setup, debugging/flaky-tests, debugging, console-errors, advanced/authentication, architecture/when-to-mock; LICENSE.md) | 200 OK (root LICENSE returned 404, LICENSE.md used); MIT, Currents Software Inc. 2026 | Locator order, web-first assertions, isolation, mocking matrix, retry budget, flakiness taxonomy |
| https://github.com/microsoft/playwright-cli (skills/playwright-cli/SKILL.md, references/tracing.md, playwright-tests.md, storage-state.md; LICENSE) | 200 OK; Apache-2.0 | Snapshot-driven exploration, refs vs durable locators, trace contents, debug-attach flow, untrusted page tools |
| https://github.com/microsoft/playwright/tree/main/packages/playwright/src/agents (planner, generator, healer .agent.md) | 200 OK (read via raw.githubusercontent.com; directory listing via GitHub API); Apache-2.0 | Role separation, seed test and specs convention, healer behaviors incl. fixme and unbounded loop (conflict) |
| https://github.com/Ycsyyds/codebase-analysis-skill (SKILL.md, README, docs/PHASE1_ENHANCED.md, Gotchas.md, LICENSE) | 200 OK; MIT | Evidence-only claims, inventory before action; heavy 9-phase pipeline rejected |
| https://github.com/obra/superpowers (skills/systematic-debugging SKILL.md + root-cause-tracing.md + condition-based-waiting.md, verification-before-completion, test-driven-development, LICENSE) | 200 OK; MIT | Root-cause-first order, 3-attempt cap, verification gate, red-green proof, condition-based waiting |
| https://playwright.dev/docs/test-agents | 200 OK (WebFetch summarized + curl; read in two passes) | init-agents loops, what each loop generates, planner/generator/healer, seed, specs/tests layout, healer-may-skip caveat |
| https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/generateAgents.ts | 200 OK (WebFetch, summarized) | Claude loop outputs: .claude/agents, .mcp.json, seed, specs |
| https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/playwright-test-healer.agent.md | 200 OK (WebFetch, summarized) | healer workflow, test.fixme behavior |
| https://api.github.com/repos/microsoft/playwright/contents/packages/playwright/src/agents | 200 OK | agent file names |
| https://playwright.dev/docs/best-practices | 200 OK | locator priority, isolation, traces, CI, lint |
| https://playwright.dev/docs/locators | 200 OK | locator order, strictness, filtering, testIdAttribute |
| https://playwright.dev/docs/test-assertions | 200 OK | web-first, expect.poll, toPass, timeouts |
| https://playwright.dev/docs/actionability | 200 OK | actionability checks per action |
| https://playwright.dev/docs/api/class-page | 200 OK (curl, waitForTimeout section) | waitForTimeout marked Discouraged |
| https://playwright.dev/docs/test-isolation | 404 | not available; isolation read from browser-contexts |
| https://playwright.dev/docs/browser-contexts | 200 OK | per-test context isolation |
| https://playwright.dev/docs/test-fixtures | 200 OK | fixtures, auto/worker/option, mergeTests |
| https://playwright.dev/docs/test-projects | 200 OK | projects, dependencies, teardown, --no-deps |
| https://playwright.dev/docs/auth | 200 OK | storage state, playwright/.auth gitignore, setup project |
| https://playwright.dev/docs/test-retries | 200 OK | retry semantics, flaky definition |
| https://playwright.dev/docs/trace-viewer-intro | 200 OK | trace on-first-retry, report |
| https://playwright.dev/docs/api/class-testoptions | 200 OK | trace/screenshot/video modes |
| https://playwright.dev/docs/api/class-testconfig | 200 OK | defaults: workers, retries, timeouts |
| https://playwright.dev/docs/debug | 200 OK | --debug, pause, PWDEBUG, DEBUG=pw:api |
| https://playwright.dev/docs/codegen-intro | 200 OK | codegen, assertions, locator pick |
| https://playwright.dev/docs/test-ui-mode | 200 OK | UI mode features and setup caveat |
| https://playwright.dev/docs/ci-intro | 200 OK | GitHub Actions workflow, artifacts, globalTimeout |
| https://playwright.dev/docs/test-sharding | 200 OK | --shard, blob, merge-reports |
| https://playwright.dev/docs/test-reporters | 200 OK | reporters and defaults |
| https://playwright.dev/docs/test-parallel | 200 OK | workers, fullyParallel, modes, isolation tips |
| https://playwright.dev/docs/api-testing | 200 OK | request fixture, API vs UI roles |
| https://playwright.dev/docs/getting-started-mcp | 200 OK | Playwright MCP, snapshots |
| https://playwright.dev/agent-cli/introduction | 200 OK | @playwright/cli for agents |
| https://playwright.dev/docs/release-notes | 200 OK (first 100k chars of 215k read) | version 1.65 latest, agents since 1.56 (undated) |
| https://playwright.dev/docs/intro | 200 OK (curl; nav links not extractable) | version context only |
| Pack author's draft skill (private notes; not a public URL) | Provided by the author; not fetched | Six-phase cycle, three modes, four guardrails; every claim checked in draft-claims-check.md |

## Licenses of the compared repos

As recorded when each LICENSE file was read; no repository text is copied, only behavior restated in our own words.

- lackeyjb/playwright-skill: MIT.
- currents-dev/playwright-best-practices-skill: MIT (LICENSE.md; the root LICENSE path returned 404).
- microsoft/playwright-cli: Apache-2.0.
- microsoft/playwright (Test Agents source): Apache-2.0.
- Ycsyyds/codebase-analysis-skill: MIT.
- obra/superpowers: MIT.

## Reading limits

- The release-notes page was read only in its first 100k of about 215k characters; the version statement (1.65 newest, agents since 1.56) comes from that part and the page shows no date.
- Several pages were read through summarizing fetches rather than raw text (test-agents page, agents source files); anything depending on exact wording is flagged in the reference as source-based.
- `https://playwright.dev/docs/test-isolation` returned 404; isolation facts come from the browser-contexts page.
- `https://playwright.dev/docs/intro` returned 200 but its navigation links were not extractable; used for version context only.
- The `webServer` config key was not fetched from its own docs page; `stack-adapters.md` marks its option names as unverified.
- Source repositories were read as data; nothing was cloned or executed.

## Claims not adopted as fact

- `--fail-on-flaky-tests` and `--repeat-each`: not covered by the Playwright pages read; confirm with `npx playwright test --help` before use.
- Extra `init-agents` flags beyond `--loop` (for example prompts or project options): only function parameters were seen in source; the CLI parsing file was not read.
- The install command `npx skills add currents-dev/playwright-best-practices-skill`: no page read verifies it.
- The `.claude/agents` and `.mcp.json` outputs of `--loop=claude` come from repository source, not a docs page; the docs page's own Claude example prints `--loop=vscode`, a docs inconsistency.
- The healer's "do whatever passes" behavior and its `test.fixme()` ending: documented as behavior, rejected as policy (INTEG, REPAIRCAP).
- Third-party claims about token savings, for example that the CLI uses fewer tokens than MCP, rest on the Playwright docs' own wording only and are not measured here.
- Stack-specific advice in `stack-adapters.md`: general practice, not verified against a source.
