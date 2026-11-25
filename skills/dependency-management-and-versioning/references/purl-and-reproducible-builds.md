# purl and Reproducible Builds

Sources: https://github.com/package-url/purl-spec ; https://reproducible-builds.org/docs/source-date-epoch/ ; https://docs.npmjs.com/cli/v10/configuring-npm/package-lock-json ; https://pip.pypa.io/en/stable/topics/repeatable-installs/ ; https://go.dev/ref/mod

Last verified 2026-11-25

## purl: one name for a package everywhere

A purl (package URL) is a URL-shaped string that identifies a package the same way across ecosystems and tools. The repository page gives the form `pkg:type/namespace/name@version?qualifiers#subpath`:

- `pkg` is the fixed scheme; `type` is the ecosystem or protocol (npm, pypi, maven, golang);
- `namespace` is optional and type-specific (a Maven group id, a GitHub user);
- `name` is required; `version`, `qualifiers` (such as architecture or repository) and `subpath` are optional.

Examples from the page: `pkg:pypi/django@1.11.1`, `pkg:npm/%40angular/animation@12.3.1` (note the encoded `@` in the npm scope), `pkg:golang/google.golang.org/genproto#googleapis/api/annotations`. The page states purl is Ecma standard ECMA-427.

A purl names a package version; it is not a range. Use it when a report, issue or comment must say exactly which package and version is meant, so a human or another tool can match it without guessing the registry.

## Reproducible builds: same inputs, same bytes

Two builds of the same source should produce identical artifacts. Dependencies enter this in two ways: which versions are used (the lock) and whether the bytes behind a version are the same (hashes). npm lock entries carry an `integrity` string; pip accepts `--hash=sha256:<digest>` per requirement and verifies downloads; Go's `go.sum` stores SHA-256 hashes of modules. A changed artifact under an unchanged version then fails verification instead of slipping in.

## SOURCE_DATE_EPOCH

Builds often embed the current time (in archives, file headers, version banners), which makes two otherwise identical builds differ. `SOURCE_DATE_EPOCH` is a standardized environment variable holding the time of the last source modification as an integer count of seconds since the Unix epoch (UTC). The page's rule for tools: if it is set, behave as if the current time were that value; if unset, fall back to now. A common way to set it from Git, taken from the page:

```
export SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
```

Pinning the clock does not make a build reproducible by itself; unpinned dependency versions, unordered file lists and varying paths also change output. This file covers the dependency side only.

## Example

A release script records `pkg:npm/lodash@4.17.21` in its notes, installs with `npm ci`, exports `SOURCE_DATE_EPOCH` from the tagged commit, and builds twice; if the two outputs differ, the cause is searched in the lock first, then in timestamps.

## How an agent should apply this

1. When citing a dependency in a report or commit message, write its purl if the ecosystem is not obvious from context.
2. Percent-encode special characters such as the `@` of an npm scope, as the page's example does.
3. For a reproducibility task, install from the lock with hashes intact, then set `SOURCE_DATE_EPOCH` from the commit being built.
4. If two builds differ, check dependency drift first (lock diff), then embedded time, before blaming the compiler.
5. SBOM generation, provenance and attestations belong to `software-supply-chain-security`.
