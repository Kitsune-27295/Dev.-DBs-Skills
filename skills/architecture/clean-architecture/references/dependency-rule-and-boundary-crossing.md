# The Dependency Rule and Boundary Crossing (Martin, 2012)

Sources: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html · Last verified 2026-11-23

## What the post claims
- Hexagonal, Onion, Screaming, DCI and BCE share one goal: separation of concerns through layers, each with at least one layer for business rules and one for interfaces. Systems built this way are independent of frameworks, testable without UI or database, independent of UI and database, and unaware of the outside world.
- **The Dependency Rule**: source code dependencies point only inward. Outer circles are mechanisms, inner circles are policies. Inner code must not name anything declared outside; data formats from outer layers, especially framework-generated ones, must not be used inside.
- Abstraction increases toward the center. The four circles are a schematic; more layers are fine as long as the rule holds.

## Layer responsibilities (as described)
- Entities: enterprise-wide rules (objects or data structures with functions); least likely to change when operational details such as page navigation or security change.
- Use cases: application-specific rules; coordinate data flow to and from entities. Operational changes touch this layer, not entities.
- Interface adapters: convert between the form convenient for use cases/entities and the form convenient for external agents. MVC pieces live here; SQL is confined here.
- Frameworks and drivers: DB, web framework; mostly glue code, kept outside so they do little harm.

## Crossing boundaries: control versus dependency
Control flows outward (controller calls use case, use case runs presenter) while the source dependency must point inward. The mechanism: the use case calls an **output port** interface declared in the inner circle, and the outer presenter implements it (Dependency Inversion Principle plus dynamic polymorphism). So the rule holds whatever the direction of control flow.

```ts
// application circle
interface OrderOutputPort { present(o: OrderResponse): void }
class PlaceOrder {                                   // interactor
  constructor(private repo: OrderGateway, private out: OrderOutputPort) {}
  execute(req: PlaceOrderRequest) { /* rules */ this.out.present({ id: "o1" }); }
}
// adapter circle
class JsonPresenter implements OrderOutputPort { present(o: OrderResponse) { /* -> HTTP */ } }
```

## Data across boundaries
Pass simple isolated structures (basic structs, DTOs, function arguments, hashmaps, simple objects), shaped for the **inner** circle. Entities and database rows must not cross, because a framework's row structure would drag a dependency on the outer circle inward.

## Trade-offs and cautions
- The post does not discuss when the structure is not worth its cost; that judgment (SKILL.md "When it earns its keep") is the skill's own, not from this page.
- More circles means more mapping code; add a circle only when a distinct policy level exists (inference).
- A purist output-port/presenter flow and a handler that returns a response DTO both satisfy the rule; see `sources.md` notes.

## How an agent should apply this
- On review, grep inner-circle imports: any name from an outer circle (ORM, HTTP, framework) is a violation, whatever the convenience.
- When an inner component needs an outer service, declare the interface in the inner circle and implement it outside.
- Define request/response structs in the inner circle; map in adapters, never pass rows or framework requests inward.
- Treat the circle count as flexible; enforce the direction, not the number.
- Add an automated import-direction check so the rule is guarded in CI.
