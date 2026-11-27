# Sources - Repository Root & Monorepo Architecture

Every URL below was re-checked on 2026-11-27 (WebFetch; Firecrawl unavailable).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://go.dev/doc/modules/layout | OK, read | Official Go layouts (package, command, supporting `internal/`, multiple commands, `cmd/`, server); no mention of `pkg/` |
| https://pkg.go.dev/cmd/go | OK, "Internal packages" section read (page truncated at first fetch, read on with an offset) | The exact `internal` import rule and example |
| https://github.com/golang-standards/project-layout | OK, README read | Self-declared not an official standard; `/pkg` and `/internal` descriptions |
| https://levelupgo.dev/blog/go-project-structure | OK, read (summary) | Start-flat advice, thin `main`, `pkg/` usually unnecessary, report of a Go tech lead's remark in issue #117 |
| https://github.com/korfuri/awesome-monorepo | OK, read | Tool index (build, ownership, CI, large-repo Git); no caching section |
| https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners | OK, read | CODEOWNERS location, pattern rules, precedence, branch-protection enforcement (added 2026-11-27) |
| https://learn.github.com/well-architected/architecture/recommendations/scaling-git-repositories/repository-architecture-strategy | Unreadable: only the title "GitHub Learn" | Nothing adopted |

## Reading limits
Issue #117 of golang-standards was not opened. No tool (Nx, Turborepo, Bazel) documentation was read, so tool capabilities are not verified. No scripts in this skill.

## Claims not adopted as fact
- The monorepo vs polyrepo advantages, challenges, "9-step activities" and checklist attributed to the GitHub Well-Architected page: unreadable, dropped; the decision table is own judgment.
- The phrasing "every non-internal directory is already importable" and the `madge --circular` / `nx graph` commands: unverified, removed.
- The four-stage escalation and the apps-import-packages-only rule: own synthesis.
- Affected-task graph as a named capability of Nx, Turborepo, Bazel, Buck2, Pants and Gradle: not verified from a read source.
