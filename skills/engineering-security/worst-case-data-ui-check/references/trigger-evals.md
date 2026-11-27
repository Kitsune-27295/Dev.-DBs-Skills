# Trigger evals

Last verified 2026-11-27. Starting points for tuning the description, not laws.

Should trigger:
1. "Before release, try this user list with a 90-character name, an empty list and 5,000 rows and tell me what breaks." -> `worst-case-data-ui-check`
2. "Does the card layout survive a really long e-mail address or an Arabic name at 320 px?" -> `worst-case-data-ui-check`
3. "Check how the dashboard looks when the API returns null for the score and the request is slow." -> `worst-case-data-ui-check`

Near-misses:
1. "Audit this page for WCAG 2.2 conformance: contrast, focus order, target size." -> `a11y-audit`
2. "Add a committed Playwright test for the checkout flow." -> `playwright-qa-orchestrator`
3. "The score shows 0 but the database has null; find where it turns into 0." -> `cross-layer-value-trace`
