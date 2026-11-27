# Go Project Layout: Start Flat, Grow on Evidence

Sources: https://go.dev/doc/modules/layout · https://pkg.go.dev/cmd/go (Internal packages) · https://github.com/golang-standards/project-layout · https://levelupgo.dev/blog/go-project-structure · Last verified 2026-11-27

## Official guidance (go.dev, read)
| Situation | Layout |
|---|---|
| Basic package | `go.mod` plus source and tests in the root |
| Basic command | `package main` in the root, `main.go` by convention |
| Supporting packages | `internal/<name>/` imported by the root package |
| Several commands | one directory per program, shared code in a top-level `internal/`; `cmd/` is a common convention, useful in mixed repositories |
| Packages and commands | public packages at the root or in directories, commands under `cmd/`, private code in `internal/` |
| Server | logic in `internal/`, entrypoints in `cmd/` (for example `cmd/api-server/main.go`); split parts into separate modules if other projects need them |

The page does not mention `pkg/` or `golang-standards`.

## The internal rule (cmd/go docs, read)
Code in or below a directory named `internal` is importable only by code that shares the import path above the `internal` directory. Example from the docs: `example.com/m/foo/internal/baz` can be imported by `example.com/m/foo` and its subpackages, not by `example.com/m/crash/bang`.

## golang-standards/project-layout (README, read)
It says it is NOT an official standard defined by the core Go dev team, describes `/pkg` as library code ok for external use (a pattern some in the community do not recommend), and `/internal` as private code enforced by the compiler. The Level Up Go article (read) additionally reports that a Go tech lead said in issue #117 it is not a standard layout; that issue itself was not opened, so treat the attribution as second-hand.

## Rules for any language (own inference)
- A directory should mark a real boundary: ownership, dependency rule or release unit.
- Name packages for what they provide (`store`, `auth`), not `common` or `utils`.
- One module per repository until separate versioning is needed (from the article; not confirmed on go.dev).

## Example growth path
```
v0   main.go  store.go
v1   main.go  internal/store/  internal/auth/
v2   cmd/api/main.go  cmd/worker/main.go  internal/orders/  internal/billing/
```
Move v0 to v1 only when a file group needs a privacy boundary or has two reasons to change.

## How an agent should apply this
- Begin with the smallest layout that compiles; justify each new directory by a boundary.
- Use `cmd/` only with more than one entrypoint; put private code in `internal/` by default.
- Do not cite `golang-standards/project-layout` as authoritative.
