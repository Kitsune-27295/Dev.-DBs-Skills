# Sources — OSS Deep Audit

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://github.com/morluto/rea/blob/main/.agents/skills/reverse-engineer-anything/SKILL.md | 200 OK via raw.githubusercontent.com (full text read, about 34 KB) | Summary-first rule, observations vs inferences vs unknowns, finding ledger with evidence IDs, staged investigation checklist, bounded negative searches, "skip REA for ordinary source repositories" scope note |
| https://mcpmarket.com/tools/skills/repo-research-analysis | 200 OK (summarized by the fetch tool; listing page only, title reads "Repo Research") | Discover, shallow clone into date-stamped dir, analyze, comparison matrices, cross-analysis with a local project |
| https://github.com/Consensys/repo-security-review | 200 OK (README summarized; full SKILL.md not read) | Phased pipeline, finder vs judge, Confirmed / Needs Review / Rejected, report sections, vendor adoption mode, tool-absence degrades only its phase; license not stated on the page |
| https://www.skillsdirectory.com/skills/mrwangjusttodo-open-source-repo-analysis | 200 OK (summarized) | Skip-clone rule, git-ignored temp clone, shallow clone preference, do not copy code or run install/build/test unless asked, separate external from local findings; structure mapping, comparison and output format are not defined in it |
| https://www.skillsdirectory.com/skills/jmagly-repo-analyzer | 200 OK (summarized) | gh CLI sequence, grounding checks, error ladder, checkpoint files, health metrics; gaps: no license or supply-chain analysis |
| https://github.com/Ycsyyds/codebase-analysis-skill | 200 OK (README summarized; the skill files were not read) | Coverage plan, file:line VERIFY tags, verification loop, gotchas list, template and verification layout |
| https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf | 200 OK (downloaded, converted with pdftotext, about 63 KB of text; two-column layout, read by search and excerpts) | Folder and file naming, frontmatter rules (description under 1024 characters, no angle brackets), progressive disclosure levels, trigger and negative-trigger guidance, testing approach |
| https://code.claude.com/docs/en/skills | 200 OK (first 100,000 of about 119,900 characters read; the evaluation section was not) | Frontmatter fields, 1,536-character listing cap, supporting files, size guidance, invocation control, allowed-tools and shell-injection security notes |
| https://platform.claude.com/cookbook/managed-agents-cma-use-skills-from-a-repo | 200 OK (summarized) | Repo-hosted skill layout and discovery, description as routing signal, repo content influencing the agent (security points partly the summarizer's inference) |
| https://www.cubic.dev/blog/claude-code-skills | 200 OK (summarized); secondary source, low trust | Restates the official authoring advice; its numeric claims were not used |
| Local skill (private install, summarized; not a public URL): REA skill and its evidence-workflow reference | Read locally | Routing by target, summary-first, finding ledger, staged investigation, "observations, inferences, unknowns" rule |
| Local skill (private install, summarized; not a public URL): writing-for-agents and its mechanics note | Read locally | Context pointers, information hierarchy and progressive disclosure, completion criteria, single source of truth, positive phrasing, invocation choice |
| Local skill (private install, summarized; not a public URL): harness-skill-creator and its patterns reference | Read locally | Smallest-skill principle, router-style entry file, validation gates over model self-report |
| Local skill (private install, summarized; not a public URL): skill-review and its audit checklist and patterns | Read locally | Trigger/protocol split, template ownership, gate function, output contract slots |
| Local skill (private install, summarized; not a public URL): skill-creator | Read locally (first part of SKILL.md) | Create-test-iterate loop, assertive descriptions, three-level loading, description optimization idea |
| https://github.com/morluto/rea (repository root, README.md, AGENTS.md, CONTRIBUTING.md, DISCLAIMER.md, SECURITY.md) | Cloned (git clone --depth 1, 9,317 files) and read locally; not executed | Scope and authority rules, "unknown stays unknown", fail-closed integration, untrusted-data threat model |
| https://github.com/morluto/rea/tree/main/.agents/skills (5 skills + references: reverse-engineer-anything, rea-tool-design, rea-ci-tests-audit, rea-analysis-optimization, rea-changelog-update) | Read in full via local clone (.cursor-plugin copy verified byte-identical; no .claude/.codex skills dirs exist) | Phase workflow, finding ledger, summary-first rule, four-way finding classification, baseline pinning, mutation-based test checks, changelog provenance |
| https://github.com/morluto/rea/tree/main/docs (reference/, development/, getting-started/, guides/javascript, reconstruction-coverage, release-exposure, ci-analysis, native-function-matching) | Read via local clone (core docs in full or by section; about 100 format-specific guides and 20 README translations only sampled) | Evidence/coverage/limitations semantics, retained references and paging, unknowns lifecycle, version-comparison tiers, obligation ledger and closure rules, checklist-style audit with unknown/not_assessed |
| https://github.com/morluto/rea/tree/main/website/evidence | Read via local clone (heads of 3 notes) | Provenance-of-claims pattern: pinned SHAs, how counts were collected, what a claim does not measure |
| Local REA skill install (private; summarized) | Read locally (SKILL.md and 6 references; .rea.backup files ignored) | Confirmed older snapshot of the same method (version 42 vs 63 upstream); no environment/desktop-build references |
| REA repo not read in depth: src/, tests/, scripts/, bridge/, native/, third_party/, website locales, plugin manifests (manifests skimmed) | Not read (implementation only; unrelated to the audit method) | None |
| Own-style vault-audit skill | read in full | Third-party skill read for ideas, no text reused: write only in a dated report folder, patches never applied, unverified hypotheses in a leads file (added 2026-11-24) |
| https://www.gradeworkinggroup.org/ | 200 OK (curl, tags stripped) | certainty graded separately from conclusions (added 2026-11-24) |

## Reading limits

- Most pages were read through a summarizing fetch tool (a small model answers a prompt over the page), not as raw text; wording and details may have been compressed. Only the REA skill file (raw download) and the Anthropic PDF (pdftotext) were read as text.
- Firecrawl was unavailable (no credits), so WebFetch and curl were used.
- Full SKILL.md files of repo-security-review, codebase-analysis-skill and the two skillsdirectory skills were not opened; their content here comes from page summaries.
- The Claude Code skills page was read to character 100,000 of about 119,900.
- No claim here depends on the cubic blog; its numbers (listing budget share, bug-rate figures) are its own claims and were not used.
- Nothing in the audited-repo material was executed. Licenses of the public skills were not verified except where a page stated one; none is copied here.
- Local skills are private installs and appear only as paraphrase; no text or paths from them are reproduced.

- (added 2026-11-24) The report-folder layout is our own design; no public standard prescribes it.
