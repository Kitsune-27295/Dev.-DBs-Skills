# Choosing a database: the reasoning behind "default to Postgres"

Sources: author's handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "Qual banco usar" (re-read); video https://www.youtube.com/watch?v=TL4T9ZESamI (not re-verified) · Last verified 2026-11-27

## The author's families

The lesson sorts storage by what the data looks like and how it will be asked about. Verified in the handout: relational and document only; the other two rows come from the video and are unconfirmed this round.

| Family | Examples named | Author's use case | Author's warning |
|---|---|---|---|
| Relational | Postgres, MySQL | Things that relate: customers, orders, payments | Recommended default |
| Document | MongoDB, Firestore | Data with no fixed shape; easy at first | Hard to ask a question across all records (handout) |
| Key-value (video only) | Redis | Cache, session data, anything that may vanish | Not for data you must keep |
| Backend-as-a-service (video only) | Supabase, Firebase | Rented database plus login plus API | Supabase is Postgres underneath (handout confirms); Firestore is a document store |

The handout's analogy: a relational table is a credit notebook where every page has the same columns, so "who owes more than 100" is one glance at one column; a document store is a drawer of loose papers, easy at first and harder to query across.

## The decision rule

"When in doubt, Postgres." Reasoning: customers, orders and payments are relations (one customer has many orders, one order many payments), and a relational engine enforces them; Supabase runs on Postgres, so choosing it keeps the relational model (handout).

## Trade-offs the lesson implies (marked as inference)

- With a document store, constraints, joins and multi-record consistency move into application code, where AI-generated code tends to be weakest. This is why `schema-and-constraints` and `transaction-fix` assume a relational engine.
- Usage-priced stores add a cost dimension (per read or write) that a flat-priced instance lacks; see `database-cost-guard`. Managed Postgres hosts may also bill by usage, so check the plan rather than assume.
- A backend-as-a-service shifts the security boundary to access rules in the database itself (`database-exposure`).
- Redis content as "anything you can afford to lose" is the video author's rule; check durability settings before relying on it.

## Where the lesson is opinion, not evidence

Remarks about front-end developers wanting Mongo everywhere, and dislike of backend-as-a-service, are taste. Document stores are legitimate for the cases listed. State the reason in one sentence and leave the decision to the owner.

## Example: one-sentence recommendation

```
Stack found: Firestore, orders and payments stored as nested documents.
Recommendation: relational data with money inside; consider Postgres.
Reason: order-payment relations and totals need constraints and transactions.
Cost of the move: data migration; owner decides. This audit does not migrate.
```

## How an agent should apply this

- Recommend a relational engine (Postgres) when the app stores money, users, orders or other related records; give the reason in one sentence.
- Do not recommend a document store for relational data only because the code already uses one; flag the trade-off.
- Treat key-value stores as disposable by default; ask where durable data lives.
- Never propose or perform a data migration during the audit.
- Label the lesson's stance as opinion when quoting it in a report.
