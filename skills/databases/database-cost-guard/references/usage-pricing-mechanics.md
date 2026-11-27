# Usage-priced databases: how reads add up (Firestore as the worked case)

Sources: Firestore pricing https://firebase.google.com/docs/firestore/pricing; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "End-of-month scare" · Last verified 2026-11-27

## Meter vs rent

The lesson contrasts a taxi meter (pay per read, write and traffic) with renting (a VPS or fixed instance: same price however many queries). Before launch, know which one you have; the audit's first question is the billing model.

## What the Firestore pricing page says counts

- You are charged for documents and index entries read to satisfy a query; each write and delete is billed separately.
- Every query costs at least one read, even with zero results.
- Index entries are billed one read per batch of up to 1,000, but queries with at most one range field are not charged for index entries.
- Free daily quota (one free database per project): 1 GiB stored, 50,000 reads, 20,000 writes, 20,000 deletes, 10 GiB outbound per month. Figures change; recheck the page.

## The patterns that multiply reads

| Pattern | Mechanic | Evidence |
|---|---|---|
| N+1 | A list of 500 orders, then one fetch per order's customer = 501 reads where a single query would do | Lesson's arithmetic |
| Offset pagination | A read is charged for each skipped document: offset 10 returning 1 doc costs 11 reads; cursors avoid this | Pricing page |
| Real-time listener | A read each time a document joins the result set or changes inside it, and when one leaves it by changing (a delete is not a read); a listener offline over 30 minutes is billed as a new query when offline persistence is on, and every reconnect is a new query when it is off | Pricing page |
| Unbounded query | No limit means every match is returned and billed; the Firebase billing guide warns about queries that could return millions | Firebase page |
| Security rules with `get()`/`exists()`/`getAfter()` | One extra read per dependent document; rule evaluation is billed once per request, and listeners incur rule charges again on updates and reconnects | Pricing page |

The lesson says a listener "listens to the whole collection"; the page bills per document added or updated in the result set. A listener on a large, frequently changing collection is still expensive.

## Estimating for 10 times the users (method from the prompt)

```
reads_per_user_per_day = screens_opened * documents_per_screen
        + listener_updates_per_day
monthly_reads = reads_per_user_per_day * users * 10 * 30
cost = (monthly_reads - free_quota_reads) * price_per_read   # price from the current page
```
Show the arithmetic; do not hard-code prices (they change).

## Fixes in order of simplicity

Replace the loop with one query or `IN`; scope listeners to what the screen shows; use cursors; add limits; cache results (inference).

## How an agent should apply this

- Identify the billing model first; if the code does not say, ask.
- Find loops, listeners, offsets and unbounded queries with `file:line`; estimate reads per user per day and cost at 10x.
- Use the provider's current pricing page for any figure and cite it.
- Propose the smallest fix per item; do not switch provider or change business rules.
- Hand the list and plan to the owner before editing files.
