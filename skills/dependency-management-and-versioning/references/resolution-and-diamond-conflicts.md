# Resolution and Diamond Conflicts

Sources: https://learn.microsoft.com/en-us/dotnet/standard/library-guidance/dependencies ; https://learn.microsoft.com/en-us/nuget/concepts/dependency-resolution ; https://learn.microsoft.com/en-us/nuget/consume-packages/central-package-management ; https://go.dev/ref/mod ; https://doc.rust-lang.org/cargo/reference/resolver.html ; https://docs.npmjs.com/cli/v10/configuring-npm/package-json#dependencies

Last verified 2026-11-25

## The problem

Your project needs A and B. A needs C at one version constraint, B needs C at another. This is a diamond. Whether it is harmless or an error depends on the ecosystem's rule and on whether the constraints overlap.

## How each documented ecosystem decides

**Go (MVS).** The build list takes the highest version of each module required anywhere in the graph, which is "the minimum versions that satisfy all requirements". Newer releases are not selected unless something requires them. Upgrades and downgrades go through `go get`, which changes the graph before MVS runs. `replace` and `exclude` also alter it; `replace` applies only in the main module.

**Cargo.** Prefers the highest available version. SemVer-compatible requirements are unified into one version; if two compatible requirements cannot be unified, Cargo errors. Incompatible versions (for example 0.6.5 and 0.7.3) are both built and coexist, which can cause type mismatches when their types cross crate boundaries. `cargo tree -d` lists duplicates. Resolver `"2"` changes feature unification, and `"3"` makes the resolver prefer versions compatible with your Rust version.

**NuGet.** Four rules: lowest applicable version, floating versions (highest match), direct dependency wins, and cousin dependencies (lowest version satisfying all). Direct-wins can silently downgrade a package, which NuGet reports as a warning. An exact or upper-bound requirement from one package against a higher minimum from another is unresolvable; the fix the docs give is for the top-level consumer to add its own direct dependency. Only one version of an assembly can run in a .NET app, so unification is necessary.

**Central Package Management.** Create `Directory.Packages.props`, set `ManagePackageVersionsCentrally` to `true`, declare `<PackageVersion Include= Version=/>` there, and leave `Version` off each `<PackageReference>`. `CentralPackageTransitivePinningEnabled` pins a transitive dependency without a top-level reference, but downgrades fail with NU1109. `VersionOverride` on a reference beats the central value unless `CentralPackageVersionOverrideEnabled` is `false`. Transitive pinning in a library can add dependencies to your package.

**npm.** The page read documents `overrides` (root `package.json` only) as the way to replace a package anywhere in the tree, and peer dependencies as the way for plugins to state host compatibility; keep peer ranges broad. Hoisting and dedupe rules were not fetched and are not described.

## Fixing a conflict, in order

1. Read the error: which two requirements clash, and which package owns each.
2. Check whether upgrading one parent resolves it, before touching the child.
3. Add your own direct requirement (NuGet, Go `go get module@version`) or a central pin (CPM, npm `overrides`) at the version both can live with.
4. Only then consider a fork or replacement (`replace` in Go), recorded with the reason.
5. Re-run the full tests; unification can pick a version one parent never tested.

## Example

App uses `lib-x` needing `util >=1.0` and `lib-y` needing `util [2.0,3.0)`. Under NuGet's cousin rule the lowest version satisfying both, 2.0.x, is chosen. If `lib-y` required exactly `[1.0]`, restore fails and the app adds a direct `util 2.0` reference.

## How an agent should apply this

1. Prefer the smallest change: a direct requirement or central pin over a fork.
2. Never fix a conflict by deleting the lock or loosening a library's range blindly.
3. For libraries, avoid upper bounds and exact pins; they create the conflicts consumers cannot fix.
4. After resolution, diff the lockfile and name every package whose version moved.
5. Note any duplicate major versions found (`cargo tree -d`, the lock) in the report rather than ignoring them.
