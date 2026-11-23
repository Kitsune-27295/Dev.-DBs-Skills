# Go Project Layout: Start Flat, Grow on Evidence

Sources: https://levelupgo.dev/blog/go-project-structure · Last verified 2026-11-23

## Thesis

Go has no mandated layout. Official guidance ("Organizing a Go module") shows layouts that grow with project size, and the article argues you should start flat and add directories only when the code needs them.

## Rules from the article

| Situation | Layout |
|---|---|
| Small tool | `main.go` plus logic files in the module root; no `utils/` |
| Several binaries, or binary plus library | `cmd/<name>/main.go`, each thin, logic imported from `internal/` |
| Private code | `internal/` (compiler-enforced: importable only inside the parent module); keep packages there as much as possible |
| Library | public package at module root |
| REST API | `internal/` split by domain |
| Multi-service repo | `cmd/` plus `internal/` |

`golang-standards/project-layout` is not an official standard (the article cites Russ Cox saying so); copying it into a small program yields many nearly empty folders.

## Best practices listed

- Keep `main` thin.
- Group packages by domain, not by role (`models`, `services`).
- Tests beside code; fixtures in `testdata/`.
- Prefer `internal/` over exported packages.
- One module per repository until separate versioning is needed.
- Avoid empty `pkg/`, `src/`, `utils/` directories; name packages for what they provide (`store`, `auth`), not `common`.

## Generalising beyond Go (own inference)

The same principle applies to any monorepo package layout: a directory should mark a real boundary (ownership, dependency rule, release unit), not a hoped-for one. Directory count is a cost paid in imports and navigation.

## Example growth path

```
v0   main.go  store.go
v1   main.go  internal/store/  internal/auth/
v2   cmd/api/main.go  cmd/worker/main.go  internal/orders/  internal/billing/
```
Move from v0 to v1 only when a file group needs a privacy boundary or two reasons to change.

## Anti-patterns

- 10+ scaffold directories before the first feature.
- `pkg/` as a dumping ground, signalling "public" without any consumer.
- Layer-based packages that force every feature change to touch four directories.

## How an agent should apply this

- Begin with the smallest layout that compiles; justify each new directory by a concrete boundary.
- Use `cmd/` only when more than one entrypoint exists.
- Put private code in `internal/` by default.
- Organise by domain, and rename `utils`/`common` packages by function.
- Do not cite `golang-standards/project-layout` as authoritative.
