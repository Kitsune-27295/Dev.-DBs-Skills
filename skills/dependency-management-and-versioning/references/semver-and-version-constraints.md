# SemVer and Version Constraints

Sources: https://semver.org/ ; https://docs.npmjs.com/cli/v10/configuring-npm/package-json#dependencies ; https://learn.microsoft.com/en-us/dotnet/standard/library-guidance/dependencies ; https://learn.microsoft.com/en-us/nuget/concepts/dependency-resolution ; https://doc.rust-lang.org/cargo/reference/resolver.html ; https://python-poetry.org/docs/basic-usage/

Last verified 2026-11-25

## What SemVer 2.0.0 says

A version is MAJOR.MINOR.PATCH. The MAJOR number rises for incompatible public API changes, MINOR for backward-compatible additions, PATCH for backward-compatible fixes; lower numbers reset to zero when a higher one rises. Version `0.y.z` marks initial development where "Anything MAY change at any time". A pre-release label sorts below the plain version, so `1.0.0-alpha` comes before `1.0.0`. Build metadata after `+` is ignored when comparing, so two versions that differ only there have equal precedence. A released version's contents must never change; a fix is a new version. Marking API as deprecated requires a MINOR increment.

## What it does not guarantee

- It is a promise by the author about a declared public API. Nothing in the spec verifies it. A PATCH release can still break you if you relied on behavior the author never declared public.
- `0.x` carries no stability promise at all, so a range that allows `0.x` upgrades is a gamble.
- Different ecosystems add their own meaning. Cargo assumes SemVer and unifies versions that are compatible under caret rules, so a wrongly labelled release can make resolution pick it for everyone. NuGet prefers the lowest applicable version rather than the newest, so the same range resolves differently per tool.
- The spec says nothing about security fixes, support windows or how long a major lives.

## Range syntax you will meet

| Ecosystem | Form | Meaning (as documented) |
|---|---|---|
| npm | `1.2.3` | must match exactly |
| npm | `^1.2.3` | compatible with the version |
| npm | `~1.2.3` | approximately equivalent to the version |
| NuGet | `1.0` | 1.0 or higher, lowest applicable preferred |
| NuGet | `[1.0,2.0)` | 1.0 up to but excluding 2.0 |
| NuGet | `[1.0]` | exactly 1.0 |
| NuGet | `3.6.*` | floating: highest 3.6.x |
| Poetry | `^2.13.0` | caret requirement in `pyproject.toml` (exact semantics are on a separate page, not read) |

## Choosing a range

- Application: a compatible range (caret) plus a lockfile is enough. The lock carries precision; the range expresses which upgrades you are willing to take.
- Library: declare the minimum you actually tested and leave the top open. Microsoft's guidance for .NET libraries is to avoid exact-version and upper-bound ranges, because an upper bound turns every diamond with a newer sibling into a hard error.
- Never combine a floating range with no lock in anything that ships.

## Example

A library tests against `requests` 2.28 to 2.31. It declares `>=2.28` and runs one CI job against the newest release. It does not write `==2.31.0`, which would force every consumer onto that exact version.

## How an agent should apply this

1. Read the version span of a bump: MAJOR or `0.x` changes get the changelog read and a closer test pass; PATCH is lowest risk but not zero.
2. When writing a manifest entry, pick the range by role: app compatible range, library wide minimum, dev tool tighter.
3. Do not add upper bounds or exact pins to a library unless a documented incompatibility forces it, and leave a comment saying why.
4. Treat a pre-release or `0.x` dependency as a decision to record, not a default.
5. Do not infer guarantees from a version number; verify with tests.
