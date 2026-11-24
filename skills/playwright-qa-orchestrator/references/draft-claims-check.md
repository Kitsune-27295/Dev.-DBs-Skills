# Draft Claims Check

Sources: https://playwright.dev/docs/test-agents · https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/generateAgents.ts · https://playwright.dev/docs/api/class-page · https://playwright.dev/docs/locators · https://playwright.dev/docs/test-retries · https://playwright.dev/docs/trace-viewer-intro · https://playwright.dev/docs/api/class-testoptions · Last verified 2026-11-24

Doc version: Playwright 1.65 is the newest release in the release notes (undated); agents introduced in 1.56.

| # | Claim in the user's draft | Verdict | Evidence and nuance |
|---|---|---|---|
| 1 | `npx playwright init-agents --loop=claude` exists | verified | Docs list vscode, claude, codex, opencode loops. Only `--loop` is documented. |
| 2 | It creates agent files for Claude Code | verified, source-based | Repo source writes `.claude/agents/<name>.md` (playwright-test-planner/generator/healer), `.mcp.json` with a `playwright-test` server, a default seed file and `specs/`. The docs page does not list Claude paths (it shows `.github/` and mislabels its Claude example as `--loop=vscode`). |
| 3 | Planner / generator / healer roles | verified | Planner makes a Markdown plan in `specs/`, generator writes `tests/`, healer repairs failures. |
| 4 | Healer is safe for the anti-cheating policy | differs | Healer may end with a skipped test (`test.fixme()`) when it believes the app is broken; the skill overrides this per INTEG (single exception: classified product defect with evidence, tracked and reported). |
| 5 | `trace: 'on-first-retry'` | verified | Default trace config in the docs; best practices recommends it for CI and warns against `on`. Seven total modes exist. |
| 6 | Locator priority: role first, then text/label/placeholder/alt/title, test-id | verified | Locators guide order: role, text, label, placeholder, alt text, title, test id; CSS/XPath discouraged. |
| 7 | `page.waitForTimeout` is discouraged | verified | API page badge "Discouraged": for debugging only. Not mentioned on best-practices or actionability pages. |
| 8 | Retries semantics: flaky = failed then passed on retry | verified | Passed / flaky / failed definitions on the retries page; retries default 0. |
| 9 | Default workers | verified (extra) | Half the logical cores per testconfig page; CI example in parallelism page uses 2, not 1. |
| 10 | `--fail-on-flaky-tests`, `--repeat-each` exist | unverified | Not covered by the pages read; confirm with `npx playwright test --help`. |
| 11 | Extra `init-agents` flags (e.g. prompts, project) | unverified | Only function parameters seen in source; CLI parsing file not read. |
