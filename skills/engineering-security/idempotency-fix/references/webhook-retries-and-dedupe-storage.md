# Webhook retries and dedupe storage

Sources: Stripe webhooks guide (https://docs.stripe.com/webhooks); Stripe idempotent requests (https://docs.stripe.com/api/idempotent_requests); Stripe advanced error handling (https://docs.stripe.com/error-low-level); IETF draft (https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/); handout section "2. Idempotência" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-27

Stripe is used as one concrete gateway; other gateways differ, so read the one in use.

## Why duplicates arrive

A gateway sends "payment approved"; the app is overloaded or mid-deploy and does not return a 2xx in time; the gateway retries. Stripe retries live-mode events for up to three days with exponential backoff, and its docs say endpoints may occasionally receive the same event more than once. Manual resends also exist (dashboard up to 15 days, CLI up to 30). Each delivery would enable the plan and send an email again, and each paid third-party call would cost money again. Moral: delivery is at-least-once, the handler must tolerate repeats. Event order is not guaranteed either.

## The dedupe record

"Stamped means done": a processed-events table whose unique key is the event id. First arrival: record the id, then do the work. Repeat: the database rejects the duplicate id; answer 2xx and do nothing more. Stripe advises logging processed event ids and not using the event's `created` time (seconds resolution, shared by distinct events) to decide order or duplication. In some cases two separate Event objects describe one fact; match those on the `data.object` id plus the event type.

Own sketch:

```text
BEGIN
  INSERT INTO processed_events(event_id, received_at) VALUES (:id, now())
  -- unique violation: ROLLBACK, return 2xx
  enable_plan(user); queue_email(user)
COMMIT
```

One transaction means a crash midway leaves no stamp, so the redelivery redoes the work (inference). Effects that cannot be rolled back, such as email, are queued and sent after commit (`transaction-fix`). A concurrent duplicate blocks on the unique key rather than double-processing (`race-condition-fix`). Stripe also says to return 2xx before complex logic and to process events from an asynchronous queue to survive spikes; use a queue only if the project already has one, and store the id before or with enqueueing.

## Why not an in-process `if`

Two requests, or two instances, do not share memory, and process state is lost on restart. The shared persistent store is the database.

## Keys on three sides

| Side | Mechanism |
|---|---|
| Inbound webhooks | Verify the signature on the raw body (framework body manipulation breaks it); signed timestamp checked against a tolerance (5 minutes default in Stripe's libraries; 0 disables the check); unique event id; fetch current state when order matters; reply 2xx fast |
| Outbound gateway calls | One random key per business operation (UUID v4 or similar), reused on every retry; Stripe stores the first response, including 500s, keyed by it, rejects the same key with different parameters, keeps keys at least 24 hours, allows up to 255 characters, and says not to put sensitive data in them. Retry within the window; after it, reconcile instead. A key derived from a cart id is another valid pattern |
| Own create endpoints | Accept an `Idempotency-Key` header and replay the same response. The IETF draft (`-09`, active Internet-Draft, last updated 2026-11-21, not an RFC) specifies the value as a structured-field string and suggests 422 for a different payload, 409 while the first request is in flight, 400 if a required key is missing; payload mismatch detection needs request fingerprints, which are optional |

Guardrails: never change prices or billing rules; never use personal data such as email or tax id as the key.

## Failure modes (own analysis)

- A fresh key per retry defeats the key; generate once per business operation and persist it across restarts.
- Verifying the signature after parsing the body can fail; hence the raw-body rule.
- Stamping the event before the work and then crashing can lose the event; use one transaction or a status column.
- A key that expires before your last retry executes the operation again; track the window.

## How an agent should apply this

- Inventory every webhook and every charging or credit endpoint with `file:line`.
- Add the processed-events table through a reviewed migration; do not alter existing tables.
- Treat "already processed" as success (2xx), not an error.
- Write both tests: same event twice sequentially, and twice concurrently.
- Confirm outbound key rules (length, retention, replay) in the gateway's own documentation.
