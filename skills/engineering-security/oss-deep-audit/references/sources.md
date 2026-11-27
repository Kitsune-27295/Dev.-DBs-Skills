# Sources — OSS Deep Audit

Rebuilt and re-verified 2026-11-27. "Re-read" means fetched again that day with WebFetch (a summarizing fetch, not raw text).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://github.com/morluto/rea | 200 OK, re-read 2026-11-27 | MIT for REA-authored code, npm package `rea-agents`, one CLI plus one MCP server, supported target kinds. The README does not mention source repositories |
| https://raw.githubusercontent.com/morluto/rea/main/.agents/skills/reverse-engineer-anything/SKILL.md | 200 OK, re-read 2026-11-27 (metadata version "63") | Description says to skip REA for ordinary source-repository architecture analysis; summary-first; finding ledger; observations, inferences, unknowns; bounded negative searches |
| https://api.github.com/repos/morluto/rea/contents/.agents/skills | 200 OK, re-read | Exactly five skill directories (names in the mapping file) |
| https://raw.githubusercontent.com/morluto/rea/main/docs/reference/mcp-contracts.md | 200 OK, first 100,000 of 177,488 characters re-read | Scoped coverage, limitations do not supply coverage, views not more certain than parent, absence not proven by empty results, untrusted-content provenance marker |
| https://raw.githubusercontent.com/morluto/rea/main/docs/reference/limits-and-recovery.md | 200 OK, re-read | Delivery budget versus admission limit, retained Evidence, partial Evidence after failure |
| https://raw.githubusercontent.com/morluto/rea/main/docs/release-exposure.md | 200 OK, re-read | Statuses exposed, not_observed, unknown, not_assessed; no pass verdict, no grade |
| https://raw.githubusercontent.com/morluto/rea/main/SECURITY.md | 200 OK, re-read | Target and project content untrusted; local tool, not a sandbox; isolate hostile targets |
| https://github.com/Consensys/repo-security-review | 200 OK, README re-read (SKILL.md not read); no license shown on the page | Phases, Confirmed / Needs Review / Rejected, vendor adoption mode, tool list |
| https://code.claude.com/docs/en/skills | 200 OK, characters 0 to 100,000 of 121,124 re-read | Frontmatter fields, 1,536-character listing cap, under 500 lines advice, `allowed-tools` and `!` injection behavior, untrusted-folder note |
| https://docs.npmjs.com/cli/v11/using-npm/scripts | 200 OK, re-read | `preinstall`, `install`, `postinstall`, `prepare` (git dependencies) run on install; the page did not state what `ignore-scripts` does |
| https://docs.github.com/en/actions/reference/security/secure-use | 200 OK, re-read | `pull_request_target` and `workflow_run` with untrusted checkout, SHA pinning, self-hosted runners on public repos |
| https://docs.github.com/en/rest/dependency-graph/sboms | 200 OK, re-read | SBOM endpoint path, SPDX JSON; old endpoint scheduled to shut down after 2026-11-13, async generate/fetch flow recommended |
| https://docs.github.com/en/rest/security-advisories/repository-advisories | 200 OK, re-read | List endpoint exists; published advisories are public for public repos |
| https://git-scm.com/docs/git-clone | 200 OK, re-read | `--depth`, `--no-checkout`, `--filter`, `--shallow-since`; the page says nothing about hooks |
| https://google.github.io/osv-scanner/ | 200 OK, re-read | Purpose only; the page gives no command syntax |
| https://mcpmarket.com/tools/skills/repo-research-analysis | Not reached this round (200 OK on 2026-11-24, listing page only) | Date-stamped clone dir, comparison matrices |
| https://www.skillsdirectory.com/skills/mrwangjusttodo-open-source-repo-analysis | Not reached this round (200 OK on 2026-11-24) | Skip-clone rule, no install or build unless asked, separate external from local findings |
| https://www.skillsdirectory.com/skills/jmagly-repo-analyzer | Not reached this round (200 OK on 2026-11-24) | `gh` sequence, error ladder, checkpoints |
| https://github.com/Ycsyyds/codebase-analysis-skill | Not reached this round (200 OK on 2026-11-24) | Coverage plan, file:line verification |
| https://www.gradeworkinggroup.org/ | Not reached this round (200 OK on 2026-11-24) | Certainty graded separately from conclusions |
| REA docs not re-read: `docs/reconstruction-coverage.md`, `docs/reference/reconstruction-obligation-ledgers.md`, `docs/development/*`, `docs/ci-analysis.md`, `docs/getting-started/mcp-prompts.md`, `website/evidence/`, the four non-main REA skills, `AGENTS.md`, `CONTRIBUTING.md` | Not reached this round (read from a local clone on 2026-11-24) | Rows in the mapping and handoff files that cite them keep the earlier reading |
| Third-party skills read for ideas, no text reused (an own-style vault-audit skill; local authoring skills) | Local, not public | Report-folder idea; the authoring-notes reference was dropped in this rebuild |

## Reading limits

- Pages were read through a summarizing fetch tool; wording may be compressed. Firecrawl was unavailable.
- `mcp-contracts.md` was read to character 100,000 of 177,488; the claim "an inference needs a stated limitation" was not found in that part and is not relied on.
- The Claude Code skills page was read to character 100,000 of 121,124.
- Scripts or code in the audited material were never executed; this skill ships none.
- The sibling skills own supply-chain controls, SBOM, SLSA, OSV and lockfile rules; their own sources were not re-checked here.
- The MANIFEST still lists the two deleted reference files until it is regenerated.

## Claims not adopted

- "Rejected maps to False Positives" in Consensys: the page does not say so; this skill uses its own bucket names.
- The Cubic blog numbers and any "local-only" claim beyond SECURITY.md wording.
- That `git -c core.hooksPath=/dev/null` is required: git does not copy hooks on clone, so it is an extra guard only.
- Exact osv-scanner command syntax: not confirmed; check `--help`.
- Whether `ignore-scripts` blocks every lifecycle script: not confirmed on the npm page; owned by `software-supply-chain-security`.
- The report-folder layout is our own design; no public standard prescribes it.
