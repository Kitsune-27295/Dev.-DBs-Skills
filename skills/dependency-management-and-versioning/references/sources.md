# Sources — Dependency Management and Versioning

Every URL below was checked during skill authoring (2026-11-25).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://semver.org/ | Retrieved (fetch OK) | Increment rules, `0.y.z`, pre-release precedence, build metadata, immutability, deprecation |
| https://github.com/package-url/purl-spec | Retrieved (fetch OK) | purl format and examples; states it is Ecma standard ECMA-427 |
| https://reproducible-builds.org/docs/source-date-epoch/ | Retrieved (fetch OK) | `SOURCE_DATE_EPOCH` meaning and usage |
| https://go.dev/ref/mod | Retrieved; first 200000 of 215534 characters read | MVS, no lockfile, `go.sum`, `go mod verify`, `go mod tidy`, `-mod=readonly`, `go get` flags, replace, retract |
| https://doc.rust-lang.org/cargo/reference/resolver.html | Retrieved (fetch OK) | Resolver behavior, SemVer unification, resolver versions, `Cargo.lock` priority, `--locked`/`--frozen` |
| https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html | Retrieved (fetch OK) | `cargo update` forms; no library-vs-binary guidance on this page |
| https://doc.rust-lang.org/cargo/faq.html | Retrieved (fetch OK) | "Why have Cargo.lock in version control?" |
| https://learn.microsoft.com/en-us/dotnet/standard/library-guidance/dependencies | Retrieved (fetch OK) | Diamond dependencies, NuGet range guidance for libraries |
| https://learn.microsoft.com/en-us/nuget/concepts/dependency-resolution | Retrieved (fetch OK) | Four resolution rules, prerelease rule |
| https://learn.microsoft.com/en-us/nuget/consume-packages/central-package-management | Retrieved (fetch OK) | CPM files, properties, transitive pinning, VersionOverride |
| https://learn.microsoft.com/en-us/nuget/consume-packages/package-references-in-project-files | Retrieved (fetch OK) | Lock file, locked mode, library vs application lock advice |
| https://docs.npmjs.com/cli/v10/commands/npm-ci | Retrieved (fetch OK) | `npm ci` semantics |
| https://docs.npmjs.com/cli/v10/commands/npm-install | Retrieved (fetch OK) | `--save-dev`, `--save-exact`, `--ignore-scripts`, lock precedence |
| https://docs.npmjs.com/cli/v10/configuring-npm/package-lock-json | Retrieved (fetch OK) | Purpose, commit advice, `integrity` |
| https://docs.npmjs.com/cli/v10/configuring-npm/package-json#dependencies | Retrieved (fetch OK) | Range operators, dev/peer dependencies, overrides |
| https://pnpm.io/cli/install | Retrieved (fetch OK) | `--frozen-lockfile` and CI behavior |
| https://yarnpkg.com/cli/install | Retrieved (fetch OK) | `--immutable`, `--check-cache` |
| https://pip.pypa.io/en/stable/topics/repeatable-installs/ | Retrieved (fetch OK) | Pinning, `pip freeze`, `--hash=sha256:`, `--no-deps` |
| https://pip-tools.readthedocs.io/en/stable/ | HTTP 302 to https://pip-tools.pypa.io/en/stable/ | Redirect only |
| https://pip-tools.pypa.io/en/stable/ | Retrieved (fetch OK, after redirect) | `pip-compile`, `pip-sync`, `--generate-hashes`, `--upgrade-package` |
| https://docs.astral.sh/uv/concepts/projects/sync/ | Retrieved (fetch OK) | `--locked`, `--frozen` with `uv run`, `uv lock --check` |
| https://docs.astral.sh/uv/concepts/projects/dependencies/ | Retrieved (fetch OK) | `uv add`, `--dev`, `--group`, `uv remove` |
| https://python-poetry.org/docs/basic-usage/ | Retrieved (fetch OK) | Lock behavior, commit advice, pip ignores the lock |

Not fetched (from the candidate list): docs.kernel.org reproducible builds, SemVer rc.2, the supply-chain, SBOM, SLSA and OSV pages (owned by `software-supply-chain-security`), the Python packaging tutorial, go.dev/doc/modules/gomod-ref. No fetch failed outright; the only anomaly was the pip-tools redirect.

## Reading limits

- Pages were read through a summarizing fetch tool, so exact wording was checked only where a quote appears in the references.
- The Go module reference was read up to character 200000 of 215534.
- The SemVer, purl and Poetry pages were summarized; ranges syntax for Poetry was not defined on the page read.

## Claims not adopted as fact

- Any numeric limit or rate limit for registries or OSV: not checked here.
- `pip install --require-hashes`: not on the pip page read; only `--hash=sha256:<digest>` is cited.
- `uv sync --locked` and `--frozen`: the page showed them only with `uv run`; the `uv sync` forms are not claimed.
- `poetry lock`, `poetry check --lock`, `--no-update`: not on the page read. `poetry update` is stated by the page in prose only.
- Library-versus-binary lockfile advice for Cargo: not on the pages read; the FAQ says it depends on the package.
- `cargo update -p`: not on the page read; the positional form is used.
- VERS (version range syntax) as part of the purl ecosystem: the repository page only lists a file name; not described here.
- ISO standardization of purl: the page says it is being progressed; not stated as done.
- npm and pnpm hoisting or dedupe rules, Yarn resolutions, pip's resolver backtracking, uv universal resolution, Poetry's solver: not fetched; not claimed.
- Blog posts and the secondary pages on the candidate list: not used.
