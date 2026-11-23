# Unit of Work and Transaction Scope

Sources: https://martinfowler.com/eaaCatalog/unitOfWork.html · https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design · Last verified 2026-11-23

## Definition
Fowler: a Unit of Work tracks everything done during a business transaction that can affect the database, and at the end works out what to write and coordinates the writes and concurrency handling. The catalog page is a summary only; caller-versus-object registration is in PoEAA ch. 11 and was NOT read from source here (the following mechanics are well-established general knowledge, labelled as such).

## Problem it solves (from the page)
- Loaded objects that change must be tracked or they are not written back; new objects must be inserted, removed ones deleted.
- Writing on every change means many small database calls.
- Holding a database transaction open for a whole business interaction is impractical across requests.
- Tracking what was read helps avoid inconsistent reads.

## Mechanics (general knowledge, not from the page)
1. Register new/dirty/removed objects (caller registration, object self-registration, or ORM change tracking via an identity map).
2. On `commit`, compute the change set, order inserts/updates/deletes by dependency.
3. Open one database transaction, apply, commit; on failure roll back and discard the unit.
4. Optionally detect concurrency conflicts (version column / optimistic check).

## Microsoft guidance
A unit of work is a single transaction with multiple insert/update/delete operations for one user action (e.g. a registration), executed in one go when the application layer commands it. Entity Framework's `DbContext` implements both Repository and Unit of Work; `SaveChanges` is the commit. Grouping reduces chatty calls, lock time and inconsistency risk. The pattern works with or without repositories.

## Scope rules
| Rule | Why |
|---|---|
| One unit per command/use case, created and committed in the application layer | Domain code must not decide transaction boundaries |
| One aggregate modified per transaction by default | Aggregate is the consistency boundary; cross-aggregate consistency is eventual (`saga-transactional-outbox-pattern`, `event-driven-architecture`) |
| Repositories participate in the ambient unit; they never commit | Single commit point |
| Do not keep a unit open across user think-time or remote calls | Long locks, stale data |
| Publish domain events/outbox rows inside the same unit | Atomic state change and message |
| Retry whole unit on transient/optimistic-conflict failure, idempotently (`idempotency-fix`) | Units must be replayable |

## Sketch
```
def handle(cmd, uow):
    with uow:                       # begin
        order = uow.orders.get(cmd.order_id)
        order.confirm()             # domain behavior
        uow.outbox.add(OrderConfirmed(order.id))
        uow.commit()                # one transaction
```

## Failure modes
Commit inside a repository; two units sharing one connection by accident; saving in a loop per row; swallowing the exception then continuing with a poisoned unit; mixing unit-of-work scope with HTTP request scope so background jobs reuse a dead context.

## How an agent should apply this
- Locate where commits happen; there should be one per use case, outside repositories and entities.
- If the ORM already is a unit of work, do not wrap it in another abstraction unless a port is needed for testing or storage swap.
- Flag multi-aggregate writes in one transaction and propose events/outbox instead.
- Confirm outbox/event writes share the unit; for transaction bugs defer to `transaction-fix`.
- Add concurrency tokens where lost updates are possible.
