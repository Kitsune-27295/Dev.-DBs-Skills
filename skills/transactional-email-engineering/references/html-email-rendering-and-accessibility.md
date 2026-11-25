# HTML Email Rendering and Accessibility

Sources: https://github.com/hteumeuleu/caniemail · https://github.com/stewartjarod/email-lint · https://www.emailmarkup.org/en/reports/accessibility/2025/ · https://www.w3.org/TR/WCAG22/ · https://postmarkapp.com/guides/transactional-email-best-practices

Last verified 2026-11-25

## Rendering

- Email clients render a limited and uneven subset of HTML and CSS. Can I email is the community support table (its source repository is MIT licensed; the repository page described the data as feature files plus test HTML, with no public API mentioned). Use it as the lookup for "does client X support feature Y".
- Practical conclusion: build with simple table layout, inline-able styles, web-safe fallbacks, and test with real clients for anything critical (reset links, codes). Progressive enhancement for media queries, with a readable single-column fallback.
- Postmark's guide adds: design for mobile, keep a plain-text twin, use absolute dates and times in the recipient's zone, keep subject lines short (it gives about 50 characters), and explain why the recipient got the message.

## A lint step, not eyeballing

- `email-lint` (GitHub, MIT, small and early: 18 commits, 8 stars when read) lints HTML against Can I email data, with CLI, library and CI annotations; it can also check React Email components and exits non-zero on errors. Maturity is low: pin the version, read its rules, and keep it as one check among several. It is a pointer, not an endorsement.
- Pair it with an accessibility check on the rendered HTML (any maintained checker) and with a plain-text diff check.
- Put it in CI after template rendering with fixtures, so a template edit that breaks compatibility fails the build.

## Accessibility

The Email Markup Consortium 2025 report analyzed 443,585 emails: 99.89% had serious or critical issues. Most frequent: no `lang` on children of body (96.67%) and on `<html>` (67.01%); formatting tables without `role="presentation"` or `none` (86.24%); missing alt text (critical in 51.42%); no level-one heading (76.78%); no `<title>` (41.35%); links without discernible text (72.04%). It suggests `lang="und"` as last resort when the language is unknown, and empty `alt` for decorative images.

WCAG 2.2 (W3C Recommendation, 12 December 2024) gives the base criteria: text contrast at least 4.5:1 (1.4.3, large text 3:1), text alternatives for non-text content (1.1.1), and a determinable reading order (1.3.2). WCAG is a web standard; applying it to email is an engineering judgment, since clients differ.

## Examples (own)

- Template skeleton checks: `<html lang="en">`, `<title>`, one `<h1>`, layout tables with `role="presentation"`, every `<img>` has `alt`, every link text makes sense alone ("Reset your password", not "click here").
- Fixture matrix: one template rendered with long names, right-to-left text and a missing optional field, snapshotted.

## How an agent should apply this

1. Pick features from the support data, not from browser behavior; state which clients were not checked.
2. Add rendering fixtures plus lint plus accessibility checks to CI, and report what ran.
3. Keep critical actions in text; never rely on an image or a hidden pre-header alone.
4. Do not claim a template "works in all clients"; claim only what the lint and the tested clients showed.
