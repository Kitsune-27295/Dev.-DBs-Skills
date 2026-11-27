# Sources — Transactional Email Engineering

Every URL below was checked during skill authoring (2026-11-25). Fetching used a page-to-text tool that answers from a summary of the page; long pages were read only in part.

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://www.rfc-editor.org/info/rfc5321 | 200 OK (first 100k of 256k chars read) | SMTP is Draft Standard, obsoletes 2821, updated by 7504. |
| https://www.rfc-editor.org/info/rfc5322 | 200 OK (first 100k of 140k chars) | Line limits 998 (must not exceed) and 78 (should not exceed); updated by 6854. |
| https://www.rfc-editor.org/info/rfc6409 | 200 OK | Submission vs relay split, port 587, updated by 8314. |
| https://www.rfc-editor.org/rfc/rfc7208.html | 200 OK (first 100k of 159k) | 10-term DNS lookup limit, counted mechanisms, permerror, void lookups. |
| https://www.rfc-editor.org/rfc/rfc6376.html | 200 OK (first 100k of 190k) | DKIM coverage, key size, From signing, selectors, key location. |
| https://www.rfc-editor.org/rfc/rfc8058.html | 200 OK | One-click unsubscribe headers and obligations. |
| https://www.rfc-editor.org/info/rfc7489 | 200 OK | DMARC 2015, Informational, obsolete, points to 9989/9990/9991. |
| https://www.rfc-editor.org/info/rfc9989 | 200 OK | DMARC, Proposed Standard, May 2026, obsoletes 7489 and 9091. |
| https://www.rfc-editor.org/info/rfc9990 | 200 OK | Aggregate reporting, May 2026, obsoletes 7489. |
| https://www.rfc-editor.org/info/rfc9991 | 200 OK | Failure reporting, May 2026, obsoletes 7489, updates 6591. |
| https://support.google.com/mail/answer/81126?hl=en | 200 OK | Sender requirements, 0.1%/0.3% spam rate, 5,000 bulk definition. |
| https://support.google.com/mail/answer/14229414?hl=en | 200 OK | FAQ: 48 hours unsubscribe, 7 days, June 1 2024 one-click deadline. |
| https://senders.yahooinc.com/best-practices/ | 200 OK | Yahoo requirements incl. 2-day unsubscribe, 0.3%, DKIM 1024. |
| https://cheatsheetseries.owasp.org/cheatsheets/Email_Validation_and_Verification_Cheat_Sheet.html | 200 OK | Validation, verification tokens, enumeration, disposable domains. |
| https://github.com/hteumeuleu/caniemail | 200 OK | Source of Can I email, MIT, structure of data. |
| https://github.com/stewartjarod/email-lint | 200 OK | Exists, MIT, small and early, CLI/library/CI. |
| https://www.emailmarkup.org/en/reports/accessibility/2025/ | 200 OK | 2025 accessibility report figures. |
| https://www.w3.org/TR/WCAG22/ | 200 OK (first 100k of 270k) | WCAG 2.2 Recommendation, SC 1.4.3, 1.1.1, 1.3.2. |
| https://postmarkapp.com/guides/transactional-email-best-practices | 200 OK | Streams, authentication, plain text, no-reply, unsubscribe. |
| https://postmarkapp.com/guides/transactional-email-bounce-handling-best-practices | 200 OK | Bounce types, suppression, webhook handling. |
| https://docs.aws.amazon.com/ses/latest/dg/best-practices.html | 200 OK (index page only, two links) | Pointer to the sub-pages. |
| https://docs.aws.amazon.com/ses/latest/dg/tips-and-best-practices.html | 200 OK | Subdomains, double opt-in, role aliases, no-reply, DKIM/SPF. |
| https://docs.aws.amazon.com/general/latest/gr/ses.html | 200 OK | Endpoints and default quotas (200/24h, 1/s). SMTP port numbers were not stated on this page. |

Not fetched (skipped on purpose): https://www.caniemail.com/ itself, the draft RFC 5321bis pages, RFC 2045-2049, m3aawg.org, emailmarkup.org home, the legacy App Engine bulk-mail page, the Stripo blog, and the off-topic generic lists.

## Reading limits

- Fetches returned model-written summaries; for the RFCs only the first 100,000 characters were read. Anything beyond status and the specific points listed above is unverified.
- Provider pages change. The numbers are as read on 2026-11-25.
- The full body of RFC 9989 to 9991 was not read.
- Can I email's data format and any API were not confirmed; only the repository front page was read.

## Claims not adopted as fact

- "Port 465 or 2587 for SES" and other provider port lists: no fetched page stated them.
- "Google honors unsubscribe within 2 days": Google's pages said 48 hours as a recommendation; "2 days" is Yahoo's wording.
- Any new DMARC behavior (tags, defaults, alignment changes) in RFC 9989: not read.
- A 5,000 per day bulk definition as a hard line: Google says "close to 5,000 or more" in 24 hours; Yahoo gives no threshold.
- Secondary blogs (tinyrelay, inboxkit, safeguard, Red Sift, dmarcian, Fastmail blog, Stripo): not fetched and not used as rules.
- Warm-up schedules and bounce-rate targets: no fetched primary page gave them.
- Postmark bounce percentages are Postmark-wide statistics, not targets.
