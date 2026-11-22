---
name: idempotency-fix
description: Use when a webhook, payment endpoint or any retried operation must have one effect no matter how many times it arrives (duplicate emails, credit added twice, double subscription, repeated calls to third-party APIs), or when auditing webhook handlers and charge calls. Adds signature verification, a processed-events table, idempotency keys and tests that send the same event twice and at the same time.
---

# Idempotency fix

Idempotent means repeating an operation any number of times gives the result of doing it once. Gateways retry a webhook when the receiver is slow, deploying or down: the same event arrives again and the plan is enabled, the email sent, the external API called twice. Multiplied by ten retries and a thousand customers, that is financial loss. Start with the shared safety rules of `fundamentals-audit`.

## Why a table and not an `if`

An in-process flag or variable is not shared between requests and dies with the process. Persist the fact "this event was handled" in the database, which every request shares and which survives a restart. No Redis needed.

## Steps

1. **Inventory:** every inbound webhook and every endpoint that charges, enables a plan, credits a balance or sends transactional email. Done when each has `file:line`.
2. **Webhooks**, each one:
   1. verify the signature against the **raw body** before any processing;
   2. create a **processed-events** table with the event id as unique key (id plus timestamp);
   3. on arrival, insert the id first; if it already exists, answer 200 and stop;
   4. do not rely on arrival order: when current state matters, fetch the object from the gateway API;
   5. answer 2xx fast and move heavy work to a queue or async job only if the project already has one.
3. **Calls you make** to the gateway (charge, subscription, refund): send an **idempotency key** (UUID v4) generated once per business operation and reused on every retry of it.
4. **Your own endpoints** that create an order or payment: accept an `Idempotency-Key` header and return the same response when the key repeats.
5. **Tests:** the same event sent twice, and twice at the same time (concurrent), prove the effect happens once. See `integration-tests`.

## Rules

- Plan first, then code. The processed-events table is a new migration: a human reviews it before it runs. Do not touch existing tables when a new one does the job.
- Never change amounts, prices or billing rules.
- Never use personal data (email, tax id) as an idempotency key.
- The unique constraint is the guard; the concurrent test proves it. Two simultaneous inserts of one id must leave one row, which is the same mechanism as in `race-condition-fix`.
