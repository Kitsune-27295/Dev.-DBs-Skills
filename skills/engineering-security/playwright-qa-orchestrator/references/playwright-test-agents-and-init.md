# Playwright Test Agents, init-agents, MCP and CLI

Sources: https://playwright.dev/docs/test-agents · https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/generateAgents.ts · https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/agents/playwright-test-healer.agent.md · https://playwright.dev/docs/getting-started-mcp · https://playwright.dev/agent-cli/introduction · https://playwright.dev/docs/release-notes · Last verified 2026-11-27

Doc version reflected: the release-notes page lists Playwright 1.65 as the newest release (no date shown; only its first 100k characters were read); the agents were introduced in 1.56. Treat names below as "as of 1.65"; regenerate definitions after every upgrade.

## What the three agents are

Playwright ships a planner, a generator and a healer. They can run alone, in sequence, or chained in a loop; run in sequence they build coverage for a product.

| Agent | Input | Output |
|---|---|---|
| planner | a request ("plan guest checkout"), a seed test, optionally a PRD | a Markdown plan under `specs/` (steps, expected results, data) |
| generator | the Markdown plan | Playwright tests under `tests/`, selectors and assertions checked live against the app |
| healer | a failing test name | replays steps, inspects the UI, patches, re-runs until green or until guardrails stop it |

Docs note: the seed test (`tests/seed.spec.ts`) is what the planner runs to get global setup, project dependencies, fixtures and hooks; the generator copies its style. Generated tests may contain initial errors the healer is expected to fix. The healer's documented end states are a passing test, or a skipped test if it believes the feature is broken.

## The init-agents command

Verified on the docs page: `npx playwright init-agents --loop=<vscode|claude|codex|opencode>`. `--loop` is the only flag the page documents. Regenerate after each Playwright update to pick up new tools and instructions. VS Code needs v1.105 or newer for the agentic experience.

What `--loop=claude` writes, read from the Playwright repository source on `main` (not from a docs page, so it can drift between versions; check the files after running):

- `.claude/agents/<agent-name>.md` for each agent definition; agent files in the repo are named `playwright-test-planner`, `playwright-test-generator`, `playwright-test-healer`. Frontmatter carries name, description, tools, model, color; tools map to Claude Code names (Glob, Grep, Read, Edit, Write, `mcp__...`).
- `.mcp.json` with a server key `playwright-test` running `npx playwright run-test-mcp-server` (on Windows through `cmd /c`).
- A default seed file if none is found, and `specs/` with a short `specs/README.md`.
- The docs page's own layout diagram shows `.github/` for agent definitions (the VS Code loop) and, oddly, its "Claude Code subagents" example prints `--loop=vscode`; that is a docs inconsistency, not a different command.

The source also writes prompt templates to `.claude/prompts` when a prompts option is on; whether a CLI flag exposes it was not visible: unverified. The agents folder in the repo holds the three `.agent.md` definitions and three `.prompt.md` templates.

## Healer behavior versus a strict QA policy

The healer definition (repo source) says: run the suite, debug each failure with snapshots, fix one error at a time, never wait for `networkidle`, and if it is highly confident the test is right and the app misbehaves, mark the test `test.fixme()` with a comment. It also loops until green. The QA skill's guardrails sit above it: INTEG (including its single `fixme` exception), RCF and REPAIRCAP in the registry override both behaviors.

## MCP and CLI for agent-driven browsing

- Playwright MCP (`npx @playwright/mcp@latest`; Claude Code: `claude mcp add playwright npx @playwright/mcp@latest`) drives pages through accessibility snapshots with element refs such as `ref=e5`, no vision model needed; Node 20+. `browser_run_code_unsafe` is RCE-equivalent: enable only for trusted clients. WebMCP page tools are treated as untrusted input.
- `@playwright/cli` (`npm install -g @playwright/cli`) is the shell-command alternative aimed at coding agents: a persistent daemon, each command prints URL, title and a snapshot file (accessibility tree with refs), commands include `open`, `goto`, `click`, `fill`, `snapshot`, `generate-locator`, `tracing-start`, `state-save`. The CLI page asserts lower token cost than MCP but gives no measurements; MCP suits exploratory loops.

Seed-style example (own code):

```ts
// tests/seed.spec.ts - environment bootstrap the planner runs first
import { test, expect } from './fixtures';

test('seed', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
});
```

## How an agent should apply this

- Offer `npx playwright init-agents --loop=claude` as optional setup; run it only with consent, then list the files it created and review `.mcp.json` before trusting it.
- Use planner/generator/healer as roles inside the Discovery, Planning and Recovery phases, with the registry guardrails above the healer's (see the section above).
- Prefer MCP or CLI snapshots for exploring the live app; never enable `browser_run_code_unsafe` by default.
- Re-run `init-agents` after upgrading Playwright and diff the regenerated definitions.
