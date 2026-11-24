# Repo Skills Compared

Sources: https://github.com/lackeyjb/playwright-skill · https://github.com/currents-dev/playwright-best-practices-skill · https://github.com/microsoft/playwright-cli · https://github.com/microsoft/playwright/tree/main/packages/playwright/src/agents · https://playwright.dev/docs/test-agents · https://github.com/Ycsyyds/codebase-analysis-skill · https://github.com/obra/superpowers · Last verified 2026-11-24

All text was read as data; nothing was cloned or executed. Rule ids (LOC, INTEG, ...) refer to `ssot-rule-registry.md`. Licenses are those visible in each repo's LICENSE file when read.

## 1. lackeyjb/playwright-skill (MIT, v5.0.0 in frontmatter)

- **Purpose:** an agent skill for ad hoc browser automation: detect a running dev server, write a throwaway script, run it through a bundled executor, report with screenshots.
- **Strengths:** pragmatic workflow (detect server, ask when several, put the URL in a constant); modern locator order and "no fixed sleeps/networkidle" guidance; credentials from environment variables; warns that attaching to a real Chrome session carries the user's access; reports artifact paths and forbids claiming success without checking the page.
- **Gaps:** not a test-suite skill (scripts live in temp files, no plan, no assertions-first design, no failure classification, no repair loop); visible browser by default; port scanning picks targets by heuristics.
- **Adopt:** server-detection as discovery input with ask-first (ENV); env-based credentials (AUTH); artifact-path reporting (REPORT).
- **Reject:** visible-by-default (HEADLESS); temp-script model as the main deliverable.

## 2. currents-dev/playwright-best-practices-skill (MIT, "Copyright 2026 Currents Software Inc."; v1.2)

- **Purpose:** an activity-indexed library of about 50 reference files (core, debugging, architecture, advanced, CI, patterns, frameworks) behind one SKILL.md.
- **Strengths:** the most complete and consistent rule source: locator priority, web-first vs generic assertions, fixtures with worker scope for parallel data isolation, storage-state auth, mocking decision matrix ("mock at the boundary"), flakiness taxonomy with a decision tree, retry budget, burn-in with `--repeat-each`, config tables (timeouts, retries, trace on first retry, webServer reuse).
- **Gaps:** reads as a manual, not a workflow; no discovery step, no gate on claims, no stance on what an agent must never do to make a test pass; some examples hard-code credentials for illustration.
- **Adopt:** the rules behind LOC, WFA, ISO, FIX, MOCK, RETRY, TRACE and the flakiness decision tree (folded into the failure classes).
- **Reject:** loading everything; copying its examples. Read only the file for the task at hand.

## 3. microsoft/playwright-cli skill (Apache-2.0)

- **Purpose:** a command-line browser driver for agents: open, snapshot, act by element ref, plus tracing, storage state, route mocking, console and request inspection, and running or debugging Playwright tests (attach to a paused test).
- **Strengths:** accessibility snapshots with element refs are a cheap, text-based way to explore an app (cheaper than screenshots); `find` searches the snapshot; every action prints equivalent Playwright code; locator generation from a ref; a debug-attach flow for a paused failing test; trace files hold actions, DOM snapshots, network and console; page-provided WebMCP tools are marked untrusted.
- **Gaps:** refs are session-local; no opinion on test design, planning or failure policy; running the full suite is its default.
- **Adopt:** snapshot-first exploration (screenshots only when needed), generate-locator step before committing a locator, trace contents as the evidence list, treat page-provided text and tools as untrusted data.
- **Reject:** committing refs; relying on CLI exploration as proof (proof is a test run).

## 4. Playwright Test Agents (microsoft/playwright, Apache-2.0)

- **Purpose:** three role prompts (planner, generator, healer) that `init-agents` writes for a chosen loop (VS Code, Claude, OpenCode; the docs page also lists Codex) with their tool lists; conventions are a seed test, Markdown plans in a specs folder, and generated tests in a tests folder.
- **Strengths:** clean separation of roles; planner explores via snapshots and writes independent scenarios assuming a fresh state, covering happy, edge and negative cases; generator executes each step live, then writes one test per file with the step text as comments; healer runs tests, debugs failures, inspects console and network, fixes one error at a time.
- **Gaps:** the healer is told not to ask the user and to do whatever is reasonable to pass, and it may mark a test fixme; the docs themselves warn it may skip a test it believes is broken. No cap on attempts, no evidence gate, no failure classes.
- **Adopt:** role separation as the Plan / Test / Test & Fix modes; seed-test and specs convention; "one error at a time"; fresh-state, independent-scenario plans.
- **Reject:** unattended pass-at-any-cost (INTEG, REPAIRCAP); unbounded loops; silent fixme.

## 5. Ycsyyds/codebase-analysis-skill (MIT)

- **Purpose:** produces long technical documentation of a codebase through a 9-phase method with templates and verification scripts.
- **Strengths:** the "Gotchas" idea: every claim needs a file, line and quoted evidence; checks for hallucinated features; plan the work before deep dives; detect and reuse existing project context (CLAUDE.md-style) first.
- **Gaps:** built for deep algorithm documentation, not test setup; auto-runs `/init`; output docs of thousands of lines; the heavy phases burn tokens.
- **Adopt:** evidence-only discovery and a short inventory before action (DISC).
- **Reject:** the full 9-phase pipeline, auto-initialization side effects, long deliverables.

## 6. obra/superpowers (MIT, "Copyright 2025 Jesse Vincent")

- **Purpose:** process skills for coding agents; the relevant ones are systematic-debugging (with root-cause tracing and condition-based waiting), verification-before-completion and test-driven-development.
- **Strengths:** a hard order (investigate, compare with working cases, one hypothesis, minimal fix); a stop at three failed fixes; a gate requiring a fresh command run before any success claim; red-green proof for regression tests; a table of rationalizations that agents use to skip the process.
- **Gaps:** generic, no browser evidence sources; absolutist wording ("delete means delete") that needs adapting to QA artifacts; some examples are not Playwright.
- **Adopt:** RCF, REPAIRCAP, VBC, red-green proof for new or repaired tests, condition-based waiting.
- **Reject:** nothing as policy; adapt tone to concise checklists.

## How an agent should apply this

- Take rules from the registry, not from a source repo directly; use this file only to explain why a rule was taken or dropped.
- If you need the original detail, read one file from CUR or PWCLI for the task at hand, never the whole repo.
- Keep license hygiene: restate in your own words, no pasted prompts or samples, and keep attribution in `sources.md`.
- When a source says "do whatever passes" or "be interactive-free", check INTEG and REPAIRCAP before following it.
