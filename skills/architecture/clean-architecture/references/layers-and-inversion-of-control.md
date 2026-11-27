# Layers, Stability and Inversion of Control (Valente)

Sources: https://softengbook.org/articles/clean-architecture · Last verified 2026-11-23

## Claims from the article
- Goals of the architecture: reusability, cohesion, technology independence, testability.
- Layers inside-out, illustrated with a university system:
  - **Entities**: business objects shared across systems (`Student`, `Course`); may hold general rules (e.g. every instructor belongs to one department).
  - **Use cases**: system-specific operations (enroll a student, cancel an enrollment).
  - **Adapters**: translators between inner layers and the outside, e.g. a REST adapter receives requests, forwards to use cases, converts results to JSON.
  - **External frameworks**: DB, payment provider, email library; "the web is a detail", "the database is a detail".
- **Stability argument**: an inner layer may not mention names from an outer one, so inner layers change least; entities rarely change, and a use case should not change because the database or framework changed.
- **Inversion of control**: control naturally flows inward, but a use case sometimes must call outward (send an email). Referencing the mail class directly breaks the rule, so the use-case layer declares an interface and the outer class implements it; both now depend on the abstraction, and the dependency arrow points inward.
- Testing: the article only says separating logic from technology makes testing easier; it gives no techniques.
- Open question: the article does not say when the architecture is not worthwhile; its exercises pose it (for example, is it useful if the technologies will never change?) without answering. Costs it implies: extra interfaces and translation code.

## Reading it next to the traditional layered stack
In a conventional UI-to-business-to-persistence stack, business code depends on persistence. Inversion reverses that arrow: the business layer owns the persistence interface. (The Microsoft guide makes the same contrast; see `dotnet-layout-and-composition-root.md`.)

```ts
// use-case layer owns the abstraction
interface Mailer { send(to: string, body: string): Promise<void> }
class EnrollStudent {
  constructor(private mailer: Mailer) {}
  async run(id: string) { /* rules */ await this.mailer.send(id, "enrolled"); }
}
// external layer implements it
class SmtpMailer implements Mailer { async send(to: string, body: string) { /* SMTP */ } }
```

## Failure modes
- Declaring the interface in the outer layer (next to the implementation): the use case then imports outward and the inversion is fake.
- Entities that import adapter DTOs or framework annotations.
- Treating every helper as an "external agency" and adding an interface: pure computation needs none.

## How an agent should apply this
- Place each port interface in the use-case layer, in the same module as the code that calls it.
- Name use cases after operations of the application ("EnrollStudent"), keep generic domain rules in entities.
- Keep adapters thin: parse request, call use case, format result.
- Ask "does this change when we swap the web framework or database?" If yes, it belongs in an outer layer.
- For a small system with fixed technology, weigh the interface and mapping cost before adopting all four layers (the article leaves this open).
