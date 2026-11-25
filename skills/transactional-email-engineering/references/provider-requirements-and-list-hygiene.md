# Provider Requirements and List Hygiene

Sources: https://support.google.com/mail/answer/81126?hl=en · https://support.google.com/mail/answer/14229414?hl=en · https://senders.yahooinc.com/best-practices/ · https://www.rfc-editor.org/rfc/rfc8058.html · https://postmarkapp.com/guides/transactional-email-bounce-handling-best-practices · https://postmarkapp.com/guides/transactional-email-best-practices · https://docs.aws.amazon.com/ses/latest/dg/tips-and-best-practices.html · https://docs.aws.amazon.com/general/latest/gr/ses.html

Last verified 2026-11-25

## What the providers say (as retrieved)

**Google (Gmail).** All senders (enforced from February 1, 2024): SPF or DKIM, valid forward and reverse DNS, TLS, RFC 5322 format, no impersonation of Gmail From headers, and spam rate in Postmaster Tools below 0.3%. Bulk senders ("close to 5,000 messages or more" to personal Gmail accounts within 24 hours) must have SPF and DKIM and DMARC (policy may be `none`), From-domain alignment with the SPF or DKIM domain, and one-click unsubscribe with a visible body link for marketing and subscribed mail. The recommended spam-rate target is below 0.1%, and the page says to avoid reaching 0.3%. Unsubscribe requests should be honored within 48 hours. Gmail returns 4.7.28 on a quota error and the page says to pause at least 10 minutes.

**Yahoo.** All senders: SPF or DKIM, valid forward and reverse DNS, RFC 5321/5322 compliance, complaint rate below 0.3%. Bulk senders: SPF and DKIM, DMARC at least `p=none` that passes, `rua` strongly recommended, working List-Unsubscribe with one-click (the RFC 8058 POST method is highly recommended), visible body link, honor unsubscribes within 2 days. Yahoo computes complaint rate from inbox-delivered mail. The page gives no bulk volume threshold and recommends DKIM keys of at least 1024 bits.

**Postmark.** Separate transactional and marketing streams or subdomains; authenticate SPF, DKIM, DMARC and a custom Return-Path; avoid no-reply; include a plain-text part; allow unsubscribing for non-essential mail. Bounces: hard bounces are permanent, so stop sending; soft bounces are retried but repeated ones can be treated as hard; spam complaints should be treated as intentional; keep bounce handling in your own app (note on the account, in-app notice, alternative channel). The page's bounce-type percentages are Postmark-wide and are not benchmarks.

**Amazon SES.** Use subdomains per mail type; avoid no-reply; sign with DKIM and publish SPF; double opt-in; validate that addresses are well-formed with an MX; do not pass unchecked user input through; role aliases (postmaster, abuse, noc) can be planted to hurt reputation. The general-reference page lists default quotas of 200 per 24 hours and 1 message per second per Region for a new account, adjustable on request. The SES best-practices index page itself only links to sub-pages.

## One-click unsubscribe (RFC 8058)

- Message carries `List-Unsubscribe` with exactly one HTTPS URI (other URIs such as mailto may coexist) and `List-Unsubscribe-Post: List-Unsubscribe=One-Click`.
- A valid DKIM signature must cover both headers (`h=`); receivers should not offer one-click without it.
- The URI must identify recipient and list with no further input, should hold an opaque hard-to-forge component that the server verifies, and must not redirect the POST.
- The receiver POSTs the key/value as body, without cookies or authorization. Serve the same endpoint for manual GET unsubscribes.

## Suppression model

Keep one durable table keyed by normalized address (and stream): reason (hard bounce, complaint, unsubscribe, manual), timestamp, source event id. Check it in the worker immediately before send. Reactivation is an explicit, audited action, and spam complaints are not reactivated by the app.

## Examples (own)

- Unsubscribe endpoint: `POST /u/<opaque>` returns 200 with empty body and idempotently marks the subscription off; `GET` renders a confirmation page and uses the same handler.
- Bounce policy in config: `soft_bounce_max_attempts` documented with the provider page and review date, not a magic number.

## How an agent should apply this

1. Quote a threshold only with its provider and page; say "as of the date read" and tell the user to re-check.
2. Separate message classes first (transactional, subscribed, marketing), then decide which need unsubscribe headers.
3. Build suppression before sending volume; treat webhooks as the source of truth for bounces and complaints.
4. Do not promise reputation outcomes; list the controls that reduce known risks.
