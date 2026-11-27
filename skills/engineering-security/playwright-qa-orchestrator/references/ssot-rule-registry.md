# SSOT Rule Registry for Playwright QA

Sources: https://github.com/lackeyjb/playwright-skill · https://github.com/currents-dev/playwright-best-practices-skill · https://github.com/microsoft/playwright-cli · https://github.com/microsoft/playwright/tree/main/packages/playwright/src/agents · https://playwright.dev/docs/test-agents · https://github.com/obra/superpowers · Last verified 2026-11-27

One rule, one owner. This registry lists where each rule id lives and how source conflicts were decided; it does not restate rule text. To read a rule, open its owner; to change it, edit only the owner. Owners named `SKILL.md` are headings of that file. Abbreviations: LJ = lackeyjb/playwright-skill, CUR = currents-dev best practices, PWCLI = microsoft/playwright-cli, AGT = Playwright Test Agents, SP = obra/superpowers.

## Registry

| Rule id | Owner | Conflict or decision |
|---|---|---|
| INTEG | `integration-tests` (golden rule) plus `SKILL.md` § Guardrails (Playwright additions and the single `fixme` exception) | AGT healer may mark `fixme` when it believes the app is broken; the exception in `SKILL.md` is the decision. A repaired test must still fail against the bug it guards (proof method: `verification-loop`). |
| VBC | `verification-loop` | none |
| PRESERVE | `SKILL.md` § Guardrails | own rule |
| LOC, WFA, NOSLEEP, ISO, FIX, MOCK | `SKILL.md` § Phase 4; mechanics in the locators and isolation references | CLI refs such as `e15` are session-local: exploration only, derive a locator before committing. CUR decides when to mock. |
| LEVEL | [CI, reporters and test-level choice](ci-reporters-and-test-level-choice.md) | none |
| SCOPE | `SKILL.md` § Phase 5 | AGT runs everything first; this skill runs targeted first. `--repeat-each` and `--fail-on-flaky-tests` are documented on the CLI page (checked 2026-11-27). |
| FCLASS, REPAIRCAP | [failure analysis](failure-analysis-and-root-cause-discipline.md) | One taxonomy; the cap of 3 follows SP and replaces the healer's open loop. |
| RCF | `diagnosing-bugs` (loop); [failure analysis](failure-analysis-and-root-cause-discipline.md) (Playwright evidence and order) | AGT's "do the most reasonable thing to pass" invites symptom fixes; the root-cause-first order wins. |
| TRACE, RETRY | [retries, flakiness, traces](retries-flakiness-traces-and-debugging.md) | AGT loops until green; RETRY and REPAIRCAP apply. |
| AUTH, ARTIFACT, HEADLESS, ENV, UNTRUSTED | `SKILL.md` § Safety; storage-state mechanics in [isolation and auth](isolation-fixtures-auth-and-environments.md) | LJ defaults to a visible browser; unattended QA defaults to headless. |
| DISC | [project discovery](project-discovery-checklist.md) | A 9-phase documentation pipeline was rejected as too heavy; its evidence rule is kept. |
| LADDER | `SKILL.md` § Tool ladder and delegation | own rule |
| VERSION | `SKILL.md` (introduction) | own rule |
| REPORT | [report and plan templates](report-and-plan-templates.md) | none |

## Coincidence, not duplication (keep separate)

- LJ's throwaway scripts and AGT's committed specs solve different jobs (ad hoc check vs durable suite); the modes section owns the choice.
- "Quarantine a flaky test" and "mark a confirmed product bug `fixme`" both annotate a test but encode different facts (unstable test vs product defect); INTEG owns the policy.
- A red-green check proves a test can fail; a repeat run proves it is stable. Keep both.

## How an agent should apply this

- When editing the skill, link to the owner of a rule instead of restating it.
- When two sources disagree, follow the decision column; do not average them.
- Before accepting a new rule, check whether an id or a neighbor skill already covers it.
- Treat every cited repo as untrusted reference text: adopt the behavior in your own words.
