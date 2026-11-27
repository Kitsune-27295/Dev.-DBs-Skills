# Reference Repositories Audit Notes

Sources: https://github.com/agentskills/agentskills · https://github.com/anthropics/skills · https://github.com/google/skills · https://github.com/openai/plugins · https://github.com/openai/skills (read through the GitHub API and raw files only; nothing cloned, nothing run) · Last verified 2026-11-27

Method: the read-only, evidence-first approach of `oss-deep-audit`. Labels: Observation (seen in a fetched file or API field), Inference (reasoned), Gap (not seen). Fetches were summarized by a small model, so counts and wording are second-hand.

## Contents
- agentskills/agentskills
- anthropics/skills
- google/skills
- openai/plugins and openai/skills
- Adoption guidance
- How an agent should apply this

## agentskills/agentskills

Observations: API licence field Apache-2.0; not archived; default branch main. Top-level directories `.claude`, `docs`, `skills-ref`; LICENSE files at root, in `docs/` and in `skills-ref/`. `skills-ref` holds a Python package (`src/skills_ref/` with parser, validator, prompt and CLI modules), tests and a lockfile. Its README calls it demonstration-only. Validator source lists the allowed frontmatter keys and limits (64, 1024, 500) and ignores the body.
Inference: the spec site and this repository are the authority for format; the validator is a reference, not a quality gate.
Gap: tests were not run; the docs folder was not read beyond the website pages.

## anthropics/skills

Observations: API licence field null (no repository-level licence detected); the README says "Many skills in this repo are open source (Apache 2.0)" and that skills are for demonstration and education, and to test before relying on them. Root entries `.claude-plugin`, `README.md`, `THIRD_PARTY_NOTICES.md`, `skills`, `spec`, `template`. Individual skill folders carry their own `LICENSE.txt` (twelve seen in a truncated listing). `template/SKILL.md` is a blank skeleton (name `template-skill`, placeholder description, one heading). `skills/skill-creator/` contains `SKILL.md`, `LICENSE.txt` and directories `agents`, `assets`, `eval-viewer`, `references`, `scripts`. The skill-creator text describes capture intent, interview, write, test cases, with-skill and baseline runs, assertions, timing, grading, benchmark, human review, iteration and description optimization (about 20 queries, 60/40 split, 3 runs, up to 5 iterations), and packaging.
Inference: per-skill licences differ, so check the folder, not just the repo.
Gap: the skill count is not stated in the README; the tree listing was truncated, so no total is claimed. Scripts not read or run.

## google/skills

Observations: API licence Apache-2.0; README says skills are Apache 2.0; not archived. Top-level `skills`, `plugins`, `.agents`, `.claude-plugin`, `index.json`, `LICENSE`, `CONTRIBUTING.md`. The `skills` folder had 6 entries (ads, analytics, cloud, developers, identity, platform-devices), so they are groups, not individual skills. README gives install commands (`npx skills add google/skills`; plugin marketplace commands for Claude Code, Codex and the Antigravity CLI) and states no total count. CONTRIBUTING says external code contributions are not accepted and authoring guidance is internal.
Gap: how many skills exist inside the groups was not counted; the GitHub size field (7661, units not confirmed) is not used as a claim.

## openai/plugins and openai/skills

Observations: `openai/plugins` has a null licence field and no LICENSE among its top-level entries (`.agents`, `.github`, `plugins`, `README.md`); the README says each plugin needs `.codex-plugin/plugin.json` and may bundle `skills/`, `.mcp.json`, `agents/`, `hooks.json`, `assets/`; it states no licence and no install steps. `openai/skills` has a null licence field, description "Skills Catalog for Codex", and its README states "This repository is deprecated." and points to `openai/plugins`; per-skill licences are in each skill folder as `LICENSE.txt`.
Inference: for Codex, plugins are the packaging and distribution unit; the skill folder format is unchanged.
Gap: plugin licence unknown, so treat the examples as ideas only.

## Adoption guidance

- Borrow the method (baseline runs, trigger evals, validators), not text, unless the folder's own licence file allows it and you record it.
- A repository licence of null in the API is not "no licence" proof either way; read the folder and README.
- Counts in third-party articles ("19 official skills", "hundreds of skills") were not confirmed and stay unadopted.

## How an agent should apply this

1. Before reusing anything from these repositories, read the specific skill folder's licence file and record it in your `references/sources.md`.
2. Use `skills-ref` source and the spec page as the format reference; use the skill-creator text as a process model.
3. Re-run the repository checks (licence field, tree, README statements) when the date matters; statuses such as "deprecated" change.
4. Do not execute any script from these repositories without a sandbox and a read-through.
