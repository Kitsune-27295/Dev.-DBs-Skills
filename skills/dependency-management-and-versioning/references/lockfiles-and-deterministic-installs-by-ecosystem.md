# Lockfiles and Deterministic Installs by Ecosystem

Sources: https://docs.npmjs.com/cli/v10/commands/npm-ci ; https://docs.npmjs.com/cli/v10/configuring-npm/package-lock-json ; https://pnpm.io/cli/install ; https://yarnpkg.com/cli/install ; https://pip.pypa.io/en/stable/topics/repeatable-installs/ ; https://pip-tools.pypa.io/en/stable/ ; https://docs.astral.sh/uv/concepts/projects/sync/ ; https://python-poetry.org/docs/basic-usage/ ; https://go.dev/ref/mod ; https://doc.rust-lang.org/cargo/faq.html ; https://doc.rust-lang.org/cargo/reference/resolver.html ; https://learn.microsoft.com/en-us/nuget/consume-packages/package-references-in-project-files

Last verified 2026-11-25

## The shared idea

A manifest says what is acceptable; a lockfile says what was chosen. A deterministic install reads the lock, refuses to change it, and fails loudly when manifest and lock disagree. Locks usually carry content hashes, so a changed artifact under the same version is detected.

## Per ecosystem

**npm.** `npm ci` requires an existing `package-lock.json` or `npm-shrinkwrap.json`, errors if the lock and `package.json` disagree, deletes any existing `node_modules`, and never writes the manifest or lock. If the lock was made with tree-changing flags such as `--legacy-peer-deps`, pass the same flags to `npm ci`. Each lock entry holds an `integrity` value (a Subresource Integrity string). The lock is intended to be committed. `npm install` updates the lock; use it to change dependencies, not to reproduce them.

**pnpm.** `pnpm install --frozen-lockfile` fails if the lockfile is out of sync with the manifest and writes none. In CI it is the default when a lockfile is present; `--no-frozen-lockfile` opts out.

**Yarn.** `yarn install --immutable` aborts if the lockfile would change; it is on by default in CI. `--check-cache` refetches and verifies checksums, recommended for Zero-Installs projects that accept third-party pull requests.

**Python.** pip has no lock of its own. Pinning means `==`; `pip freeze` produces a pinned file including transitive packages; adding `--hash=sha256:<digest>` per entry makes pip verify downloads. With pip-tools, `pip-compile requirements.in` writes the pinned `requirements.txt`, `--generate-hashes` adds hashes, `pip-compile --upgrade-package <pkg>` bumps one package, and `pip-sync` makes the environment match the file. With uv, `uv.lock` is checked by `uv lock --check`; `uv run --locked` errors if the lock is stale, while `--frozen` uses it without checking. With Poetry, `poetry install` uses the exact versions in `poetry.lock`, applications commit it, and `pip install` ignores it.

**Go.** There is no lockfile: "the build list is not saved in a 'lock' file", because MVS is deterministic. `go.mod` states minimums; `go.sum` holds SHA-256 (`h1`) hashes of module contents and `go.mod` files. Since Go 1.16 the `go` command defaults to `-mod=readonly` and errors if `go.mod` needs changes. `go mod tidy -diff` prints needed changes and exits non-zero if any, a usable CI check. `go mod verify` checks that cached modules were not modified since download.

**Cargo.** The resolver gives `Cargo.lock` highest priority when it exists; `--locked` or `--frozen` make Cargo fail instead of updating it. The FAQ says whether to commit it "is dependent on the needs of your package", and warns that it does not affect consumers of your package: `cargo install` selects the latest dependencies unless `--locked` is passed.

**NuGet.** Set `RestorePackagesWithLockFile` to generate `packages.lock.json`. In CI use `dotnet restore --locked-mode` (or `RestoreLockedMode=true`), which restores exactly the locked packages or fails. Commit the lock for applications; do not rely on a library project's lock, because the consuming application's own lock wins. Floating versions such as `4.*` are the case where the page recommends a lock.

## Example CI step (Node)

```
npm ci
npm test
```

If the second command passes only after `npm install` rewrote the lock, the lock was stale; fix it in a separate, reviewed commit.

## How an agent should apply this

1. Identify the ecosystem from the manifest and use its frozen command in CI and in any verification you run.
2. After editing a manifest, regenerate the lock with the ecosystem's own command and commit both together.
3. Never hand-edit a lock; never delete it to make an error go away.
4. If a frozen install fails, the lock is stale or the flags differ: report which, do not silently switch to a non-frozen install.
5. Do not claim a command you have not seen on an official page; where this skill lists none (for example a `uv sync` flag), check the tool's current docs first.
