# Report Templates and Verdict Rubric

Sources: https://github.com/morluto/rea/blob/main/.agents/skills/reverse-engineer-anything/SKILL.md · https://github.com/Ycsyyds/codebase-analysis-skill · https://www.skillsdirectory.com/skills/jmagly-repo-analyzer · https://github.com/Consensys/repo-security-review · Last verified 2026-11-24

Phase 4 of `oss-deep-audit`. The audit output has exactly five sections; this file owns their shape (template ownership: structure lives here, method lives in `SKILL.md`).

## 1. Template

```markdown
# OSS Audit: OWNER/REPO @ COMMIT_SHA
Tier: quick | standard | deep   Variant: default | security | comparison | extraction
Decision served: adopt | integrate | learn | replicate   Date: YYYY-MM-DD

## 1. Executive Summary
Verdict: adopt | adopt with conditions | study only | avoid
Why (3 bullets, each cites an evidence row). Biggest Gap. Coverage line.

## 2. Architectural Map
Stack and package managers. Entry points (table: kind | path:line). Critical path
(numbered hops with path:line). Patterns and coupling. Diagram (mermaid or C4).

## 3. Confirmed Observations vs Inferences
Observations | Inferences (each names its basis) | Gaps (each names what would close it)
Evidence table: claim | class | evidence | confidence

## 4. Risks and Technical Debt
Table: risk | severity | evidence | mitigation. License and provenance verdict.
Not assessed: tools or runtime topics skipped.

## 5. Integration Guide / Next Steps
Conditions to meet. Pinning and sandboxing. Runtime checks that would lift Gaps.
Decision record pointer if adopted.
```

Keep it short: lead with the verdict, put dense material in tables, and write "none found in scope X" instead of silently dropping a section. The codebase-analysis skill's quality gate is worth copying: every claim carries a file:line tag, and a verification pass confirms each tag opens to the claimed code before delivery. The repo-analyzer skill scores documentation out of 10; scores are optional here and, if used, must list the criteria behind the number.

## 2. Verdict rubric

| Dimension | Green | Amber | Red |
|---|---|---|---|
| License | Permissive or compatible, headers consistent | Copyleft that reaches the use, mixed headers, vendored third-party code | No license, non-commercial, incompatible |
| Maintenance | Recent releases, issues answered, more than one active maintainer | Slow, single maintainer | Archived or abandoned with open security issues |
| Security surface | No High Observations, no install-time code | Telemetry or exec surfaces that are documented and controllable | Hidden network calls, obfuscation, credential harvesting, malicious install scripts |
| Architecture fit | Clear boundaries, critical path understood | Strong coupling or global state | Cannot be traced, or contradicts needs |
| Evidence quality | Mostly Observations | Material Inferences | Verdict dominated by Gaps |

- **Adopt**: no Red, at most minor Amber, tests or CI observed.
- **Adopt with conditions**: Amber items each convertible into a checkable condition (pin SHA, vendor and review, sandbox, disable telemetry, replace a dependency). Also the cap when Gaps dominate.
- **Study only**: Red license or maturity but valuable design; learning allowed, reuse not.
- **Avoid**: any Red security Observation, or Red license with no workaround, or evidence too thin for the stakes.

A verdict cites the evidence rows that drive it. Never use stars, README tone or popularity as a driver.

## 3. Comparison matrix (two-repo variant)

| Criterion | Repo A | Repo B | Evidence |
|---|---|---|---|
| License and obligations | | | |
| Maintenance and bus factor | | | |
| Architecture fit with the local project | | | |
| Dependency weight and risk | | | |
| Security surface | | | |
| Integration cost | | | |

Run both repos at the same tier, commit-pinned. Keep two headings: findings about each external repo, and findings about the local project (the clone-cache skill's guardrail: distinguish them clearly). End with one verdict per repo, the ranking, and the condition that would flip it.

## 4. Worked Observation / Inference / Gap triple

- **Observation**: `package.json:21` declares `"postinstall": "node scripts/fetch-binary.js"`, and `scripts/fetch-binary.js:9-18` downloads an archive from a hard-coded third-party host and extracts it into `bin/`. Evidence: file reads. Confidence: High.
- **Inference**: installing this package would run that download on every consumer machine and CI runner, because npm runs `postinstall` by default, so the downloaded binary becomes part of the trusted code base. Basis: the Observation plus standard package-manager behavior. Confidence: Medium (consumers may install with scripts disabled).
- **Gap**: whether the archive is checksum-verified, what the binary does, and whether the host serves different content over time; the script pins no hash. Needs: the binary and a sandboxed run, or a published provenance record. Confidence: Unknown.
- **Effect on verdict**: Amber on supply chain; condition "install with scripts disabled, vendor and review the binary, pin its hash" before "adopt with conditions".

## How an agent should apply this

- Fill the template literally; do not add or rename the five sections.
- Put the evidence table in section 3 and reference its rows from sections 1 and 4.
- Score each rubric dimension before choosing the verdict, and cite the driving rows.
- For comparisons, use the same commit-pinned tier for both and keep external vs local findings separate.
- Before delivering, open every cited path:line once to confirm it says what the audit claims.

## Evidence ledger example (moved from SKILL.md, 2026-11-24)

Evidence table (keep one running ledger, reuse it in the report):

| Claim | Class | Evidence (`path:line` or command) | Confidence |
|---|---|---|---|
| Entry point is `cmd/server/main.go` | Observation | `cmd/server/main.go:12` | High |
| Writes to Postgres only through `repo/` | Inference | grep of `sql.Open` hits only `repo/db.go:30` | Medium |
| Sends usage telemetry in production | Gap | needs a runtime capture; code has a flag at `cfg.go:55` | Unknown |
