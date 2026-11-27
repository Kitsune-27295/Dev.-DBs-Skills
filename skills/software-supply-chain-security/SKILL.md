---
name: software-supply-chain-security
description: "Defend and document the software supply chain of a project: name the threat classes (dependency confusion, typosquatting, malicious install scripts, abandoned or compromised packages, CI/workflow compromise) and apply controls (pinning, an ignore-scripts policy, provenance, least-privilege CI tokens, pinned actions, reviewed dependency updates), read SLSA v1.0 levels and provenance, produce and read an SBOM (CycloneDX, SPDX), query OSV, handle a vulnerable dependency and flag licenses for human review. States that an SBOM or a clean scan is not proof of safety. Use when hardening CI or dependency intake, generating or reviewing an SBOM or provenance, or responding to a suspicious package. Not for choosing versions, ranges or lockfiles (use dependency-management-and-versioning) or judging one scanner alert (use vulnerability-triage)."
---

# Software Supply Chain Security

One idea: every package, build step and workflow you consume is code you did not write and run with your privileges, so reduce what you trust, make what you trust verifiable, and write down what you ship. Evidence and limits live in [references/sources.md](references/sources.md).

Boundaries: versions, lockfile mechanics, resolution per ecosystem, purl identity and reproducible builds belong to `dependency-management-and-versioning`. Whether a given CVE is reachable and how urgent it is belongs to `vulnerability-triage`. Auditing an external repository before adopting it belongs to `oss-deep-audit`. Modeling threats of a whole system belongs to `threat-modeling`. Application-code flaws belong to `security-audit`. Flaky CI belongs to `ci-test-reliability`.

## 1. Threat classes and the control that answers each

| Threat | How it happens | First controls |
|---|---|---|
| Dependency confusion | A public package shadows an internal name | Scope or namespace internal packages, configure the registry per scope, never let a resolver fall back to a public index for internal names |
| Typosquatting | A near-identical name is installed by mistake | Review every new dependency name by hand, copy it from the official docs, check age, owner and download history |
| Malicious install scripts | Install or build hooks run code at install time | Treat install as code execution, disable lifecycle scripts by default where the ecosystem allows, allow-list the few that need them |
| Abandoned or compromised package | Maintainer gone, account taken, release hijacked | Pin, use a lockfile, review update diffs, watch advisories, plan a replacement for dead packages |
| CI or workflow compromise | Untrusted input reaches a privileged job, or a third-party action changes under you | Read-only default token, pinned actions, no untrusted checkout in privileged triggers, short-lived credentials |

See [references/threats-and-ci-hardening-controls.md](references/threats-and-ci-hardening-controls.md) for each control and its limits.

## 2. Dependency intake rules

1. Add a dependency only with a stated reason; prefer fewer, well-maintained ones.
2. Verify the name against the official project page, not a search result or a model's memory.
3. Install from the committed lockfile in CI with the read-only form of the install command; a CI job that rewrites the lockfile is a finding.
4. Review the diff of every update (version, changed install hooks, new transitive packages), automated update bots included. Auto-merge only after tests and policy checks.
5. Disable or allow-list install scripts; record each exception with an owner.
6. Never run install or build of an untrusted repository on a machine holding credentials.

## 3. CI and workflow hardening

- Default token permission read-only; raise per job, never globally.
- Pin third-party actions or steps to an immutable commit identifier from the original repository; keep first-party reusable workflows under review too.
- Never interpolate untrusted fields (PR title, branch name, issue text) into shell; pass them through environment variables and quote.
- Do not check out or run untrusted pull request code in triggers that carry secrets or write tokens.
- Prefer short-lived federated credentials to stored long-lived secrets; gate sensitive secrets behind reviewed environments.
- Publishing credentials: separate from test jobs, scoped to one package, protected by 2FA on the account.

## 4. SLSA v1.0 build track

Levels: L0 no guarantees; L1 provenance exists (can be forged); L2 hosted build platform with signed provenance; L3 hardened builds where runs are isolated and the signing secret is out of reach of build steps. Only the Build track exists in v1.0. Provenance is useful only if a consumer verifies the signer, the builder identity and the external parameters. State a level only when you can name the platform that produces the evidence. Detail: [references/slsa-and-provenance.md](references/slsa-and-provenance.md).

## 5. SBOM

An SBOM is an inventory of components and relationships for one build or release. Two mainstream formats: CycloneDX (JSON or XML) and SPDX. Generate from the build or lockfile, not from memory; record tool, time, and which scope was covered; mark completeness honestly (CycloneDX compositions can say complete, incomplete or unknown). An SBOM generated after the fact may not match what was built. Store it next to the release, and sign or hash it. Detail: [references/sbom-cyclonedx-spdx-and-minimum-elements.md](references/sbom-cyclonedx-spdx-and-minimum-elements.md).

## 6. Vulnerability data (OSV)

- Query endpoint: `POST https://api.osv.dev/v1/query` with a JSON body; batch endpoint `POST https://api.osv.dev/v1/querybatch`.
- Body by name and ecosystem: `{"package":{"name":"lodash","ecosystem":"npm"},"version":"4.17.20"}`; ecosystem names are case-sensitive.
- Follow `next_page_token` until it disappears. Set the version in one place only.
- A hit is an input to `vulnerability-triage`, not a verdict; a miss means "not in OSV", not "safe".

Detail and schema notes: [references/osv-vulnerability-data-and-license-compliance.md](references/osv-vulnerability-data-and-license-compliance.md).

## 7. Handling a vulnerable dependency

Order of preference: patch (upgrade to a fixed version, run tests); workaround (provider mitigation or disabling the feature, temporary, documented, alert suppression scoped to that advisory); replace (move to a maintained alternative); last resort, backport the security change onto your version line and track its upkeep. For a transitive package, act through the direct dependency that pulls it in. Ask `vulnerability-triage` whether the flaw is reachable before spending effort; record the decision and the expiry date of any accepted risk.

## 8. License compliance basics

Identify each component's license with an SPDX identifier (for example `MIT`, `Apache-2.0`, `GPL-2.0-or-later`). Group them as permissive (few obligations, mostly notices) or copyleft (obligations that can reach code you distribute). Collect and list; do not interpret. Flag unknown, missing, custom, conflicting or copyleft-in-distributed-code cases for human or legal review. Never state that something is legally safe or compliant.

## 9. What the agent must not claim

- "No vulnerabilities": a clean scan covers known, published, matched entries only.
- "Safe" or "trusted": an SBOM lists components, it proves nothing about their behavior.
- "SLSA Lx": without verified provenance from a named builder.
- "Compliant": license output is a list for review, not a legal opinion.
- Any number, version or standard status you did not read in this session; say "not verified".

## Quick Decision Checklist

- [ ] New dependency: name verified, reason stated, maintainers and age checked.
- [ ] Lockfile committed; CI installs read-only from it.
- [ ] Install scripts disabled or allow-listed with owners.
- [ ] Dependency update diff reviewed, including transitive additions.
- [ ] CI token read-only by default; actions pinned; no untrusted input in shell.
- [ ] Provenance verified against a named builder before any SLSA statement.
- [ ] SBOM generated from the build, with scope and completeness stated.
- [ ] OSV or scanner hits routed to `vulnerability-triage`; decision and expiry recorded.
- [ ] Licenses listed by SPDX identifier; doubtful ones flagged for human review.
- [ ] Report says what was not checked.

## Deep references

- [references/threats-and-ci-hardening-controls.md](references/threats-and-ci-hardening-controls.md)
- [references/slsa-and-provenance.md](references/slsa-and-provenance.md)
- [references/sbom-cyclonedx-spdx-and-minimum-elements.md](references/sbom-cyclonedx-spdx-and-minimum-elements.md)
- [references/osv-vulnerability-data-and-license-compliance.md](references/osv-vulnerability-data-and-license-compliance.md)
- [references/sources.md](references/sources.md)
