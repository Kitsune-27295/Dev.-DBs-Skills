# Data Transfer Object and Assembler

Sources: https://martinfowler.com/eaaCatalog/dataTransferObject.html · https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer · Last verified 2026-11-23

## Definition
Fowler (PoEAA 2003): a DTO is an object that carries data between processes to reduce the number of method calls. It exists because remote calls are expensive, so each call should move more data, and because many parameters (or multiple return values) are awkward. The DTO holds everything for one call, must be serializable, and also encapsulates the serialization mechanism so wire-format logic sits in one place. An assembler on the server side usually moves data between the DTO and domain objects. A 2013 note on the page says batching remote calls is the main reason, encapsulated serialization secondary; the Java community first called it "value object" and then "Transfer Object", which is why it must not be confused with the DDD Value Object.

## Mechanics
1. Define a flat, serializable shape for exactly one use case (request or response).
2. The boundary adapter (controller, message handler) receives the DTO.
3. An assembler/mapper converts DTO to a command or domain object, and domain result back to a response DTO.
4. The DTO crosses the wire; the domain objects never do.

```
# response DTO, shaped for the screen, not for the table
OrderSummaryDto { id: str, status: str, total: str, lines: [LineDto] }
def to_dto(order: Order) -> OrderSummaryDto: ...
```

## Design rules
- **No behavior, no domain invariants**: DTOs are data. Validation of shape happens at the boundary (`validator-input-parser`); invariants live in domain types (`value-objects-type-invariants`).
- **One DTO per use case/direction** (request vs response vs event), versioned deliberately; do not reuse one DTO for create, update and read.
- **Never expose domain entities or ORM entities** as the contract: schema changes then break clients and lazily loaded graphs leak.
- Public contract shape is governed by `arc42-api-contracts-architecture`; keep DTOs derived from, or generated from, the contract (SSOT, `pragmatic-solid-and-ssot`).
- Keep them flat and coarse-grained across process boundaries; avoid chatty fine-grained fetching.

## When to use / avoid
Use at every process or trust boundary (HTTP, queue, RPC), and between layers when the inner model must stay hidden. Avoid DTO-per-layer copying inside one process where nothing is hidden or remote: that is ceremony (`codebase-design`, `yagni-evolutionary-architecture`). Fowler's own rationale is remote-call cost, so inside a single process the case is weaker (my inference: the other reasons are contract stability and security).

## Failure modes
Anemic mapping copies of the entity (1:1 DTO adds nothing); DTOs carrying fields the caller must not set (mass assignment; see `never-trust-the-client`); DTO reused as persistence model; serialization annotations leaking into the domain; nullable-everything DTOs that push validation downstream.

## How an agent should apply this
- Ask "which process or trust boundary does this cross?"; if none, do not add a DTO.
- Separate request, response and event shapes; name them after the use case.
- Whitelist fields on inbound DTOs; never bind directly to an entity.
- Put the conversion in one assembler per boundary (see `mapper-pattern.md`).
- Generate DTOs from the contract where tooling allows, to avoid drift.
