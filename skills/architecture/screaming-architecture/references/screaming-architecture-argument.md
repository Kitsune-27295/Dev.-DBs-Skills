# Screaming Architecture: The Argument in Detail

Sources: https://blog.cleancoder.com/uncle-bob/2011/09/30/Screaming-Architecture.html (read) · Last verified 2026-11-27

## Thesis
Architecture should reveal what the system is for, as a house or library plan does. Martin asks what your top-level directories announce: a business domain, or a framework.

## Supporting claims
| Claim | Meaning |
|---|---|
| Architecture follows use cases | Drawn from Jacobson's *Object Oriented Software Engineering*; structure supports the use cases |
| Frameworks are tools | "Frameworks are tools to be used, not architectures to be conformed to" |
| The web is a detail | A delivery mechanism; the system could ship as console, web, thick client or service |
| Testability | Use cases run without web server or database; business objects are plain objects |

## Example structures
```text
# screams "Rails"
app/controllers  app/models  app/views  db/migrate

# screams "Clinic scheduling"
scheduling/  book-appointment.ts  cancel-appointment.ts  appointment.ts
billing/     issue-invoice.ts
infrastructure/  http/  postgres/
```

## Diagnostic questions (own heuristics)
1. Could a stranger name the business from `ls src/`?
2. Can book-appointment run in a unit test with no HTTP and no DB?
3. If the framework were swapped, would the use-case files change?
4. Do folders name nouns of the business or layers of the technology?

## Failure modes (own inferences)
- Cosmetic renames with no logic moved.
- Domain folders importing framework types.
- Vertical slicing that copy-pastes infrastructure everywhere.
- Using the slogan to forbid any layer folder.

## How an agent should apply this
- Run the four diagnostics before suggesting folders for a new layout.
- Name top-level modules after capabilities, use cases with verbs.
- Keep framework imports out of use-case and entity files; check by grep.
- Add one use-case test without server or database as proof.
- Dependency direction: `clean-architecture`; grouping: `package-by-feature-component`.
