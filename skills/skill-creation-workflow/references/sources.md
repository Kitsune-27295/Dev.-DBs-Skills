# Sources — Skill Creation Workflow

Every URL below was checked during skill authoring (2026-11-27).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://agentskills.io/specification | 200 OK (fetched, summarized) | Frontmatter fields and limits (name 64, description 1024, compatibility 500), directory layout, progressive disclosure numbers, `skills-ref validate` command |
| https://agentskills.io/skill-creation/best-practices | 200 OK | Real-expertise sourcing, add-what-the-agent-lacks, freedom vs fragility, gotchas, templates, validation loops, bundling scripts |
| https://agentskills.io/skill-creation/optimizing-descriptions | 200 OK | Description principles, 20-query eval set (8-10 / 8-10), near-miss negatives, 3 runs, 0.5 threshold, 60/40 split, 5 iterations, 1024 limit |
| https://agentskills.io/skill-creation/evaluating-skills | 200 OK | `evals/evals.json`, with-skill vs without-skill (or snapshot) runs, timing, assertions, grading, benchmark, human review |
| https://github.com/agentskills/agentskills (API metadata, tree, `skills-ref/README.md`, `validator.py`) | 200 OK | Apache-2.0, structure, demonstration-only statement, validator rules |
| https://github.com/anthropics/skills (API metadata, root contents, README, `template/SKILL.md`, `skills/skill-creator/SKILL.md` and folder listing) | 200 OK; git tree listing truncated by the fetch tool | Licence statements, template content, skill-creator process |
| https://github.com/google/skills (API metadata, tree, README, CONTRIBUTING, `skills` listing) | 200 OK | Apache-2.0, 6 top-level groups, install commands, contribution policy |
| https://github.com/openai/plugins (API metadata, contents, README) | 200 OK | Plugin layout, manifest path, null licence field |
| https://github.com/openai/skills (API metadata, README) | 200 OK | README states the repository is deprecated, points to openai/plugins |
| https://code.claude.com/docs/en/skills | 200 OK; last ~21,000 characters not read | Paths, frontmatter fields, 1,536-character listing cap, 500-line advice, strict keys outside Claude Code, testing advice |
| https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | 200 OK | Surfaces, no cross-surface sync, runtime constraints, security considerations |
| https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | 200 OK | 1,024 cap, third person, degrees of freedom, evaluation-driven development, checklist |
| https://antigravity.google/docs/skills/ | 200 OK | Workspace and global skill paths, frontmatter, triggering |
| https://codelabs.developers.google.com/getting-started-with-antigravity-skills | 200 OK (gist only) | Corroborating Antigravity paths |
| https://developers.openai.com/api/docs/guides/tools-skills | 200 OK | Upload, `skill_reference`, limits (50 MB, 500 files, 25 MB), safety advice |
| https://developers.openai.com/codex/skills | 308 redirect to https://learn.chatgpt.com/docs/build-skills (followed, 200 OK) | Codex skill paths, fields, install, invocation |
| https://learn.microsoft.com/en-us/agent-framework/agents/skills | 200 OK; last ~228 characters not read | Discovery sources, four-stage loading, approval, security notes |
| https://modelcontextprotocol.io/specification/2026-07-28 | 200 OK | Page exists; lists "Skills over MCP" as an optional extension |
| https://raw.githubusercontent.com/a2aproject/A2A/main/docs/topics/what-is-a2a.md | 200 OK | MCP vs A2A relationship; does not define AgentSkill |
| https://cloud.google.com/blog/topics/developers-practitioners/behind-the-scenes-how-we-build-test-and-scale-google-agent-skills | 200 OK | With/without evals, CI linters, link checks; nothing on triggering or descriptions |
| https://www.anthropic.com/research/writing-tools-for-agents | 200 OK (gist only) | Not used for rules; tool-design pointer |
| https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf | Fetched as PDF but not readable as text | Not used |
| Firecrawl | Failed (no credits) | Not used; WebFetch used instead |

Not fetched (low weight, not needed): the conorbronsdon builder repository, the gist, building-effective-agents post, the ADK multi-agent patterns post, bkircher/skills, nexu-io/open-design, forums and blogs.

## Reading limits

- Pages were read through a summarizing fetch tool (a small model answers a prompt over the page); wording and numbers may be compressed. Verbatim claims were requested but not byte-checked.
- No repository was cloned and no script from any repository was run.
- The anthropics/skills tree listing was truncated, so no skill count is claimed.
- The Anthropic PDF guide was not read.

## Claims not adopted as fact

- "19 official skills" in the Anthropic repository (third-party guide): not confirmed; README states no count.
- "Hundreds of skills" in google/skills: not confirmed; the `skills` folder showed 6 group directories and the README states no count. The repository size field is not used.
- Apache-2.0 for the whole of anthropics/skills: not confirmed; API licence is null and the README says "many" skills are Apache 2.0; check each folder.
- MCP spec path 2026-07-28: the page loads, but no claim about its status relative to other versions is made.
- "Four-stage loading" is documented for Microsoft Agent Framework only; other hosts document three levels.
- Blog and third-party claims (Medium, Reddit, HN, verdent, claude-world, pinggy) were not used as rules.
- The numeric defaults (20 prompts, 60/40, 3 runs, 0.5, 5 iterations) are the specification guide's starting points, not measured optima.
