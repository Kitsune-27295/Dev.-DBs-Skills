# Existing Audit Skills Compared

Sources: https://mcpmarket.com/tools/skills/repo-research-analysis · https://github.com/Consensys/repo-security-review · https://www.skillsdirectory.com/skills/mrwangjusttodo-open-source-repo-analysis · https://www.skillsdirectory.com/skills/jmagly-repo-analyzer · https://github.com/Ycsyyds/codebase-analysis-skill · Last verified 2026-11-27 (only the Consensys README was re-read; the other four listings were not reached, so their rows keep the 2026-11-24 summaries)

All pages were read through a summarizing fetch tool, so details below are what those summaries reported; none of the repos' full files were read except where stated in `sources.md`.

## Comparison

| Skill | Core job | Strengths to borrow | Gaps for due diligence |
|---|---|---|---|
| Repo Research (mcpmarket listing) | Find, shallow-clone into a date-stamped research dir, analyze architecture, dependencies and security, compare repos and cross-analyze with the local codebase, write Markdown reports and matrices | Date-stamped workspace; comparison matrix; cross-analysis with the user's project | Listing is thin on how safety is enforced; no evidence classes or verdict rubric reported |
| repo-security-review (Consensys) | Phased security review: secrets, architecture, dependency CVEs, OWASP scan, AI-skill security, validation, report | Finder vs judge split; Confirmed / Needs Review / Rejected; vendor adoption mode; per-phase isolation; degrade-not-fail on missing tools | Aimed at security, not architecture or license; some modes execute code (runtime, PoC) |
| open-source-repo-analysis (skillsdirectory) | Decide if a clone is needed; temp clone in git-ignored `tmp/`; analyze; ask before deleting | Skip-cloning rule; do not copy external code unless asked; do not run install/build/test unless asked; separate external from local findings | Defines no structure-mapping method, comparison procedure or output format |
| repo-analyzer (skillsdirectory) | gh CLI: access check, structure, docs, dependencies, contributions; checkpoints; health report | Grounding checks; ask-before-guessing list; error ladder with three retries; checkpoint files per phase; documentation and activity metrics | Excludes source code; "outdated" and "vulnerable" counts undefined; no license or supply-chain analysis |
| codebase-analysis-skill | Nine-phase deep analysis of a local codebase with VERIFY tags and a five-step verification loop | Coverage plan before deep reading; file:line verification gate; Q&A on design rationale; gotchas list | Heavy (many output files); assumes you own the code; no untrusted-input posture |

## What this skill adds

1. A **safety envelope** that treats the repo as untrusted data (none of the five states one as a first-class rule).
2. **Observation / Inference / Gap** classes with confidence and an evidence table (the REA discipline), instead of free prose.
3. **Scope tiers** with stopping criteria and a sampling order for token economy.
4. **License and provenance** checks, including supply-chain signals.
5. A **verdict rubric** tied to evidence.
6. Variants: security pass, comparison, clean-room extraction.

## Design choices that resolve disagreements

- Where to clone: the clone-cache skill uses the project's own git-ignored `tmp/`; this skill prefers a directory outside the project (or `.git/info/exclude`) because untrusted files inside the project can be picked up by tooling.
- Whether to run things: the security skill offers runtime checks; this skill makes execution opt-in, sandboxed and user-approved.
- Depth: the codebase-analysis skill's nine phases are overkill for adoption triage; tiers let the user choose.

## How an agent should apply this

- Reuse the borrowed mechanics (gh ladder, judge step, verification gate) rather than reinventing them.
- Do not rely on a listing page's claims about another skill; if it matters, read that skill's own file.
- When a user already has one of these skills installed, use this skill's envelope and report shape and let the other skill supply tool-specific steps.
- Keep external findings and local-project findings under separate headings in every comparison.
