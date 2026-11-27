---
name: screaming-architecture
description: "Audit or design a repository's top-level folders, package names and use-case names so a newcomer can tell the business domain and its use cases at a glance, instead of the framework (controllers/, models/, prisma/). Gives the first-impression test, use-case naming in business verbs, keeping frameworks and delivery mechanisms at the edge, and testing use cases without server or database, following Robert C. Martin's 2011 post and Ivar Jacobson's use-case-driven view. Use when naming or restructuring top-level source folders, reviewing a framework-generated app tree, or asked what a codebase communicates. Not for dependency direction (use clean-architecture), choosing layer vs feature vs component packaging (use package-by-feature-component) or repository root layout (use repository-root-monorepo-architecture)."
---

# Screaming Architecture

One idea: the top level of a repository should announce what the system is for (a clinic, a ledger, a vault), the way a building's plans announce a house or a library, not which framework or database it uses. Sources and what was read: [references/sources.md](references/sources.md).

> **Scope boundary:** the Dependency Rule and boundary crossing belong to `clean-architecture`; ports and adapters to `hexagonal-architecture`; how to group code (feature, component, layer) to `package-by-feature-component`; repo root and monorepo layout to `repository-root-monorepo-architecture`. This skill owns what the top-level names communicate.

## 1. What the source claims (Martin, 2011)

| Claim | Meaning |
|---|---|
| Plans reveal purpose | A software system should reveal its business domain, not its technologies |
| Use-case driven | Following Ivar Jacobson, architecture is a structure that supports the system's use cases |
| Frameworks at arm's length | "Frameworks are tools to be used, not architectures to be conformed to"; view them skeptically |
| The web is a delivery detail | The same system could be console, web, thick client or service with little change |
| Testable | Use cases unit-test without a web server or database; business objects are plain objects |

## 2. The audit (about 15 minutes)

1. **First-impression test:** list the top two levels of the source tree with package manifests hidden. Can a stranger name the industry and the product? (A heuristic built on the post's central question, not a quote.)
2. **Count names:** domain nouns and use-case verbs versus technical stereotypes (`controllers`, `services`, `utils`, `dto`).
3. **Use-case names:** replace generic `UserService.update(id, data)` or `OrderManager` with business verbs (`ApproveLoanApplication`, `DischargePatient`).
4. **Framework imports:** grep use-case and entity files for framework or ORM types; they should be plain objects.
5. **Test without infrastructure:** run one use case in a unit test with no HTTP and no database.

## 3. Fixing it

- Name top-level folders after business capabilities (`scheduling/`, `billing/`); how to group inside them is `package-by-feature-component`.
- A directory a framework requires (routes, `app/`) stays a thin driver that parses the request and calls the core.
- In a single-context service, `domain/` and `application/` at the top level with capability-named folders inside is acceptable; in a multi-context system the top level names the contexts (`modular-monolith-architecture`). Either satisfies the test if the business shows first (an inference from the post's goal).
- Do not simply rename `controllers/` without moving logic: that is cosmetic.

## 4. When it does not apply

A library whose domain is the technical mechanism itself (an HTTP router) legitimately has technical names. The post is about what the top level communicates, not a ban on every layer folder (inference).

## Mistakes to catch

- Letting the generator's tree (`rails new`, `create-next-app`) hold all business rules for years.
- Vague nouns (`DataHelper`, `ProcessService`) instead of the verbs domain experts use.
- Domain folders that still import framework types.
- Reading the slogan as permission to put SQL and HTML in `billing/`: delivery and persistence stay decoupled (`clean-architecture`).

## Quick Decision Checklist

- [ ] Would a stranger guess the product's domain from the top two levels?
- [ ] Are use cases named in business verbs?
- [ ] Do entities and use cases avoid framework types?
- [ ] Can one use case be tested without server or database?
- [ ] Are framework-required directories thin drivers?

## Deep references

- [Screaming architecture argument](references/screaming-architecture-argument.md) - read when judging what a repo layout communicates
- [Trigger evals](references/trigger-evals.md) - should-trigger and near-miss prompts for the description
- [Sources](references/sources.md) - retrieved statuses, reading limits, claims not adopted
