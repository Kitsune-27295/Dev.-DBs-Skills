# Azure CQRS Pattern: Models, Stores and Event Sourcing

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs (page dated 2025-02-20, platform update stamp 2026-10) · Last verified 2026-11-27

## Problem with one CRUD model

As load grows, a single model suffers: **data mismatch** (update fields not needed for display), **lock contention** from parallel operations, **performance** cost from complex retrieval queries, and **security** overlap exposing data in unintended contexts.

## Commands and queries

- Commands express business tasks, not field edits: `BookHotelRoom`, not "set status to Reserved". Make them likelier to succeed with client-side pre-validation (disable Book when no rooms), server-side handling of races (waiting list, alternatives for the last room) and optionally asynchronous processing via a queue.
- Queries never mutate; they return DTOs shaped for display with no domain logic.
- Cost: ORM scaffolding cannot generate CQRS code from a schema; custom glue is needed.

## Two levels of separation

| Level | Write side | Read side | Consistency |
|---|---|---|---|
| Single data store (the page calls it the foundational level) | Domain logic, validation, transactional integrity | DTO projections, no domain logic | No replication lag (inference: same store) |
| Separate stores (the advanced level) | e.g. relational | e.g. document DB, materialized view, read replicas | Eventual (the page says reads may be stale) |

With separate stores the write side usually publishes events that refresh the read model. Because broker and database usually cannot share one distributed transaction, the page recommends the Transactional Outbox and an idempotent read-model consumer; both are owned by `saga-transactional-outbox-pattern`.

## Benefits listed

Independent scaling, schemas optimized per side, security (only the right entities and operations may write), cleaner separation of concerns, simpler queries via materialized views.

## Problems listed

Complexity (notably with Event Sourcing), messaging failures, duplicates and retries (messaging itself is not required by CQRS), and eventual consistency including users acting on stale data.

## Use when / avoid when

Use: collaborative multi-user data (fine-grained commands cut conflicts), task-based UIs with rich domain models, performance tuning where reads outnumber writes, separate teams for read and write sides, evolving systems, integration with event-sourced systems. Avoid: simple domain or business rules, or when a CRUD UI is sufficient.

## Combined with Event Sourcing

The event store becomes the write model and read models are materialized views rebuilt by replay; the page warns about lag, extra complexity and view-generation cost and suggests snapshots. Projections, snapshots and costs are owned by `event-sourcing-pattern`.

## Example: command handler skeleton (mirrors the page's C# shape)

```python
class RateProduct:                     # task-based command
    id: UUID; product_id: int; user_id: int; rating: int

def handle(cmd: RateProduct, repo):
    p = repo.find(cmd.product_id)
    if p: p.rate(cmd.user_id, cmd.rating); repo.save(p)   # write model only
# read side: ProductDao.find_by_id(id) -> ProductDisplay (DTO, no logic)
```

## How an agent should apply this

- Name commands after business intent and reject `UpdateX` commands with many nullable fields.
- When splitting stores, design the sync path with `saga-transactional-outbox-pattern`; never dual-write.
- Plan the UI for stale reads (pending state, version check) before promising separate stores.
- Define projection rebuild and snapshot strategy if Event Sourcing is in play.
- Apply the same authorization to read projections as to commands.
