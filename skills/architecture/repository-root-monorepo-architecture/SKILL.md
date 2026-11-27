---
name: repository-root-monorepo-architecture
description: Use when designing, auditing, or refactoring a repository's root layout, deciding between a Monorepo and Polyrepo strategy, organizing Go/TypeScript/multi-service project trees (start flat, internal/, cmd/, apps/, packages/), or enforcing monorepo build-graph and CODEOWNERS governance.
---

# Repository Root Conventions & Monorepo Architecture

One idea: scale your repository topology from the **simplest flat layout that fits the project right now** up to a **governed Monorepo or Polyrepo** — never copy-pasting premature directory scaffolding (`pkg/`, `utils/`, 15 empty folders), and never running a Monorepo without affected-graph build caching, strict cyclic-dependency checks, and path-scoped `CODEOWNERS`. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (GitHub Well-Architected, Go Module Layout & Monorepo Tooling)

| Term | Meaning | Test sentence |
|---|---|---|
| Start-Flat Rule | begin a single library or CLI command in the module root (`main.go`, `weather.go`, `weather_test.go`) and add subdirectories only when genuine package boundaries emerge | "a directory is a package boundary; don't create a folder for one file" |
| `cmd/` & `internal/` | **`cmd/<app>/`**: minimal `main` entrypoints for multi-binary projects; **`internal/`**: compiler/linter-enforced private packages that external consumers cannot import | "wires the app in `cmd/`, hides private packages in `internal/`" |
| Monorepo | a single version-controlled repository hosting multiple distinct applications, services, and shared libraries with atomic cross-project commits | "one repository, multiple independently deployable apps and packages" |
| Polyrepo | separate repositories per service or library, each with its own isolated CI/CD pipeline, issue tracker, and access control | "strong repo-level isolation, higher cross-repo version-sync cost" |
| Affected Task Graph | a build tool capability (Nx, Turborepo, Bazel, Buck2, Pants, Gradle) that computes the DAG of package dependencies and runs `build/test/lint` **only** on packages affected by a PR's diff | "prevents monorepo CI times from scaling linearly with total repo size" |

## Decision Matrix: Monorepo vs. Polyrepo (GitHub Well-Architected)

| Force | Choose **Monorepo** when... | Choose **Polyrepo** when... |
|---|---|---|
| **Coupling & Atomic Changes** | Services/apps share TypeScript/Go/Proto contracts and frequently need atomic cross-cutting PRs | Services are genuinely independent, rarely change together, and communicate via stable public versioned APIs |
| **Team & Security Boundaries** | Teams collaborate openly across the stack and use `CODEOWNERS` for path-level review gates | Hard regulatory, contractor, or security boundaries require denying read access to sibling codebases |
| **Tooling Investment** | You commit to affected-graph build tooling (Turborepo/Nx/Bazel) and dependency boundary linters | You want zero special build-graph tooling and standard 1-repo-1-pipeline CI templates |

## Core architectural rules and invariants

1. **Progressive Layout Escalation (Never scaffold empty directories):**
   - **Stage 1 (Small Library / Single Command):** Flat root (`go.mod` / `package.json`, source files, co-located tests). Zero ceremony.
   - **Stage 2 (Growing Single Application):** Add `internal/` (or `src/`) partitioned by domain capability (`screaming-architecture`, `package-by-feature-component`).
   - **Stage 3 (Multi-Binary / Multi-Driver System):** Add `cmd/<binary-name>/main` (or `src/drivers/{cli,http,mcp}`) as thin composition roots calling `internal/`.
   - **Stage 4 (Workspace Monorepo):** Separate deployable applications (`apps/` or `services/`) from shared internal libraries (`packages/` or `libs/`).
2. **Avoid the `golang-standards/project-layout` & `pkg/` / `utils/` trap:** As the Go team and LevelUpGo emphasize, `golang-standards/project-layout` is **not** an official standard. Do not create a `pkg/` wrapper folder (every non-`internal` directory in a repo is already importable); for catch-all `utils/`/`helpers/`/`common/` folders see `package-by-feature-component`.
3. **Keep the Repository Root clean and predictable:** The root directory belongs to **universal project contracts and entrypoints**, not random scratch scripts:
   - Documentation & Governance: `README.md`, `LICENSE`, `CHANGELOG.md`, `CONTRIBUTING.md`, `AGENTS.md` / `CLAUDE.md`, `.github/CODEOWNERS`.
   - Build & Workspace manifests: `package.json` / `pnpm-workspace.yaml` / `go.mod` / `Cargo.toml` / `Makefile`, lockfiles, and `docs/` (`adr-architecture`, `arc42-api-contracts-architecture`).
4. **Enforce strict DAG boundaries in a Monorepo:**
   - `apps/*` (deployable units) may import from `packages/*` (shared libraries).
   - `packages/*` must **never** import from `apps/*`, and circular dependencies between `packages/A` and `packages/B` must fail CI immediately.
5. **Co-locate tests with the code they test:** Place unit and slice tests right next to the source file (`weather_test.go`, `order.test.ts`), reserving a top-level `tests/` or `e2e/` folder strictly for cross-package system/smoke tests.

## Standard Monorepo Layout (`apps/` + `packages/`)

```text
repo-root/
├── .github/
│   ├── CODEOWNERS          # Path-scoped review ownership per team
│   └── workflows/          # Affected-only CI pipelines
├── apps/                   # Deployable applications / containers (C4 Level 2)
│   ├── web/                # Frontend app
│   ├── api/                # Backend HTTP/gRPC server
│   └── worker/             # Background queue consumer
├── packages/               # Shared internal libraries (acyclic DAG)
│   ├── domain-billing/     # Cohesive domain package
│   ├── ui-primitives/      # Dumb design-system components
│   └── telemetry/          # Shared OpenTelemetry setup
├── docs/
│   ├── adr/                # Architecture Decision Records
│   └── architecture/       # C4 diagrams & arc42 overview
├── AGENTS.md               # Single instruction source for coding agents
└── README.md
```

## Mistakes to catch

- **A "Monorepo" that is just 10 folders with no workspace graph or boundary rules:** Putting 10 apps in one Git repo without affected-build caching or import rules — resulting in 45-minute CI builds on every typo commit and hidden circular imports across apps.
- **Sharing a mutable "God Package" (`packages/shared-everything`) across all monorepo apps:** Forces every app to rebuild and redeploy on every commit. Keep shared `packages/*` narrow, cohesive, and versioned/layered cleanly.
- **Over-nesting a 300-line tool into 12 directories (`cmd/`, `pkg/`, `internal/controllers/`, `internal/services/`, `internal/models/`):** Start flat and split only when flatness causes real friction.

## Quick Decision Checklist

- [ ] Am I using the simplest flat layout that fits now, without scaffolding empty directories?
- [ ] Did I weigh coupling, security boundaries and tooling investment before choosing monorepo or polyrepo?
- [ ] Is the repository root limited to universal project contracts and entrypoints?
- [ ] In a monorepo, do apps import packages but never the reverse, with no circular dependencies (CI runs `madge --circular`, `dependency-cruiser` or `nx graph`)?
- [ ] Is CI affected-only (a PR touching only `apps/web` does not rerun unrelated suites), and does CODEOWNERS map every app and package to a team?
- [ ] Am I avoiding a pkg/ wrapper and a God shared package (catch-all folders: `package-by-feature-component`)?
- [ ] Are tests co-located with the code they test?

## Deep references

- [Go layout: start flat](references/go-layout-start-flat.md) — when scaffolding directories or Go modules
- [Monorepo tooling and strategy](references/monorepo-tooling-and-strategy.md) — when choosing monorepo tooling or judging the GitHub guidance
