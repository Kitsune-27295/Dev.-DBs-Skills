# Architecture, Queue, Webhooks and Security

Sources: https://cheatsheetseries.owasp.org/cheatsheets/Email_Validation_and_Verification_Cheat_Sheet.html · https://postmarkapp.com/guides/transactional-email-bounce-handling-best-practices · https://docs.aws.amazon.com/ses/latest/dg/tips-and-best-practices.html · https://docs.aws.amazon.com/general/latest/gr/ses.html · https://support.google.com/mail/answer/14229414?hl=en · https://www.rfc-editor.org/rfc/rfc8058.html

Last verified 2026-11-25

Sources cover validation, verification, bounce handling and quotas. The queue, outbox and retry patterns below are general engineering practice owned by neighbor skills; they are not claims from these pages.

## Architecture

1. **Enqueue, do not send inline.** The request writes an outbox row in the same transaction as the business change, then a worker sends (`saga-transactional-outbox-pattern`, `background-worker-job-scheduler`).
2. **Idempotency.** A stable key per logical email; the worker claims the row (status `queued` to `sending`), sends, stores the provider message id, marks `sent`. A crash between send and mark can cause a duplicate, so make content safe to receive twice (`idempotency-fix`).
3. **Streams.** Transactional and marketing mail use separate subdomains or provider streams (Postmark and SES both advise this), separate queues and separate limits.
4. **Provider limits.** SES lists default quotas of 200 per 24 hours and 1 message per second per Region for a new account; Gmail documents a 4.7.28 quota response and a pause of at least 10 minutes. On throttling or temporary errors retry with exponential backoff and jitter, cap attempts, then dead-letter (`circuit-breaker-retry-telemetry`, `rate-limiter-throttler`).
5. **Webhooks.** Endpoint verifies the provider's signature or shared secret, parses with a schema, stores the raw event id for replay protection, returns quickly and processes asynchronously, and updates suppression (`validator-input-parser`). Postmark suggests also noting the event on the user's account, showing an in-app notice and offering a reactivation path.
6. **Port.** `EmailSender.send(message)` hides the provider; a fake implements it in tests.

## Security

- **Header injection.** Any CR or LF in subject, display name or address ends the message and starts a new header. Reject it at the edge and use the MIME library's header API.
- **Address validation.** OWASP: use a well-tested library, accept a broad range of valid formats, normalize Unicode and convert internationalized domains to punycode for comparison; prefer risk-based controls over blocking disposable domains.
- **Ownership proof.** Do not activate an account until the address is confirmed; a change of address needs confirmation at the new address (high-risk systems: both).
- **Tokens.** OWASP: time-limited, invalidated after use or expiry, cryptographically random (it states no minimum length). Store a hash, bind to user and purpose, and revoke older tokens on reissue (`authn-authz-guard`).
- **Enumeration.** Same response and similar timing whether or not the address exists, plus rate limiting and monitoring (OWASP). Send the "no account found" message to the address owner only if you want to inform them.
- **Logging.** No bodies, tokens, links with tokens or credentials; mask recipients.
- **Abuse.** Forms that send mail to user-supplied addresses can be used to harass or damage reputation; rate-limit per recipient and per source. SES also warns about role aliases planted as sabotage.

## Testing

- Template snapshot tests with fixtures; header assertions; fake `EmailSender` in unit tests.
- Integration tests against a local SMTP capture server or the provider sandbox; webhook replay and out-of-order tests; duplicate-send test by killing the worker between send and mark.
- Staging DNS check and a real-mailbox smoke test reading authentication results from headers.

## Examples (own)

- Outbox columns: `id, idempotency_key (unique), stream, template, to_hash, status, attempts, next_attempt_at, provider_message_id`.
- Reset endpoint contract: always 202 with a fixed body; the worker decides whether to mail.

## How an agent should apply this

1. Check these requirements in order: separation of streams, outbox plus idempotency, suppression, webhook verification, token rules, logging.
2. Link to the neighbor skill for each general mechanism instead of redesigning it.
3. Mark any provider-specific limit as needing confirmation from the user's own account.
4. Propose tests for each control; report which ones were actually run.
