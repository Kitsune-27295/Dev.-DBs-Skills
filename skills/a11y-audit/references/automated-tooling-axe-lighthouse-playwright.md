# Automated Tooling: axe-core, Lighthouse, Playwright

Sources: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md · https://github.com/dequelabs/axe-core/blob/develop/doc/API.md · https://developer.chrome.com/docs/lighthouse/accessibility/scoring · https://playwright.dev/docs/accessibility-testing · https://playwright.dev/docs/aria-snapshots · https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Accessibility/Tooling · Last verified 2026-11-24

Command lines for Lighthouse and install names are from general knowledge, not from the pages read; confirm against the installed version.

## 1. What each tool is

| Tool | Role | Strength | Limit |
|---|---|---|---|
| axe-core | Rule engine run inside the page | Precise, explains each failure with selector and help link; maps rules to WCAG tags | Covers only what can be decided from the DOM and styles |
| Lighthouse (accessibility category) | Runs axe audits, adds a score | Quick whole-page baseline in a standard report | Score is a weighted average of automated, pass/fail audits; manual audits are excluded; one page state at a time |
| `@axe-core/playwright` | axe inside a Playwright test | Scans each state a script reaches, can be a regression check | Only as good as the states the script reaches |
| Playwright ARIA snapshots | Tree comparison | Cheap regression guard for names/roles/structure | Detects change, not correctness |
| DevTools Accessibility panel, WAVE, Accessibility Insights | Human-driven inspection | Guided manual checks and tree view | Needs a person |

## 2. axe result groups (do not collapse them)

- `violations`: rule failed on a node. Each node has a selector `target`, the HTML, and a failure summary with how to fix. Candidate defects: reproduce by hand before reporting.
- `incomplete` ("needs review"): the rule could not decide, because of a technical limit or an error during the run. Not a pass. Typical: contrast over images or gradients. Every item needs a human decision; list the open ones in the report.
- `passes`: one rule found no problem on that node. Useful to show what was checked, never proof of accessibility.
- `inapplicable`: the rule found nothing to test (no video, no table). Neutral.

Impact levels run critical, serious, moderate, minor. They describe the rule, not your user's task; severity in the report is decided separately (see the severity and evidence reference).

## 3. Selecting rules

- Rules carry tags: conformance level (`wcag2a`, `wcag2aa`), version and level (`wcag21a`, `wcag21aa`, `wcag22aa`), criterion (`wcag244` means 2.4.4), and `best-practice`, `experimental`, `cat.*` categories.
- Listing one tag does not pull in related levels: to run level A and AA together, pass every tag (`wcag2a`, `wcag2aa`, plus the 21 and 22 ones for the target version).
- In the rule list read, the WCAG 2.2 AA rules were off by default and the AAA and deprecated groups too. Enable 2.2 on purpose (tag `wcag22aa`) when the target is 2.2, or the new criteria such as target size are silently absent.
- Best-practice rules are not WCAG failures. Report them separately and say so; do not map them to a criterion.
- For very large pages the API notes `resultTypes` can limit returned nodes to speed runs; keep `incomplete` out of that limit when auditing.
- axe checks nested iframes by default and supports open shadow DOM; closed shadow roots and cross-origin frames can be partial: note that in coverage.

## 4. Playwright wiring

```ts
import AxeBuilder from '@axe-core/playwright';

const scan = (page, scope?) => {
  let b = new AxeBuilder({ page }).withTags(['wcag2a','wcag2aa','wcag21a','wcag21aa','wcag22aa']);
  if (scope) b = b.include(scope);
  return b.analyze();
};

test('checkout: payment step', async ({ page }, testInfo) => {
  await page.goto('/checkout');
  await page.getByRole('button', { name: 'Continue' }).click();
  await page.getByRole('heading', { name: 'Payment' }).waitFor(); // settle first
  const r = await scan(page);
  await testInfo.attach('axe', { body: JSON.stringify(r, null, 2), contentType: 'application/json' });
  expect(r.violations).toEqual([]);   // incomplete is read by a person, not asserted away
});
```

Rules of use:

1. Interact and wait for the target element before `analyze()`, otherwise axe scans the wrong state.
2. Scan at least: initial load, each opened menu/dialog, validation-error state, success state, and a 320 px wide viewport.
3. `include`/`exclude`/`disableRules` narrow or silence results. `exclude` skips an element and all descendants for every rule, so keep it small and each use documented with a reason and tracking reference.
4. Do not snapshot the full `violations` array (HTML snippets churn). Snapshot a fingerprint: rule id plus node targets.
5. Put the builder in a fixture (`test.extend`) so tags and shared exclusions live in one place.
6. A known-bad page can use a fingerprint snapshot as a baseline; new entries fail the test, fixed entries are removed deliberately.

Execution discipline for these tests (running only what is relevant, classifying failures, no weaker assertions) is owned by `playwright-qa-orchestrator`.

## 5. Lighthouse

```
npx lighthouse <url> --only-categories=accessibility --output=json --output-path=./a11y-lh.json --quiet
```

- Scoring: weighted average of automated audits, weights of 3, 7 or 10 derived from axe impact assessments; each audit is binary, so one unnamed button fails the whole button-name audit and earns zero for it.
- Manual audits, and low-impact or best-practice ones, do not change the score.
- Use it as a baseline and trend. The scoring page lists what counts; it does not turn a high score into a conformance statement. That reading is also this skill's rule: never report a number as "accessible".
- Lighthouse audits one URL and one state per run; for multi-step flows use the Playwright route or run it on the state's URL if it has one.

## 6. Reading results honestly

Automated checks find only part of the problems; Playwright's own documentation says many issues can only be found manually, and MDN says the same of auditing tools. No source read gives a defensible percentage, so state none. The coverage statement lists the criteria with no rule at all (see the criteria map) and says how each was handled.

## How an agent should apply this

- Run axe per state with the full tag set for the target version, including the 2.2 tag; keep the raw JSON as evidence.
- Triage: verify each violation by hand, list every `incomplete` item as open or resolved with a reason, and separate best-practice hits.
- Never raise a Lighthouse score by excluding audits or nodes; fix or record the false positive.
- Report scores only as a baseline with the sentence "automated audits only".
- Install nothing globally; ask before adding a dev dependency, otherwise use `npx` in a throwaway directory.
