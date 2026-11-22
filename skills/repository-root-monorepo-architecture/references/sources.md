# Sources for the repository-root-monorepo-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | GitHub Well-Architected Framework, "Exploring repository architecture strategy" (Steffen Hiller, 2024/2026), https://learn.github.com/well-architected/architecture/recommendations/scaling-git-repositories/repository-architecture-strategy | Authoritative comparison between Monorepo and Polyrepo strategies; monorepo advantages (unified codebase, atomic cross-project commits, single source of truth, simplified cross-package refactoring) and challenges (large clone sizes, slow CI pipelines, complex tooling requirements, permission granularity); polyrepo trade-offs (clear ownership, isolated blast radius, fast CI, but painful cross-repo version drift); 9-step implementation activities and repository architecture checklist. |
| 2 | Awesome Monorepo (Guillaume Luccisano, et al.), https://github.com/korfuri/awesome-monorepo | Comprehensive taxonomy of monorepo tooling (Nx, Turborepo, Bazel, Buck2, Pants), build caching mechanisms (local vs remote distributed computation cache), affected task detection algorithms, and enterprise monorepo case studies (Google, Facebook, Uber, Twitter). |
| 3 | Level Up Go, "Standard Go Project Structure & Module Layout" (2024), https://levelupgo.dev/blog/go-project-structure | Critique of premature and dogmatic directory scaffolding (the `pkg/` anti-pattern); the **Start-Flat Rule** (single file in root until complexity demands structure); distinction between `cmd/<binary>/` (entrypoints only) and `internal/` (packages protected from external imports by the Go compiler); semantic meaning of directories as package boundaries. |

Contradictions and trade-offs resolved:
- Some developers blindly scaffold 10+ folders (`pkg/`, `internal/`, `api/`, `configs/`, `scripts/`, `test/`) before writing a single line of business logic. The skill enforces the Start-Flat rule: package boundaries must reflect actual domain needs, not cargo-cult scaffolding.
- Monorepo tooling can introduce severe configuration overhead. The skill specifies when a monorepo is justified (shared domain models, atomic multi-package releases) versus when polyrepos or simple flat repositories remain superior.
