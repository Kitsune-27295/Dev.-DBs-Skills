# Choosing a database: the reasoning behind "default to Postgres"

Sources: video "Banco de Dados | Fundamentos para Vibe Coders #EP2" (mano deyvin, 2026-11-12, https://www.youtube.com/watch?v=TL4T9ZESamI), chapter 01 02:07-06:25; handout https://manodeyvin.com.br/p/banco-de-dados-fundamentos-para-vibe, section "Qual banco usar" · Last verified 2026-11-24

## The author's four families

The lesson sorts storage into four families by what the data looks like and how it will be asked about.

| Family | Examples named | Author's use case | Author's warning |
|---|---|---|---|
| Relational | Postgres, MySQL | Customers, orders, payments: things that relate | None; the recommended default |
| Document | MongoDB, Firestore | Data with no fixed shape: big logs, a form whose fields keep changing | Hard to ask a question across all records |
| Key-value | Redis | Cache, session data, anything temporary that may vanish | Not a place for data you must keep |
| Backend-as-a-service | Supabase, Firebase | Rented database plus login plus API, convenient for beginners | Supabase is Postgres underneath; Firebase's Firestore is a document store |

The analogy: a relational table is a credit notebook where every page has the same columns, so "who owes more than 100" is one glance at one column. A document store is a drawer of loose notes, each with different content; the same question means going note by note (the database automates that, but it still costs work).

## The decision rule

"When in doubt, Postgres." The stated reasons: customers, orders and payments are relations (one customer has many orders, one order has many payments), and a relational engine enforces those relations. The handout adds that Supabase is Postgres underneath, so choosing it does not give up the relational model.

## Trade-offs the lesson implies (marked as inference)

- Inference: with a document store, constraints, joins and multi-record consistency move into application code, which is where AI-generated code tends to be weakest. This is why `schema-and-constraints` and `transaction-fix` assume a relational engine.
- Inference: usage-priced stores add a cost dimension that a fixed-price instance does not have. The lesson covers this in chapter 05 (see `database-cost-guard`): a VPS bills a flat price whether it serves ten or ten million queries, while per-read pricing bills each one.
- Inference: a backend-as-a-service shifts the security boundary to access rules in the database itself (see `database-exposure`).
- The lesson also says Redis content should be anything you can afford to lose. This is the author's rule; check durability settings before relying on it.

## Where the lesson is opinion, not evidence

The remarks about "front-end developers who bought a course and wanted Mongo everywhere" and about disliking backend-as-a-service are the author's taste. Document stores are legitimate for the cases listed above. An audit should state the reason for the recommendation in one sentence and leave the decision to the owner.

## Example: one-sentence recommendation

```
Stack found: Firestore, orders and payments stored as nested documents.
Recommendation: relational data with money inside; consider Postgres.
Reason: orders-payments relations and totals need constraints and transactions.
Cost of the move: data migration; owner decides. This audit does not migrate.
```

## How an agent should apply this

- Recommend a relational engine (Postgres) when the app stores money, users, orders or other related records; say the reason in one sentence.
- Do not recommend a document store for relational data just because the code already uses one; flag the trade-off and let the owner decide.
- Treat key-value stores as disposable by default; ask where durable data lives.
- Never propose or perform a data migration during the audit.
- Label the lesson's stance as opinion when quoting it in a report.
