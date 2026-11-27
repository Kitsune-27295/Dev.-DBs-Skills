---
name: transactional-email-engineering
description: "Engineer an application's outbound email module: RFC 5321/5322 basics and submission, SPF/DKIM/DMARC (DMARC now RFC 9989/9990/9991), mailbox-provider sender requirements, bounce/complaint suppression, RFC 8058 one-click unsubscribe, HTML email rendering and accessibility with a lint step, transactional vs marketing separation, async queue with idempotency, provider webhooks, retries, header injection, enumeration-safe responses, single-use expiring tokens, and testing with sandboxes and snapshots. Never promises inbox placement. Use when adding or reviewing email sending, password-reset or verification mail, bounce webhooks, email templates, or sender-domain setup."
---

# Transactional Email Engineering

One idea: an email module is a small distributed system with a reputation attached. Build it so a message is composed safely, sent once, authenticated, observable, and stopped when the recipient or provider says stop. Deliverability can never be guaranteed; the module can only avoid known causes of failure. Evidence and limits are in [references/sources.md](references/sources.md).

## 1. Scope and ownership

This skill owns only email-specific rules. Link out for everything else:

- Queue, retries, dead letters, graceful shutdown: `background-worker-job-scheduler`; backoff, jitter and breakers: `circuit-breaker-retry-telemetry`; duplicate-safe handlers: `idempotency-fix`; atomic "write state then send": `saga-transactional-outbox-pattern`.
- Provider quota and per-user send limits: `rate-limiter-throttler`.
- Reset/verification flow, sessions, token theft: `authn-authz-guard`.
- Untrusted input parsing: `validator-input-parser`; API error shape: `error-handling-problem-details`; persistence of suppression/outbox rows: `repository-unit-of-work`.
- Audit of leaked keys and IDOR: `security-audit`; accessibility audit of the product UI: `a11y-audit`.

## 2. Transport and message format

Details: [references/protocols-and-domain-authentication.md](references/protocols-and-domain-authentication.md).

- Hand mail to a provider API or to a submission server (RFC 6409; port 587 is the reserved submission port). Plain port 25 is relay, not for application clients.
- Use a MIME library; never concatenate headers or bodies by hand. RFC 5322 lines must not exceed 998 characters and should stay under 78; a library with proper encoding handles this.
- Send `multipart/alternative` with a plain-text part that carries the same facts as the HTML.
- One `From` address per message category, a monitored `Reply-To` or `From` (avoid no-reply), one copy of each single-instance header.

## 3. Domain authentication

- Authenticate every sending domain with SPF and DKIM, and publish DMARC. Use a dedicated sending subdomain per stream.
- DMARC is now specified by RFC 9989 (protocol), 9990 (aggregate reports) and 9991 (failure reports); they obsolete RFC 7489. Cite the new numbers, check provider docs for what they still say.
- SPF evaluation is limited to 10 DNS-lookup terms (`include`, `a`, `mx`, `ptr`, `exists`, `redirect`); more gives a permanent error. Flattening or consolidating includes is a DNS-owner task, test after changing it.
- DKIM: sign From; keep keys at 1024 bits or more (RFC 6376 minimum for signers; large keys may not fit a DNS UDP response); rotate by adding a new selector, never reusing one.
- Start DMARC at `p=none` with an `rua` mailbox, read reports, then tighten. Do not move to enforcement without evidence that all legitimate sources align.

## 4. Mailbox-provider requirements and list hygiene

Details: [references/provider-requirements-and-list-hygiene.md](references/provider-requirements-and-list-hygiene.md).

- Treat provider rules as moving targets: re-read the current page when numbers matter. Do not hardcode thresholds in code without a source comment and review date.
- Hard bounce or spam complaint: suppress the address immediately and keep the suppression durable; never "clean it up" on a retry.
- Soft bounce: bounded retries, then treat as hard.
- Bulk or subscribed mail: RFC 8058 one-click (`List-Unsubscribe` with one HTTPS URI plus `List-Unsubscribe-Post: List-Unsubscribe=One-Click`, both covered by DKIM, no redirect on the POST), plus a visible body link, and honor requests quickly.
- Security and account mail (reset, verification, receipts) is not marketing: do not add promotional content to it, and do not send marketing to addresses collected only for it.
- New domain or IP: ramp volume gradually and watch bounce and complaint rates.

## 5. HTML email rendering and accessibility

Details: [references/html-email-rendering-and-accessibility.md](references/html-email-rendering-and-accessibility.md).

- Email clients support a small, uneven subset of HTML and CSS. Check features against the Can I email data; do not trust a browser preview.
- Add a lint step to CI (compatibility linter plus an accessibility checker) and fail on errors; a person previewing a few screenshots is a supplement, not the gate.
- Accessibility basics: `lang` on `<html>`, `<title>`, real heading, `alt` on every image (empty for decorative), `role="presentation"` on layout tables, descriptive link text, 4.5:1 text contrast.
- Never put the only copy of an action (code, link) in an image.

## 6. Architecture

Details: [references/architecture-queue-webhooks-and-security.md](references/architecture-queue-webhooks-and-security.md).

- The request handler enqueues; a worker sends. Persist an outbox row (message id, template, recipient, status) in the same transaction as the business change.
- Idempotency key per logical email (for example `reset:<user>:<token-id>`); the worker checks status before sending and records the provider message id after.
- Separate streams for transactional and marketing: different subdomains or provider streams, different queues and limits, so one reputation cannot sink the other.
- Provider webhooks (bounce, complaint, delivery, unsubscribe) feed the suppression list. Verify their authenticity, make the handler idempotent, answer fast, process async.
- Respect provider quotas and rates (an account can start at a low daily quota and 1 message per second, check yours); on throttling errors back off with jitter.
- Abstract the provider behind a small port so tests and migration do not touch domain code (`hexagonal-architecture`).

## 7. Security

- Header injection: reject CR or LF in any value that reaches a header (subject, name, address); let the MIME library set headers.
- Validate addresses with a vetted library and accept broad valid forms; prove ownership by sending a confirmation, not by regex.
- Enumeration-safe: "if that address exists, we sent a message", same response and similar timing for known and unknown addresses; rate-limit the endpoint.
- Tokens: cryptographically random, time-limited, single-use, stored hashed, invalidated on use or when a newer one is issued.
- Never log message bodies, tokens, full recipient lists or credentials; mask addresses in logs. Treat webhook payloads as untrusted data.
- Do not let users control the recipient or body of system mail (contact forms and invite features are abuse vectors).

## 8. Testing

- Unit: render each template with fixtures; snapshot the HTML and plain text; assert headers (From, Reply-To, List-Unsubscribe) and that no placeholder is left unrendered.
- Integration: a local SMTP sandbox or capture server (or the provider's sandbox) to read what was really sent; test retries, duplicate delivery and webhook replays.
- Pipeline: lint step from section 5 and a DNS check script for SPF/DKIM/DMARC in staging.
- Follow `testing-pyramid-and-shapes`; mock the provider port, not the MIME library.

## 9. What the agent must not claim

- That any change guarantees inbox placement, or that a domain "is whitelisted".
- Any threshold, quota or deadline not read from a current provider page.
- That DMARC `p=none` protects against spoofing, or that SPF alone is enough.
- That open tracking is reliable evidence of reading.
- Legal compliance (anti-spam and privacy law): say it needs counsel.

## Quick Decision Checklist

- [ ] Sending goes through a queue and an outbox row, with an idempotency key.
- [ ] Transactional and marketing use separate subdomains or streams.
- [ ] SPF, DKIM and DMARC published; DMARC reports read before tightening.
- [ ] Bounce and complaint webhooks verified, idempotent, feeding durable suppression.
- [ ] One-click unsubscribe headers and body link present on bulk or subscribed mail.
- [ ] Multipart message with plain-text part; MIME library; no hand-built headers.
- [ ] HTML lint and accessibility checks run in CI.
- [ ] No CR/LF in header values; enumeration-safe responses; tokens single-use and expiring.
- [ ] No secrets or PII in logs.
- [ ] Tests: template snapshots, SMTP sandbox, webhook replay.
- [ ] Final answer makes no deliverability guarantee and cites sources for numbers.

## Deep references

- [references/sources.md](references/sources.md): retrieved statuses, reading limits, claims not adopted.
- [references/protocols-and-domain-authentication.md](references/protocols-and-domain-authentication.md): SMTP, message format, submission, SPF, DKIM, DMARC status.
- [references/provider-requirements-and-list-hygiene.md](references/provider-requirements-and-list-hygiene.md): Google, Yahoo, Postmark, SES guidance, RFC 8058, bounces.
- [references/html-email-rendering-and-accessibility.md](references/html-email-rendering-and-accessibility.md): client support data, lint step, accessibility findings.
- [references/architecture-queue-webhooks-and-security.md](references/architecture-queue-webhooks-and-security.md): outbox, idempotency, webhooks, token and enumeration rules, testing.
