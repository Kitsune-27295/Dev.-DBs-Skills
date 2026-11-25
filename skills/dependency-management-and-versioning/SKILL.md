---
name: dependency-management-and-versioning
description: "Choose, declare, resolve, lock and update dependencies correctly per ecosystem: what SemVer 2.0.0 does and does not promise, version ranges versus lockfiles (applications lock, libraries declare ranges), deterministic CI installs, diamond and transitive conflicts (npm/pnpm/Yarn, pip/uv/Poetry/pip-tools, Go MVS, Cargo, NuGet with Central Package Management), purl identifiers, reproducible-build basics, and the agent's rules before adding a dependency and when bumping one. Use when adding, removing, pinning or upgrading a dependency, editing a manifest or lockfile, fixing a version conflict or a non-reproducible install, or setting up a CI install step."
---

# Dependency Management and Versioning

One idea: a dependency is a decision with a lifetime. Declare what you accept (a range), record what you got (a lock), install exactly that in CI, and change it one deliberate step at a time. Sources and what was not confirmed: [references/sources.md](references/sources.md).

Out of scope here, owned elsewhere: SBOMs, SLSA, advisory databases, license compliance, typosquatting and dependency confusion, CI hardening belong to `software-supply-chain-security`. Judging one advisory belongs to `vulnerability-triage`. Auditing an external repository belongs to `oss-deep-audit`. Commit shape belongs to `git-atomic-commits`. Flaky CI belongs to `ci-test-reliability`. Cloud app conventions (dependencies declared explicitly) are in `twelve-factor-cloud-native`.

## 1. SemVer 2.0.0: the promise and its limits

- MAJOR.MINOR.PATCH: MAJOR for incompatible API changes, MINOR for compatible additions, PATCH for compatible fixes. Lower numbers reset when a higher one rises.
- `0.y.z` is initial development: "Anything MAY change at any time." Treat every `0.x` bump as potentially breaking.
- A pre-release ranks below its normal version (`1.0.0-alpha` < `1.0.0`). Build metadata after `+` is ignored in precedence.
- A released version is immutable; fixes ship as a new version. Deprecation requires a MINOR bump.
- It is a convention the author chose to follow, not a guarantee a tool enforces. Ecosystems rely on it (Cargo unifies by it), so a mislabelled release breaks resolution and users. Details: [references/semver-and-version-constraints.md](references/semver-and-version-constraints.md).

## 2. Ranges versus locks

- Manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, project file): the range you accept. Lockfile: the exact closure that was resolved and tested.
- Applications and anything deployed: commit the lockfile and install from it. Libraries: declare the widest range you tested; a library's lockfile does not flow to its consumers (NuGet and Cargo docs both say so), so test the newest range edge in CI too.
- Go is the exception by design: MVS makes the build list deterministic from `go.mod` alone; `go.sum` holds hashes, not a resolution.

## 3. Deterministic installs in CI

Install from the lock and fail if it is stale; never let CI rewrite it. Verified commands per ecosystem are in section 7 and [references/lockfiles-and-deterministic-installs-by-ecosystem.md](references/lockfiles-and-deterministic-installs-by-ecosystem.md). Floating versions (`4.*`, `latest`) without a lock make two runs differ.

## 4. Diamond and transitive conflicts

Two dependencies need different versions of a third. Each ecosystem decides differently: Go picks the highest required minimum, NuGet the lowest applicable version with "direct dependency wins", Cargo unifies SemVer-compatible versions and can keep incompatible majors side by side, .NET needs a single version. Fix by adding your own direct requirement or a central pin, not by editing the lockfile by hand. See [references/resolution-and-diamond-conflicts.md](references/resolution-and-diamond-conflicts.md).

## 5. Identity and reproducibility

- Name a package across tools with a purl: `pkg:type/namespace/name@version`, for example `pkg:pypi/django@1.11.1`.
- Reproducible builds need pinned inputs (hashes in the lock) and no embedded wall-clock time: honor `SOURCE_DATE_EPOCH` (seconds since the Unix epoch). See [references/purl-and-reproducible-builds.md](references/purl-and-reproducible-builds.md).

## 6. Rules before adding a dependency

1. Need: can the standard library or code already in the repo do it in a few lines? If yes, do not add.
2. Maintenance: recent releases, responsive issues, a stable major. A dead package is a future fork.
3. Size and transitive weight: look at what it pulls in (`cargo tree`, `go list -m all`, the lockfile diff). Fewer dependencies mean fewer diamonds.
4. License: check it against the project's policy; the method belongs to `software-supply-chain-security`.
5. Pin appropriately: application gets the lock plus a compatible range; library gets the widest tested range, no exact pin.
6. Prod versus dev: tests, linters and build tools go in the dev group, never in runtime dependencies.
7. Add one dependency per commit, with the manifest and lockfile change together.

## 7. Rules when updating

1. One bump per commit (or one tightly related group such as a framework and its plugin).
2. Read the changelog and release notes for the span you cross, and check for MAJOR or `0.x` steps.
3. Run the full tests after the bump, not just the affected ones.
4. Prefer targeted upgrades over "update everything".
5. Never edit a lockfile by hand and never delete it to "fix" a conflict.
6. If a bump breaks the build and the fix is large, revert the bump and open a separate task.

Per-ecosystem commands (each seen on an official page; see sources):

| Ecosystem | Do | Do not |
|---|---|---|
| npm | `npm ci` in CI; `npm install --save-dev <pkg>` for dev tools; `--save-exact` when you must pin | `npm install` in CI (it may rewrite the lock) |
| pnpm | `pnpm install --frozen-lockfile` | `--no-frozen-lockfile` in CI unless a bump is the job |
| Yarn | `yarn install --immutable` | disabling immutability in CI |
| pip | pin with `==`; `pip freeze` output as a starting point; `--hash=sha256:<digest>` entries | unpinned `pip install foo` in CI |
| pip-tools | `pip-compile requirements.in`, `pip-compile --upgrade-package <pkg>`, `pip-sync` | `pip-compile --upgrade` for a one-package bump |
| uv | `uv add <pkg>`, `uv add --dev <pkg>`, `uv remove <pkg>`, `uv lock --check`, `uv run --locked` | `uv run --frozen` when you need staleness caught |
| Poetry | commit `poetry.lock` for applications; `poetry install` uses it | assuming `pip install` reads it (it does not) |
| Go | `go get <module>@<version>`, `go get -u=patch ./...`, `go mod tidy`, `go mod tidy -diff` in CI, `go mod verify` | `-u` across everything for one fix; `go get -insecure` |
| Cargo | `cargo update <name>`, `cargo tree -d` to find duplicates, `--locked` in CI, `cargo install --locked` | `cargo update` with no argument for a single fix |
| NuGet | `dotnet restore --locked-mode` in CI, `RestorePackagesWithLockFile`, central versions in `Directory.Packages.props` | upper-bound or exact-version ranges in libraries |

## Quick Decision Checklist

- [ ] Is the dependency really needed, maintained and licensed acceptably?
- [ ] Is it in the right group (runtime or dev)?
- [ ] Application: lockfile committed? Library: range declared, wide, no exact pin?
- [ ] Manifest and lockfile changed together, in one commit?
- [ ] CI installs from the lock and fails if it is stale?
- [ ] Changelog read for the version span; MAJOR and `0.x` steps flagged?
- [ ] Full tests ran after the bump?
- [ ] Conflict fixed with a direct requirement or central pin, not a hand-edited lock?
- [ ] No `latest` or unbounded floating versions without a lock?
- [ ] Supply-chain checks (SBOM, advisories, provenance) routed to `software-supply-chain-security`?

## Deep references

- [references/sources.md](references/sources.md): retrieved statuses, reading limits, claims not adopted.
- [references/semver-and-version-constraints.md](references/semver-and-version-constraints.md): SemVer rules, range syntax, what is not guaranteed.
- [references/lockfiles-and-deterministic-installs-by-ecosystem.md](references/lockfiles-and-deterministic-installs-by-ecosystem.md): lock files and frozen installs per ecosystem.
- [references/resolution-and-diamond-conflicts.md](references/resolution-and-diamond-conflicts.md): how each ecosystem resolves conflicts and how to fix them.
- [references/purl-and-reproducible-builds.md](references/purl-and-reproducible-builds.md): purl syntax, `SOURCE_DATE_EPOCH`, hashes.
