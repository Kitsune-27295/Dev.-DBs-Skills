# Project Discovery Checklist for Test Setup

Sources: https://github.com/Ycsyyds/codebase-analysis-skill · https://github.com/lackeyjb/playwright-skill · https://github.com/microsoft/playwright/tree/main/packages/playwright/src/agents · https://playwright.dev/docs/test-agents · https://github.com/currents-dev/playwright-best-practices-skill/blob/main/playwright-best-practices/core/configuration.md · Last verified 2026-11-24

Owner of rule DISC in `ssot-rule-registry.md`. Borrowed from the codebase-analysis skill: every statement about the project must be traceable to a file or a live observation, and the work is planned from a short inventory before deep work. Left behind: its 9 phases, auto-initialization and multi-thousand-line outputs, which are far too costly for test setup.

## 1. Budget and order (stop as soon as you can act)

Read in this order; stop when you can answer "how do I run one test against a known target?".

1. **Agent instructions** already in the repo (CLAUDE.md, AGENTS.md, README test section). Do not generate new ones.
2. **package manifest scripts**: names of test, e2e, lint, build, start commands and the package manager lockfile.
3. **Playwright config** (`playwright.config.*`): test directory, projects, base URL source, web server command, retries, trace setting, reporter, storage state paths, timeouts.
4. **One seed or representative test and the fixtures file**: how pages are opened, how login happens, what helpers exist. Read one test, not the folder.
5. **Folder listing only** of the test tree (names, not contents) to learn naming, tagging and page-object conventions.
6. **CI workflow** that runs the tests: browsers, shards, env vars, artifact upload.
7. **Env templates** (`.env.example`, config files): variable names only; never read or print real secret values.
8. **App surface**: route table or router file, then, if needed, a live look through one accessibility snapshot per key page rather than screenshots.
9. **Requirements**: README, specs/, tickets or acceptance notes the user points to.

Stop-reading rule: cap at about 15 files for a small task; if the config and one test answer the question, stop at step 4.

## 2. Inventory to write down (10 lines or fewer)

| Item | Example entry | Evidence |
|---|---|---|
| Run command for one file | `npx playwright test tests/cart.spec.ts` | package.json, config |
| Target | `baseURL` from env, local server via config web server | config |
| Auth | setup project saves storage state for two roles | fixtures file |
| Data | API seeding helper; per-worker users | helpers |
| Conventions | tags, test id attribute, page-object use | one test, folder names |
| CI | sharded, 2 retries, trace on first retry | workflow |
| Gaps | no tests for checkout; no negative cases | listing vs route table |
| Blockers | env var missing; app not running | live check |

Cite each entry as `path` (and line when it matters). Anything not read is written as "unknown", not guessed.

## 3. Target and safety checks

- Target selection, production handling and secrets follow ENV and AUTH (registry); a port scan only suggests candidates.
- Do not run unfamiliar scripts from the repo to "discover" things; read them first.
- Confirm the app is reachable with one cheap request or page load before planning around it.

## 4. When nothing exists (greenfield)

Record "no config" as a finding, propose the minimal layout (config, one seed test, fixtures file, specs folder) and ask before creating it in Plan mode; in Test mode create only what the user's request requires.

## Example: a 6-line discovery result

```
Run one: npx playwright test tests/login.spec.ts --project=chromium (package.json:12, playwright.config.ts:20)
Target: BASE_URL env, default http://localhost:4000, webServer starts `npm run dev` (config:31)
Auth: tests/auth.setup.ts writes .auth/user.json; admin role missing
Tests: 14 files, tagged @smoke on 3; no page objects, fixtures in tests/fixtures.ts
CI: .github/workflows/e2e.yml, 2 shards, retries 2
Gaps: no coverage of /billing (routes.ts:44) ; unknown: staging credentials
```

## How an agent should apply this

- Walk the nine steps in order and stop early; budget reads before opening large folders.
- Produce the inventory table as the input to requirement and risk analysis, with evidence for every row.
- Mark unknowns and blockers explicitly; ask the user once, with the full list, instead of guessing.
- Carry the inventory forward to the report so the next session need not rediscover it.
