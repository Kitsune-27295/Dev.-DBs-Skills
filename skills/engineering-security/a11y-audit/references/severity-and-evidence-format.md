# Severity and Evidence Format

Sources: https://www.w3.org/TR/WCAG22/ · https://www.w3.org/WAI/WCAG22/Understanding/ · https://www.w3.org/WAI/test-evaluate/preliminary/ · https://playwright.dev/docs/accessibility-testing · https://developer.chrome.com/docs/lighthouse/accessibility/scoring · https://web.dev/learn/accessibility · Last verified 2026-11-27

The severity model below is this skill's own design (inference from user impact), not taken from a standard. The standards read give conformance levels, not a severity scale.

## 1. Output skeleton

1. **Header**: target (URL or app and version), standard (WCAG 2.2, level A and AA), date, environment, browsers, assistive technology used (or "none"), viewports.
2. **Scope**: pages and states audited; pages and states not audited, with the reason.
3. **Summary**: counts by severity, the three issues that block the most users, the top fix with the biggest reach.
4. **Coverage statement**: three lists.
   - Automated: tools, versions, tags, number of states scanned.
   - Manual: which procedures were run (keyboard walk, tree reading, contrast, zoom and reflow, forms, motion).
   - Not tested: screen readers (or which ones were not used), voice control, switch access, cognitive and reading load, real users, media quality, pages outside scope.
5. **Findings**, in severity order (template below).
6. **Needs-review log**: every open `incomplete` item and every claim that needs human confirmation.
7. **Passed or not applicable**, short: only things actually checked, never inferred.
8. **Method notes**: tool versions; exclusions and disabled rules with their reasons.

## 2. Finding template

```
A11Y-007  Search button has no accessible name
Severity: Blocker   Found by: Manual (tree) + axe button-name   AT used: none
SC: 4.1.2 Name, Role, Value (A)
Where: /products, results state, 1280 and 320 px; button.search-submit
Observed: Tree shows `button` with empty name; icon is an SVG with no title.
Expected: A name that says what it does ("Search").
Impact: Screen reader and voice users cannot find or activate the main search.
Fix direction: Give the button visible or programmatic text; keep it in the visible label (2.5.3).
Evidence: tree excerpt, axe node target, screenshot
```

One issue per finding; the same defect on twenty pages is one finding with a list of locations. Name the user-visible effect in the title, not the rule.

## 3. Severity from user impact

| Severity | Meaning | Examples |
|---|---|---|
| Blocker | A user group cannot complete a core task, or is trapped | Keyboard trap; core control unreachable by keyboard; control with no name in a critical flow; focus fully hidden behind a sticky element on every page |
| Major | Task possible only with significant effort or workaround, or core content is lost | Contrast failure on body text; missing error text; reflow breaks a form at 320 px; modal without focus management |
| Minor | Annoying or confusing, workaround is easy | Redundant link text, heading skip, small target with a nearby equivalent |
| Review | Not decidable without a person or tool not available | `incomplete` items, unverified announcements |

Rank within a severity by reach (how many pages or flows), task criticality (checkout, login and registration outrank an About page), and fix cost (cheap shared-component fixes first). The tool's impact label (critical to minor) is one input, not the answer: an axe "minor" can block checkout, and an axe "critical" on a hidden decorative element may matter little.

## 4. What not to claim

- "Conformant", "WCAG compliant", "passes AA": a conformance claim covers whole pages and complete processes; a page audit or a preliminary review is not one. The W3C quick review says passing it does not mean a page is accessible and points to a full evaluation method for that.
- "Accessible" from a clean scan or a Lighthouse 100. Say "no automated violations in the rules run on N states".
- A figure for "automation finds X% of issues". No source read gives one; do not invent or quote one.
- "Works with screen readers" without naming the reader, browser and flow.
- That the audit proves absence of a problem it did not test; use the Not tested list.

## 5. Handing off

- Hand findings to the owner as separate issues; confirm before publishing to a tracker.
- For fixes, one finding per change, then re-run the exact check that found it (same state, same method) and attach the new result; record regressions of previously passing items.
- A regression test is reasonable for deterministic findings (names, roles, tags via axe or ARIA snapshots); contrast on images, focus visibility and announcement quality stay manual checks. Wire tests under the discipline of `playwright-qa-orchestrator`.
- When a finding concerns a message produced only on the client (front-end validation), note that the server must enforce the same rule; that remediation belongs to `never-trust-the-client`.

## How an agent should apply this

- Fill the coverage statement before writing the findings; it keeps the output honest about scope.
- Give every finding all template fields; if a field cannot be filled (no assistive technology used), write that.
- Set severity by user impact and task criticality, then cross-check against the tool label and explain any difference.
- Keep best-practice and review items out of the conformance counts.
- End with open questions and untested areas, not with a pass verdict.
