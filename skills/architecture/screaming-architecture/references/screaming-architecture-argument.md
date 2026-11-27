# Screaming Architecture: The Argument in Detail

Sources: https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html · Last verified 2026-11-23

## Thesis

Architecture should reveal what the system is for, as a house or library blueprint does. Martin asks what your top-level directories and packages announce: a health-care, accounting or inventory system, or Rails, Spring/Hibernate, ASP.

## Supporting claims

| Claim | Meaning |
|---|---|
| Architecture follows use cases | Drawn from Ivar Jacobson's use-case-driven OOSE; structure supports the use cases |
| Frameworks are tools | Martin: "Frameworks are tools to be used, not architectures to be conformed to"; a framework-shaped architecture cannot be use-case-shaped |
| Defer decisions | A good architecture postpones framework, database and server choices and keeps them cheap to change (the owner picks brick or cedar after the house is usable) |
| The web is a detail | A delivery mechanism; the system should ship as console, web, thick client or service without fundamental change |
| Skepticism toward frameworks | Evaluate benefits against costs; do not let one take over |
| Testability | Use cases unit-test without web server or database; business objects are plain objects; use-case objects coordinate them |

Test of success: a newcomer opening a health-care repo recognizes a health-care system and its use cases; views and controllers come later.

## Example structures

```text
# screams "Rails"
app/controllers  app/models  app/views  db/migrate

# screams "Clinic scheduling"
scheduling/  book-appointment.ts  cancel-appointment.ts  appointment.ts
billing/     issue-invoice.ts
infrastructure/  http/  postgres/
```

## Diagnostic questions

1. Could a stranger name the business from `ls src/`?
2. Can the book-appointment use case run in a unit test with no HTTP and no DB?
3. If the framework were swapped, would the use-case files change?
4. Do folders name nouns of the business or layers of the technology?

## Failure modes

- Renaming `controllers/` to something cute without moving logic (cosmetic).
- Domain folders that still import framework types (violates the "plain objects" point).
- Vertical slicing with copy-pasted infrastructure everywhere (inference: boundaries need shared kernel decisions).
- Using the slogan to forbid any layer folder; the post is about what the top level communicates, not a ban (inference, consistent with the existing skill's nuance note).

## Boundary with sibling skills

Dependency direction and boundary crossing are covered by `clean-architecture` (`references/dependency-rule-and-boundary-crossing.md`); hexagonal and modular-monolith structuring belong to `hexagonal-architecture` and `modular-monolith-architecture`.

## How an agent should apply this

- Run the four diagnostics on any new repo layout before suggesting folders.
- Name top-level modules after business capabilities or use cases, verbs for use cases.
- Keep framework imports out of use-case and entity files; check by grep.
- Write at least one use-case test without server or database as proof.
- Treat framework choice as deferrable; record it in an ADR if made early.
