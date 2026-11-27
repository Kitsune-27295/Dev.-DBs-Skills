# Sources — Software Supply Chain Security

Every URL below was checked during skill authoring (2026-11-25).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://cheatsheetseries.owasp.org/cheatsheets/Software_Supply_Chain_Security_Cheat_Sheet.html | 200 OK | Stage-based threat grouping, pinning, platform provenance, least privilege |
| https://cheatsheetseries.owasp.org/cheatsheets/Vulnerable_Dependency_Management_Cheat_Sheet.html | 200 OK | Patch, workaround, replace, no-fix and backport cases; transitive handling |
| https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions | 200 OK | SHA pinning, read-only token, script injection, risky triggers, secrets |
| https://github.com/ossf/package-manager-best-practices/blob/main/published/npm.md | 200 OK | Lockfile and read-only install, signature check, 2FA; does not mention ignore-scripts, provenance or trusted publishing |
| https://slsa.dev/spec/v1.0/levels | 200 OK | Build L0-L3 definitions; only the Build track in v1.0 |
| https://slsa.dev/spec/v1.0/provenance | 200 OK (page marked Retired; 1.2 shown as current) | Predicate type, fields, consumer verification |
| https://cyclonedx.org/specification/overview/ | 200 OK | Version 1.7, ECMA-424, formats, media types, compositions |
| https://spdx.dev/use/specifications/ | 200 OK | SPDX 3.0 current, ISO/IEC 5962:2021 link, version table |
| https://spdx.org/licenses/ | 200 OK | Identifiers, list version 3.29.0, WITH and + syntax |
| https://google.github.io/osv.dev/api/ | 200 OK | Endpoints, no-limits statement, 32 MiB cap |
| https://google.github.io/osv.dev/post-v1-query/ | 200 OK | Base URL, request shapes, pagination, matching rules |
| https://ossf.github.io/osv-schema/ | 200 OK | Schema 1.9.2, required fields, range types |
| https://www.cisa.gov/topics/information-communications-technology-supply-chain-security/sbom | 200 OK | SBOM definition, 2026 minimum-elements update listed, no formats named |
| https://www.nist.gov/itl/executive-order-14028-improving-nations-cybersecurity/software-supply-chain-security-guidance-20 | 200 OK (page appears genuine: nist.gov address, created and updated dates; the fetch tool could not independently confirm) | SBOM purpose, limits, capability tiers |

## Reading limits

Pages were read through a summarizing fetch tool, so wording is paraphrase, not quotation. Pages with dynamic content may differ from the live site. The SLSA pages were the retired v1.0 copies. The SPDX license page and the CISA page showed no per-page dates beyond those stated above.

## Claims not adopted as fact

- Exact SBOM minimum-element field lists (CISA 2026 update, NTIA): not enumerated on fetched pages.
- SPDX file serializations (JSON, tag-value) and expression operators AND, OR, `LicenseRef`, `NOASSERTION`: not on fetched pages.
- npm `--ignore-scripts`, npm provenance and trusted publishing: not on the fetched npm guide; verify in current npm docs.
- Dependency confusion and typosquatting definitions: not defined on the fetched pages; descriptions are the skill's own.
- SLSA 1.2 changes: only the retired v1.0 text was read.
- OSV limits: a reading from the API page on this date, may change.
- Blog sources in the candidate list (not fetched): pointers only.
