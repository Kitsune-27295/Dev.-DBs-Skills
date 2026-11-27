# Monorepo Tooling Landscape and Strategy Notes

Sources: https://github.com/korfuri/awesome-monorepo (read) · https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners (read) · https://learn.github.com/well-architected/architecture/recommendations/scaling-git-repositories/repository-architecture-strategy (NOT readable: returns only the title "GitHub Learn") · Last verified 2026-11-27

## Part A: awesome-monorepo (read)
A curated index, not a recommendation. Sections relevant here:
| Need | Tools named |
|---|---|
| Build systems and dependency management | Bazel, Buck, Pants, Please, Nx, Turborepo, Rush Stack, Bit, Lerna, pnpm, Yarn, Nix and others |
| Code ownership | GitHub CODEOWNERS, Chromium OWNERS, and generator tools |
| CI | Bazel-based incremental CI, buildpipe, Codefresh, Semaphore CI |
| Large-repo Git | shallow clones, `--single-branch`, sparse-checkout, Git LFS, GVFS, git subtree, splitsh-lite, josh |
There is no dedicated caching section; caching appears only incidentally (Nix "remote caching"). The index does not describe affected-task algorithms.

## Part B: CODEOWNERS (GitHub docs, read)
Location `.github/`, root or `docs/` (first found wins); gitignore-like patterns, case-sensitive, no negation or character ranges; the last matching pattern takes precedence; owner review is required only when branch protection or a ruleset enables it.

## Part C: GitHub Well-Architected page (not read)
Unreadable, so its monorepo and polyrepo claims are not adopted. The decision rules below are own synthesis from general practice.

## Decision rules (own synthesis)
- Monorepo: packages share models or need atomic releases and you can invest in affected-only builds.
- Polyrepo or flat: teams release independently on stable contracts, or access must be isolated.
- Always: dependency graph, boundary rules (CODEOWNERS plus import restrictions), affected-task detection.

## Example: affected-only CI step (sketch)
```
changed = git diff --name-only origin/main...HEAD
affected = graph.dependents_of(packages_containing(changed))
run test,build for affected only
```

## How an agent should apply this
- Recommend tools by need (graph, cache, ownership, Git scale), not one product by default.
- Require CODEOWNERS with enforced review and affected-build CI in any monorepo proposal.
- Say the vendor guidance page could not be verified.
