# Webhook retries and dedupe storage

Sources: video chapter "Idempotência: garantindo ações únicas" (7:11-13:26, https://www.youtube.com/watch?v=G8SeOH0qerk); handout section "2. Idempotência" (https://manodeyvin.com.br/p/fundamentos-de-engenharia-de-software) · Last verified 2026-11-24

## Why duplicates arrive

The video's scenario: a gateway sends "payment approved"; the app is overloaded or mid-deploy and does not return the expected 2xx in time; the gateway retries the same event, up to a configurable count. Each delivery enables the plan and sends an email again, and if the handler calls paid third-party APIs (the video's example: generating a welcome video or a digital product), each retry spends money. At scale this multiplies. Moral: delivery is at-least-once, so the handler must tolerate repeats.

## The dedupe record

The video's design is "stamped means paid": a processed-events table with the event id and a timestamp. First arrival: record the id, then do the work. Repeat arrival: the database rejects the duplicate id; the handler answers 200 and does nothing more. The handout makes the order explicit: insert the id first, and the id column is a unique key.

Own sketch:

```text
BEGIN
  INSERT INTO processed_events(event_id, received_at) VALUES (:id, now())
  -- unique violation: ROLLBACK, return 200
  enable_plan(user); queue_email(user)
COMMIT
```

Putting the insert and the effects in one transaction means a crash mid-way leaves no "processed" stamp (my inference; whether to include external calls in that transaction is a design choice, and effects that cannot be rolled back, such as emails, are better queued after commit). A concurrent duplicate blocks on the unique key rather than double-processing, the same mechanism as in `race-condition-fix`.

## Why not an in-process `if`

The video: two requests to the same endpoint do not share memory, and object state is not persisted, so a flag cannot remember across requests or restarts. The shared persistent store is the database.

## Keys on the three sides

| Side | Mechanism (handout) |
|---|---|
| Inbound webhooks | Verify signature on the raw body; unique event id; do not depend on arrival order, fetch current state from the gateway when it matters; reply 2xx fast, defer heavy work only if a queue already exists |
| Outbound gateway calls | A UUID v4 idempotency key per business operation, reused across retries of that operation |
| Own create-order or create-payment endpoints | Accept an `Idempotency-Key` header and replay the same response for a repeated key |

Guardrails from the handout prompt: never change prices or billing rules; never use personal data such as email or tax id as the key.

## Failure modes (own analysis)

- Generating a fresh key per retry defeats the key; generate once per business operation.
- Verifying the signature after parsing the body can fail, since parsing may alter bytes; hence the raw-body rule.
- Stamping the event before the work and then crashing can lose the event; decide between stamp-then-work in one transaction or a status column.

## How an agent should apply this

- Inventory every webhook and every charging or credit endpoint with `file:line`.
- Add the processed-events table through a reviewed migration; do not alter existing tables.
- Treat "already processed" as success (2xx), not an error, so the sender stops retrying.
- Write both tests: same event twice sequentially, and twice concurrently.
- Confirm outbound idempotency keys with the gateway's own documentation before relying on them (not verified here).
