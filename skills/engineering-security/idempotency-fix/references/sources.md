# Sources — Idempotency fix

Every URL below was re-fetched during the rebuild (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Stripe, Receive events in your webhook endpoint, https://docs.stripe.com/webhooks | 200 OK, read | Raw-body signature verification, 5-minute default tolerance (0 disables), retries up to three days in live mode, duplicates and event-id logging, ordering not guaranteed, quick 2xx, async queue advice |
| Stripe, Idempotent requests, https://docs.stripe.com/api/idempotent_requests | 200 OK, read | Key semantics: V4 UUID suggestion, up to 255 characters, saved first response including 500s, parameter mismatch error, 24-hour pruning (API v1), POST only |
| Stripe, Advanced error handling, https://docs.stripe.com/error-low-level | 200 OK, read | Retry only within 24 hours with same key and parameters, reconcile after, 409 for a concurrent same-key request, cart-id-derived keys, persist keys across restarts |
| IETF draft, https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/ | 200 OK, read: draft `-09`, active, updated 2026-11-21, expires 2027-05-25, not an RFC | `Idempotency-Key` header as a structured-field string; 422, 409 and 400 behaviors |
| Author's handout, https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software, section "2. Idempotência" | 200 OK, read | Check order (signature, insert id first, no arrival-order reliance, fast 2xx), outbound keys, `Idempotency-Key` on own endpoints, tests, no personal data as key |
| Video https://www.youtube.com/watch?v=G8SeOH0qerk | 200 OK but text truncated: only the title was readable | Nothing newly verified; the retry story rests on the 2026-11-24 read of a saved transcript, which had a gap near the end of the chapter |

## Reading limits

- No scripts in this skill; none run. The SQL sketch is illustrative and was not executed.
- Gateway facts come from Stripe only; other gateways were not read, so the skill says to check the one in use.
- Rebuild changes: Stripe retry duration, timestamp tolerance, key limits and retention, the in-flight 409 rule, the two-events-for-one-fact dedupe, "do not dedupe on created time" and the IETF draft status added; "id plus timestamp" reworded so the id alone is the key (about 8 corrections or additions).

## Claims not adopted as fact

- "Retried 10 times" from the video: the speaker's illustration, not a gateway default (Stripe documents up to three days of retries, not a count).
- The thousands-of-customers loss story: rhetorical, not measured.
- Anything in the lost part of the video transcript: not available; the SKILL wording rests on the visible part and the handout.
- The IETF draft: still a draft, so its status codes are suggestions, not a standard.
- That every gateway keeps keys for 24 hours or replays 500s: Stripe v1 behavior only.
