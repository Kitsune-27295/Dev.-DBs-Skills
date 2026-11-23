# Clean Architecture: Dependency Rule and Boundary Crossing

Sources: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html · Last verified 2026-11-23

## Shared goal

Hexagonal, Onion, DCI, BCE and Screaming Architecture all separate concerns into layers with a business-rules layer and an interfaces layer. The results are independent of frameworks, UI and databases, with business rules testable in isolation.

## The Dependency Rule

Source-code dependencies point only inward. Inner code cannot name anything in an outer circle (functions, classes, variables). Data formats from outer layers, especially framework-generated ones, must not be used by inner layers. Martin: "Nothing in an inner circle can know anything at all about something in an outer circle."

## The four circles (schematic; more are allowed)

| Circle | Holds | Changes because of |
|---|---|---|
| Entities | Enterprise-wide business rules | Rarely; most general |
| Use Cases | Application-specific rules orchestrating entities | How the application operates, not DB/UI |
| Interface Adapters | Controllers, presenters, views, all SQL; converts formats | Delivery and persistence choices |
| Frameworks and Drivers | DB, web framework; mostly glue | Tool choices |

Abstraction increases inward.

## Crossing boundaries

Control may flow outward while source dependencies point inward. Example: controller calls use case, use case needs a presenter, but cannot call it directly. It calls an output port (interface) defined in the use-case layer; the outer presenter implements it (dependency inversion and polymorphism).

```ts
// inner: use-case layer owns the port
interface EnrollmentOutput { present(result: EnrollmentResult): void }
class EnrollStudent {
  constructor(private repo: StudentRepo, private out: EnrollmentOutput) {}
  run(req: { studentId: string }) { /* rules */ this.out.present(result) }
}
// outer: adapter implements it
class JsonPresenter implements EnrollmentOutput { present(r) { /* build view model */ } }
```

## Data across boundaries

Pass simple isolated structures: structs, DTOs, function arguments, hashmaps. Never pass entities or database rows across; a framework row type would make an inner layer depend on an outer one. Shape data for the convenience of the receiving inner circle.

## Consequences and trade-offs

Inherently testable systems; obsolete frameworks replaceable cheaply. Cost: mapping code and ports; do not add ports with only one realistic implementation (see `codebase-design` on seams). The existing skill's note on slicing by context versus by layer still applies.

## Failure modes

- Use case imports ORM entities or HTTP request objects.
- Returning DB rows to controllers and calling that "DTO".
- Circles treated as exactly four, then inventing empty layers.

## How an agent should apply this

- Check imports: inner folders must not import from outer ones; add an architecture test.
- Define output ports in the use-case layer and implement them in adapters.
- Map at boundaries; never leak entities or rows outward or framework types inward.
- Keep SQL and view formatting in the adapter circle.
- Add layers only when a real distinct concern appears.
