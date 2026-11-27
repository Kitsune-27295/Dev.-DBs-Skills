# Usage-priced databases: how reads add up (Firestore as the worked case)

Sources: Firestore pricing https://firebase.google.com/docs/firestore/pricing; video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI) chapter 05 21:28-24:10; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe section "4. Susto no final do mês" · Last verified 2026-11-24

## Meter vs rent

The lesson contrasts a taxi meter (pay per read, write and traffic) with renting (a VPS or fixed instance: same price for ten or ten million queries). Before launch, know which one you have; the audit's first question is the billing model.

## What the Firestore pricing page says counts

- Billable units: reads, writes, deletes, index entries read, storage (index overhead included) and network.
- A document returned by a query is a read. Index entries add reads in batches of up to 1,000 (with exceptions the page lists).
- Each query costs at least one read, even with zero results.
- Writes and deletes are billed per document.
- Free daily quota (one free database per project): 50,000 reads, 20,000 writes, 20,000 deletes. Figures change; recheck the page.

## The patterns that multiply reads

| Pattern | Mechanic | Evidence |
|---|---|---|
| N+1 | A list of 500 orders, then one fetch per order's customer = 501 reads where a single query would do | Video's arithmetic |
| Offset pagination | You are charged a read for each skipped document: offset 10 returning 1 doc costs 11 reads | Pricing page; cursors avoid this |
| Real-time listener | A read each time a document in the result set is added or updated (and when one leaves it by changing); a listener offline over 30 minutes is billed as a new query; without offline persistence every reconnect is a new query | Pricing page |
| Unbounded query | No limit means every match is returned and billed; the Firebase billing guide warns about queries that could return millions | Firebase page |
| Security rules with `get()`/`exists()` | Extra reads for the documents the rule touches | Pricing page |

Correction of an oversimplification: the video says a listener "listens to the whole collection"; the page says billing is per document added or updated in the result set. A listener on a large, frequently changing collection is still expensive.

## Estimating for 10 times the users (method from the prompt)

```
reads_per_user_per_day = screens_opened * documents_per_screen
        + listener_updates_per_day
monthly_reads = reads_per_user_per_day * users * 10 * 30
cost = (monthly_reads - free_quota) / 100000 * price_per_100k   # price from the current page
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
