---
name: repository-root-monorepo-architecture
description: "Decide and review a repository's root layout and topology: start with the simplest flat layout, add cmd/ and internal/ only when a boundary exists (Go and similar), choose between monorepo and polyrepo, lay out apps/ and packages/ with one-way dependencies, and set up path-scoped CODEOWNERS and affected-only CI. Use when scaffolding a new repo, auditing a root folder that has grown scratch files or empty directories, deciding monorepo vs polyrepo, or governing a monorepo. Not for naming folders after the domain (use screaming-architecture), grouping code inside a service (use package-by-feature-component) or modular monolith module rules (use modular-monolith-architecture)."
---

# Repository Root Conventions & Monorepo Architecture

One idea: use the simplest layout that fits today, and add structure only where a real boundary (ownership, dependency rule, release unit) exists. A monorepo is only worth it with a dependency graph, boundary rules and path-aware CI. Sources and what was read: [references/sources.md](references/sources.md).

> **Scope boundary:** domain-revealing names are `screaming-architecture`; grouping inside a service (including catch-all `utils/`) is `package-by-feature-component`; module rules inside one deployable are `modular-monolith-architecture`; decision records are `adr-architecture`. This skill owns root layout and repository topology.

## 1. Start flat (verified for Go)

The official Go guide shows layouts that grow with the project: a package or command lives in the module root (`go.mod` plus source and tests); helper packages go in `internal/`; several commands get one directory each, often under `cmd/`; a server keeps its logic in `internal/` with entrypoints in `cmd/`. Rules worth carrying to any language:

- A directory is a package boundary; do not create one for a single file or for nothing.
- `internal/` is compiler-enforced in Go: code below it is importable only by code sharing the path above `internal` (so other modules cannot import it). The guide recommends keeping packages there as much as possible.
- `cmd/<name>/` pays off when there are several binaries or a binary plus a library; keep each `main` thin.
- `golang-standards/project-layout` is not an official standard; its own README says so. Do not cite it as authority. `pkg/` is optional, not required; expose a root package only when you intend to support it as public API.

## 2. Progressive escalation (own synthesis)

1. Small library or command: flat root.
2. Growing application: `internal/` or `src/` split by capability (`package-by-feature-component`).
3. Several binaries or drivers (CLI, HTTP, MCP): thin `cmd/<binary>/` entrypoints over the shared core.
4. Several deployable apps plus shared libraries: workspace monorepo with `apps/` (deployables) and `packages/` (shared libraries).

## 3. Monorepo or polyrepo (judgment; the vendor page was unreadable)

| Force | Monorepo when | Polyrepo when |
|---|---|---|
| Coupling | Apps share contracts and often need atomic cross-cutting changes | Services are independent and talk through stable versioned APIs |
| Access | Teams collaborate openly | Regulatory or contractor boundaries must hide sibling code |
| Tooling | You will invest in build graph, caching and boundary checks | You want standard one-repo-one-pipeline CI |

Never adopt a monorepo without three things: a dependency graph, boundary rules, and affected-only CI. Ten folders in one repo with none of these gives slow CI and hidden cycles.

## 4. Monorepo rules (own synthesis)

- `apps/*` may import `packages/*`; never the reverse; cycles between packages fail CI.
- Keep shared packages narrow and cohesive; a single `shared-everything` package forces every app to rebuild on every change.
- Affected-only CI: compute packages touched by the diff plus their dependents; run the rest from cache. Tools in this space include Bazel, Nx, Turborepo and Pants (listed in a curated index; their feature claims not re-verified here).
- **CODEOWNERS** (GitHub docs, read): the file may live in `.github/`, the root or `docs/`; patterns follow most gitignore rules and are case-sensitive; the last matching pattern wins; review by owners is enforced only if "Require review from Code Owners" is enabled in branch protection or a ruleset. Map every app and package to an owner.
- Large repos: sparse-checkout and shallow clones are listed as options in the awesome-monorepo index.
- Tests next to the code; a top-level `e2e/` or `tests/` only for cross-package checks.

## 5. Root hygiene

The root holds universal contracts: README, LICENSE, contributing and agent-instruction files, the build or workspace manifest (`go.mod`, `package.json`, workspace file), lockfiles, `.github/`, and `docs/`. Scratch scripts and empty scaffolding do not belong there.

```text
repo-root/
  .github/CODEOWNERS
  apps/      web/  api/  worker/
  packages/  domain-billing/  telemetry/
  docs/      adr/
  README.md
```

## Mistakes to catch

- Scaffolding `pkg/`, `api/`, `configs/` and `scripts/` before writing code.
- A "monorepo" that is only a shared Git history.
- Over-nesting a 300-line tool into `cmd/`, `pkg/` and layered `internal/` folders.

## Quick Decision Checklist

- [ ] Is the layout the simplest that fits now, each directory marking a real boundary?
- [ ] Did I weigh coupling, access boundaries and tooling before choosing monorepo or polyrepo?
- [ ] In a monorepo: one-way app-to-package imports, cycle check, affected-only CI?
- [ ] Does CODEOWNERS map every app and package, with owner review enforced?
- [ ] Is the root limited to universal contracts?

## Deep references

- [Go layout: start flat](references/go-layout-start-flat.md) - when scaffolding directories or Go modules
- [Monorepo tooling and strategy](references/monorepo-tooling-and-strategy.md) - when choosing monorepo tooling
- [Trigger evals](references/trigger-evals.md) - should-trigger and near-miss prompts for the description
- [Sources](references/sources.md) - retrieved statuses, reading limits, claims not adopted
