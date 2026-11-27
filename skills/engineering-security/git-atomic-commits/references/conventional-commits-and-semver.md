# Conventional Commits 1.0.0 and the SemVer Link

Sources: https://www.conventionalcommits.org/en/v1.0.0/ · https://semver.org/ · Last verified 2026-11-27

## Grammar

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

Key rules from the spec (paraphrased):
- Type is a noun; colon plus one space is mandatory after the type/scope/`!`.
- `feat` = adds a capability; `fix` = corrects a defect. Other types are allowed; the spec does not define them. The set build, chore, ci, docs, style, refactor, perf, test is a common convention (its Angular origin was not re-read on 2026-11-27).
- Scope is an optional noun in parentheses naming a codebase area.
- Body is free text after one blank line; footers come after another blank line, each as `Token: value` or `Token #value`. Footer tokens use hyphens instead of spaces, except `BREAKING CHANGE`, which may keep the space (`BREAKING-CHANGE` is equivalent).
- A breaking change is signaled by a `!` right before the colon, by a `BREAKING CHANGE: <description>` footer, or both. With `!`, the footer may be omitted if the description states the break.
- Everything is case-insensitive except `BREAKING CHANGE`, which must be uppercase.

## Mapping to SemVer

SemVer 2.0.0: PATCH for backward-compatible bug fixes; MINOR for new backward-compatible public-API functionality, or for deprecating public API (may also cover substantial internal improvements); MAJOR for incompatible public-API changes. Lower numbers reset to 0 when a higher one bumps. Released versions are immutable: any fix is a new version.

| Commit | Release effect |
|---|---|
| `fix: ...` | PATCH |
| `feat: ...` | MINOR |
| any type with `!` or `BREAKING CHANGE:` | MAJOR |
| `docs:`, `chore:`, `refactor:`, `test:` ... | none by themselves |
| `perf:` | none by spec; teams often treat as PATCH (inference; check tooling config) |

Pre-release (`1.0.0-rc.1`) sorts below its release; build metadata (`+sha`) is ignored in precedence.

Zero-major: `0.y.z` means anything may change. SemVer FAQ: start at 0.1.0, bump minor per release, move to 1.0.0 when others depend on a stable API. Conventional Commits FAQ advises still treating early projects as released.

Deprecation (SemVer FAQ): document it, ship a minor release containing the deprecation, keep at least one minor with it before removal in a major. So commit sequence: `feat: deprecate X in favor of Y` (or `docs`), later `feat!: remove X`.

Accidental break in a minor release: ship a new minor restoring compatibility and document; never edit the released version.

## Examples

```
feat(api)!: drop v1 /users endpoint

BREAKING CHANGE: clients must call /v2/users; /v1 returns 410.
Refs: #482
```
```
fix(parser): reject empty tokens before lookup

An empty token reached the lookup table and raised IndexError on
inputs ending with a comma.
```
```
refactor(billing): extract invoice rounding into one function
```

## Scope guidance

- One scope per commit; if you need two, the commit probably spans two concerns (split).
- Pick scopes from areas people already name (module, package, layer). Do not invent per-commit scopes.
- Multiple types in one change: the FAQ says to split into several commits.

## Fixing a wrong type

Before merge/release: `git rebase -i` and `reword`. After release: depends on the release tooling. A misspelled non-spec type is simply ignored by spec-based tools. In squash-merge workflows the maintainer rewrites the final message, so casual contributors need not comply. Reverts are not defined by the spec; a common choice is a `revert:` type with the reverted SHAs in a footer.

## Use when / avoid when

- Use when the repo generates changelogs or versions from commits, or the team already agreed on the convention.
- Avoid imposing it on a repo with another established message style; match what `git log` shows.
- Breaking-change marking must reflect the *public API contract*, not internal churn.

## How an agent should apply this

- Read `git log --oneline -20` first; follow the repo's existing style, use Conventional Commits only if present or requested.
- Choose type by effect on users: new capability `feat`, defect `fix`, everything else the narrowest non-bumping type.
- If a change breaks the public contract, add `!` and a `BREAKING CHANGE:` footer describing what consumers must do.
- If a diff needs two types, split it into two commits instead of picking the stronger type.
- Do not claim a version number; say which bump the commits imply (PATCH/MINOR/MAJOR) and let release tooling apply it.
- Multi-step breaking migrations: each step is its own commit; see `parallel-change-expand-contract`.
