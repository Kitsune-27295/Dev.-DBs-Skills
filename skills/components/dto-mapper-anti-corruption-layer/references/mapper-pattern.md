# Mapper Pattern and Translation Code

Sources: https://martinfowler.com/eaaCatalog/mapper.html · https://martinfowler.com/eaaCatalog/dataTransferObject.html · Last verified 2026-11-27

## Definition
Fowler's catalog entry defines a Mapper as an object that sets up communication between two independent objects. The page is a short summary; the mechanics are in PoEAA ch. 18 (not read). Core idea: a separate object sits between two subsystems so neither knows about the other.

## When Fowler says to use it
- The two subsystems must interact but should stay unaware of each other.
- You cannot modify one or both subsystems.
- You can modify them, but do not want a dependency between them, or between them and the mapper itself.

Note the generality: "Mapper" is a pattern family (data mapper, DTO assembler, message mapper), not one class shape. The specific object-relational variant is Data Mapper; see `repository-unit-of-work`.

## Where mappers live
| Boundary | Mapper | Direction |
|---|---|---|
| HTTP/RPC edge | DTO <-> command/domain | inbound request, outbound response |
| Persistence edge | domain aggregate <-> storage record | inside the repository adapter |
| External system edge | external model <-> local model | inside an anti-corruption layer |
| Event edge | domain event <-> integration message | publisher/consumer adapter |
Rule: the mapper belongs to the adapter that owns the foreign shape, so the inner model never imports it.

## Implementation guidance (my inference, grounded in the above)
- **Explicit functions first.** Hand-written `to_domain` / `to_dto` are searchable, type-checked and trivially testable. Reflection/auto-mapping libraries save keystrokes but hide renames, silently drop or default fields and make nullable bugs runtime events. Use them only for genuinely 1:1 shapes, with a test that fails on unmapped fields.
- **Mappers are pure and total:** no I/O, no service calls, no lazy loading; reject or return an explicit error for unmappable input instead of guessing.
- **Mapper is not a service:** no business rules; defaults and lookups that need data belong to application services.
- **Round-trip and golden tests:** `to_domain(to_dto(x)) == x` where lossless; fixed fixtures for lossy mappings.
```
def to_domain(dto: PlaceOrderDto) -> PlaceOrder:
    return PlaceOrder(CustomerId(dto.customer_id),
                      [Line(Sku(l.sku), Quantity(l.qty)) for l in dto.lines])
```

## Trade-offs
Benefit: isolates change and enforces direction of dependency. Cost: more types and a copy per boundary, plus drift risk when fields are added in one place. Mitigate with contract generation, mapping tests and by limiting layers that need their own model.

## Failure modes
Mapper that calls repositories; bidirectional mappers living in the domain; auto-mapper with magic naming across contexts; "mapper hell" from a model per layer inside one bounded context; mapping that mutates the source.

## How an agent should apply this
- Place the mapper in the adapter owning the external shape; check the import direction.
- Prefer explicit mapping; add unmapped-field tests if a library is used.
- Keep mappers pure; move lookups to the application service.
- Count model copies: more than one per real boundary is over-mapping.
- Hand the strategic question (two contexts, different semantics) to `anti-corruption-layer.md`.
