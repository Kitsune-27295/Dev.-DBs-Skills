# Unit of Work and Transaction Scope

Sources: https://martinfowler.com/eaaCatalog/unitOfWork.html · https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design · Last verified 2026-11-27

## Definition
Fowler: a Unit of Work tracks everything done during a business transaction that can affect the database, and at the end works out what to write and coordinates the writes and concurrency handling. The catalog page is a summary only; caller-versus-object registration is in PoEAA ch. 11 and was NOT read from source here (the following mechanics are well-established general knowledge, labeled as such).

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

## Scope rules and sketch

Owned by `SKILL.md` section 3 (one unit per use case, repositories never commit, one aggregate per transaction, outbox in the same unit, no unit across think time, idempotent retry, concurrency tokens). Not repeated here.

## Failure modes
Commit inside a repository; two units sharing one connection by accident; saving in a loop per row; swallowing the exception then continuing with a poisoned unit; mixing unit-of-work scope with HTTP request scope so background jobs reuse a dead context.
