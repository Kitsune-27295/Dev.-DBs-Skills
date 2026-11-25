# SBOM: CycloneDX, SPDX and Minimum Elements

Sources: https://cyclonedx.org/specification/overview/ ; https://spdx.dev/use/specifications/ ; https://www.cisa.gov/topics/information-communications-technology-supply-chain-security/sbom ; https://www.nist.gov/itl/executive-order-14028-improving-nations-cybersecurity/software-supply-chain-security-guidance-20
Last verified 2026-11-25

## What an SBOM is

CISA calls it a nested inventory, a list of the ingredients of software, and a building block for supply chain risk management. NIST (EO 14028 guidance page) describes a formal record of components and their relationships, compares it to an ingredient label, and says it complements, not replaces, vulnerability management and vendor risk assessment. NIST warns that an SBOM produced after the fact may not match the dependencies used at build time.

## The two formats

| | CycloneDX | SPDX |
|---|---|---|
| Page states | Version 1.7 (2025-10-21); ECMA-424 (2025-12-10), Ecma TC54 | Version 3.0 current; links ISO/IEC 5962:2021 as the international standard |
| Serializations stated | JSON, XML, Protobuf; media types `application/vnd.cyclonedx+json` and `+xml`; file names `bom.json`, `*.cdx.json` | The page's table lists PDF, HTML, SHACL for 3.0 and RDF/OWL for 2.x; it does not list file serializations such as JSON |
| Strength | BOM kinds beyond software (SaaSBOM, HBOM), compositions with completeness | License identifiers and expressions, long-standing standard |

The CISA page names no formats; NIST lists SPDX, CycloneDX or SWID as standard formats.

## Completeness statements

CycloneDX compositions mark an aggregate as complete, incomplete, incomplete first-party only, incomplete third-party only, or unknown. Use `unknown` when you cannot tell; an honest "incomplete" beats an implied "complete".

## Minimum elements

CISA's page lists a 2026 update to the minimum elements and a 2025 draft whose comment period closed, without enumerating fields; the NIST page says agencies should follow NTIA minimum elements (data fields, automation support, practices and processes) without listing them either. This pass did not read the element list, so the field list is not reproduced as fact. Practical minimum for your own output, as an engineering judgment: component name, version, supplier or origin, a stable identifier, dependency relationships, tool and author of the SBOM, timestamp, plus scope and completeness notes. Check the current CISA or NTIA text before claiming conformance.

## Example

A release job runs a generator on the lockfile and the built image, writes `bom.cdx.json`, records the tool name and version, marks the image layer composition `incomplete` (base image not scanned), and attaches the file to the release with a checksum.

## How an agent should apply this

1. Generate from lockfile or build output; never type components by hand.
2. Record scope, tool, time and completeness; mark gaps.
3. Pick the format the consumer asks for; otherwise state the one chosen.
4. Never write "SBOM attached, so safe"; an SBOM enables lookup, it is not an assurance.
5. Cite conformance to minimum elements only after reading the current official list.
