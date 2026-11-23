# Azure CQRS Pattern: Models, Stores and Event Sourcing

Sources: https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs (PT-PT version is the same article, not re-read) · Last verified 2026-11-23

## Problem with one CRUD model

As load grows, a single model suffers: **data mismatch** (update fields not needed for display), **lock contention** from parallel operations, **performance** cost from complex retrieval queries, and **security** overlap exposing data in unintended contexts.

## Commands and queries

- Commands express business tasks, not field edits: `BookHotelRoom`, not "set status to Reserved". Make them likelier to succeed with client-side pre-validation (disable Book when no rooms), server-side handling of races (waiting list, alternatives for the last room) and optionally asynchronous processing via a queue.
- Queries never mutate; they return DTOs shaped for display with no domain logic.
- Cost: ORM scaffolding cannot generate CQRS code from a schema; custom glue is needed.

## Two levels of separation

| Level | Write side | Read side | Consistency |
|---|---|---|---|
| Single data store | Domain logic, validation, transactional integrity | DTO projections, no domain logic | Immediate |
| Separate stores | e.g. relational | e.g. document DB, materialized view, read replicas | Eventual |

With separate stores the write side usually publishes events that refresh the read model. Because broker and database cannot share one distributed transaction, the page recommends the **Transactional Outbox** (persist state change and event atomically) and an **idempotent** read-model consumer for duplicates.

## Benefits listed

Independent scaling, schemas optimized per side, tighter write permissions, cleaner separation of concerns (complex logic write-side, simple read-side), simpler queries via materialized views.

## Problems listed

Complexity (worse with Event Sourcing), messaging failures/duplicates/retries, and eventual consistency including users acting on stale data.

## Use when / avoid when

Use: collaborative multi-user data (fine-grained commands cut conflicts), task-based UIs with rich domain models, reads far outnumber writes, separate teams for read and write sides, evolving rules, integration with event-sourced systems. Avoid: simple domain or business rules, CRUD UI is sufficient.

## Combined with Event Sourcing

The event store is the write model and single source of truth; the read model builds denormalized materialized views from events and can be rebuilt by replay, acting like a durable read-only cache. Costs: lag, a different design approach, and view-generation expense. Mitigation: periodic snapshots instead of replaying full history.

## Example: command handler skeleton (inference-free, mirrors the page's shape)

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
- When splitting stores, add an outbox and an idempotent projector in the same design; never dual-write.
- Plan the UI for stale reads (pending state, version check) before promising separate stores.
- Define projection rebuild and snapshot strategy if Event Sourcing is in play.
- Apply the same authorization to read projections as to commands.
