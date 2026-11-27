---
name: idempotency-fix
description: "Make a webhook handler, payment endpoint or any retried operation have one effect however many times the same event or request arrives (duplicate emails, credit added twice, double subscription, repeated paid third-party calls); also audits webhook handlers and charge calls. Adds signature verification on the raw body, a processed-events table with a unique event id, idempotency keys on outbound and inbound calls, and tests that send the same event twice and at the same time. Use when a retry, redelivery or double click repeats an effect. Not for different users racing for a limited resource (use race-condition-fix) or a failure midway through several writes (use transaction-fix)."
---

# Idempotency fix

One idea: **delivery is at-least-once, so persist "this was handled" where every request and every restart can see it.** Idempotent means repeating an operation any number of times gives the result of doing it once. Gateways retry a webhook when the receiver is slow, deploying or down, so the same event arrives again and the plan is enabled, the email sent, the paid API called twice. Verified facts and claims not adopted: [references/sources.md](references/sources.md). Start with the shared safety rules of `fundamentals-audit`.

## 1. Why a table and not an `if`

An in-process flag is not shared between requests or instances and dies with the process. Persist the fact in the database. No Redis needed. The unique constraint is the guard, the same mechanism as in `race-condition-fix`: two simultaneous inserts of one id must leave one row.

## 2. Inventory

Every inbound webhook and every endpoint that charges, enables a plan, credits a balance or sends transactional email. Done when each has `file:line`. Show the plan before coding.

## 3. Inbound webhooks, each one

1. Verify the signature against the **raw body** before any processing; a framework that parses and re-serializes the body breaks verification. Reject timestamps outside a tolerance (Stripe's libraries default to 5 minutes); never set tolerance to 0.
2. Create a **processed-events** table with the provider's event id as the unique key (plus a received-at column for audit; do not dedupe on the event's creation time, which can be shared by distinct events).
3. On arrival, insert the id first; if it already exists, answer 2xx and stop. A repeat is success, not an error, so the sender stops retrying.
4. Do not rely on arrival order: when current state matters, fetch the object from the gateway API.
5. Answer 2xx quickly; move heavy work to a queue or async job only if the project already has one.
6. Some providers can emit two distinct events for one fact; if so, also dedupe on the object id plus event type.

Design caveat: stamping the id and then crashing before the work loses the event. Do the stamp and the writes in one transaction (`transaction-fix`), or keep a status column (received, done) and retry unfinished rows. Effects that cannot roll back, such as email, are queued after commit.

## 4. Calls you make to a gateway

Send an **idempotency key** (UUID v4 or similar random string) generated once per business operation and reused on every retry of it, including across process restarts: generate and persist it. Reusing a key with different parameters is rejected by Stripe; keys can expire (Stripe: at least 24 hours kept, up to 255 characters). If the outcome is unknown after the retention window, reconcile by reading the object instead of retrying. Check the gateway's own rules; they differ.

## 5. Your own endpoints

An endpoint that creates an order or payment accepts an `Idempotency-Key` header and returns the same response when the key repeats. The IETF HTTPAPI draft (still a draft, not an RFC) suggests 422 for a reused key with a different payload, 409 for a retry while the first request is still running, and 400 for a missing required key.

## 6. Tests

The same event sent twice, and twice at the same time (concurrent), prove the effect happens once (`integration-tests`).

## Rules

- The processed-events table is a new migration: a human reviews it before it runs. Do not touch existing tables when a new one does the job.
- Never change amounts, prices or billing rules.
- Never use personal data (email, tax id) as an idempotency key.

## Quick Decision Checklist

- [ ] Did I inventory every webhook and every endpoint that charges, enables a plan, credits or sends email, with file:line?
- [ ] Is the webhook signature verified against the raw body, with a timestamp tolerance, before any processing?
- [ ] Is the event id saved in a processed-events table with a unique key, and a repeat answered 2xx and stopped?
- [ ] Are the stamp and the effects safe against a crash between them?
- [ ] Am I fetching current state from the gateway instead of relying on arrival order?
- [ ] Do my own outbound gateway calls send an idempotency key reused on every retry?
- [ ] Do my create endpoints accept an Idempotency-Key header and return the same response on repeats?
- [ ] Is there a test sending the same event twice, and twice concurrently?
- [ ] Is the new table a migration a human reviews, with no personal data used as a key?

## Deep references

- [references/webhook-retries-and-dedupe-storage.md](references/webhook-retries-and-dedupe-storage.md): read when designing the processed-events table and the key rules.
- [references/trigger-evals.md](references/trigger-evals.md): read when tuning the description or checking the boundary with neighbors.
- [references/sources.md](references/sources.md): read to see what was verified on 2026-11-27, reading limits and claims not adopted.
