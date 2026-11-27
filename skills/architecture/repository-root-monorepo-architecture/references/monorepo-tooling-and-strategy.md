# Monorepo Tooling Landscape and Strategy Notes

Sources: https://github.com/korfuri/awesome-monorepo (read), https://learn.github.com/well-architected/architecture/recommendations/scaling-git-repositories/repository-architecture-strategy (NOT readable: the page renders only the title "GitHub Learn" via fetch, also via the wellarchitected.github.com redirect) · Last verified 2026-11-23

## Part A: awesome-monorepo (read from source)

A curated list (about 5.9k stars) organized into: build systems and dependency management, repository management, good reads, version control add-ons, development process tools, notable public monorepos, migration tools, development workflows.

| Need | Tools named |
|---|---|
| Build systems | Bazel, Buck, Pants, Please, Nx, Turborepo, Rush Stack, Bit, others |
| Workspace/package managers | Yarn workspaces, pnpm, Lerna, Bolt; Nix (mentions remote caching) |
| Repo management | Syncpack, wsrun, meta, Ultra Runner |
| Large-repo Git | shallow and single-branch clones, sparse-checkout, Git LFS, GVFS, git subtree, splitsh-lite, josh; Mercurial with Watchman/fsmonitor |
| Code ownership | GitHub CODEOWNERS, Chromium OWNERS files |
| CI | path-based filtering (for example GitLab CI), Bazel-based incremental CI, buildpipe for Buildkite |
| Migration | Bazel migration tooling, Gazelle, tomono |
| Workflows | Trunk-Based Development, Branch By Abstraction |

Reading list highlights: Google's paper on a single repository for billions of lines, Atlassian's Git scaling guide, Facebook's Mercurial scaling post, essays on monorepo advantages. Correction to the existing sources table: the list has no dedicated caching section; caching appears only in the Nix remote-caching entry.

## Part B: GitHub Well-Architected page (not read from source)

Not read from source. Well-established general knowledge, labeled as such: monorepos give atomic cross-project changes and easier refactors but need path-aware CI, caching and ownership rules; polyrepos give clear ownership and isolation but risk version drift. The existing skill's SKILL.md and sources.md describe the page's claims; this reference does not independently verify them.

## Decision rules (own synthesis)

- Choose a monorepo when packages share domain models or need atomic releases and you can invest in affected-only builds.
- Stay polyrepo or flat when teams release independently with stable contracts.
- Never adopt a monorepo without three things: a dependency graph, boundary rules (CODEOWNERS plus import restrictions) and affected-task detection.

## Example: affected-only CI step (sketch)

```
changed = git diff --name-only origin/main...HEAD
affected = graph.dependents_of(packages_containing(changed))
run test,build for affected only   # others served from cache
```

## How an agent should apply this

- Recommend tools by need (build graph, cache, ownership, Git scale) rather than naming one product by default.
- Require CODEOWNERS and affected-build CI in any monorepo proposal.
- Use sparse-checkout or shallow clones in the plan when repo size is a concern.
- When citing the GitHub Well-Architected page, say it was unavailable to verify.
