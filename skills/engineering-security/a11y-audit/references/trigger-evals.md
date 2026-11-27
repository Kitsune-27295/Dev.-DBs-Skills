# Trigger Evals: a11y-audit

Last verified 2026-11-27. Prompts are starting points, not a scored run.

Should trigger (`a11y-audit`):
1. "Check our checkout flow against WCAG 2.2 AA before Friday's release and give me a report."
2. "Lighthouse says 100 for accessibility but a colleague cannot tab into the date picker. What is going on?"
3. "Triage this axe JSON: 40 violations, 12 'incomplete'. Which are real?"

Near-miss (other skill):
1. "Add Playwright tests for the login page and heal the flaky ones." Expected: `playwright-qa-orchestrator`.
2. "Does the table still lay out with 5,000 rows and a 90-character name?" Expected: `worst-case-data-ui-check`.
3. "Our form accepts any value if JavaScript is off." Expected: `never-trust-the-client`.
