# SLSA v1.0 and Provenance

Sources: https://slsa.dev/spec/v1.0/levels ; https://slsa.dev/spec/v1.0/provenance
Last verified 2026-11-25

## Status note

Both pages were fetched under the v1.0 path. The provenance page was marked "Retired" and pointed to version 1.2 as current. This file records v1.0 as read; check the current specification before citing level text in a new document, and do not assume 1.2 changed or kept any rule.

## Build track levels (v1.0)

| Level | Meaning | Protects against |
|---|---|---|
| L0 | No guarantees; dev or test builds | Nothing |
| L1 | Consistent build process; provenance exists and is distributed, possibly unsigned or incomplete | Release mistakes; helps debugging and inventory. Trivial to forge |
| L2 | Hosted build platform; provenance bound to it by digital signature; consumers verify authenticity | Tampering after the build |
| L3 | Hardened: runs cannot influence one another, signing secret unavailable to user-defined steps | Tampering during the build, including insiders, stolen credentials, other tenants |

v1.0 contains only the Build track. The Source track was removed for v1.0 and may return later.

## Provenance predicate

- Predicate type string: `https://slsa.dev/provenance/v1`.
- `buildDefinition`: `buildType` (URI of the template), `externalParameters` (untrusted, must be verified), optional `internalParameters` (set by the platform), `resolvedDependencies` (best-effort completeness).
- `runDetails`: `builder.id` (and optional dependencies, version), `metadata` (`invocationId`, `startedOn`, `finishedOn`), `byproducts`.
- Required for L1: top-level `buildDefinition` and `runDetails`, with `buildType`, `externalParameters`, `builder.id`.

## What verification means

The consumer decides which signer and builder pairs to accept, reads the builder documentation (the builder identity determines the level), rejects unexpected `externalParameters`, and checks `resolvedDependencies`. Provenance that nobody verifies is documentation, not a control.

## Example

An artifact arrives with a provenance file. Claim "L2" only after: the signature verifies, the signer maps to a hosted platform you know, the repository and entry point in `externalParameters` match expectation, and the artifact digest matches the subject.

## How an agent should apply this

1. Say "provenance present" for L1 only; never imply tamper resistance from L1.
2. State an L2 or L3 level only with a named platform and a verification you ran, citing the spec version.
3. Treat `externalParameters` as input to review, not as trusted.
4. For build determinism and artifact identity, use `dependency-management-and-versioning`.
