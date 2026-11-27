# Sources — Agent Skills, Context Engineering & Harness Design

Every URL below was re-fetched with WebFetch during the 2026-11-27 rebuild (Firecrawl had no credits). Last verified 2026-11-27.

| # | Source | Retrieved status | What it contributed |
|---|---|---|---|
| 1 | Agent Skills specification, https://agentskills.io/specification | 200 OK, full page | Frontmatter table and limits, `name` rules, directory layout, progressive-disclosure numbers, 500-line advice, one-level file references, `skills-ref validate` |
| 2 | `agentskills/agentskills` repository, https://github.com/agentskills/agentskills | 200 OK | Licenses (Apache-2.0 code, CC-BY-4.0 docs), "originally developed by Anthropic", layout; the page does not describe `skills-ref` or validation |
| 3 | `skills-ref` README, https://raw.githubusercontent.com/agentskills/agentskills/main/skills-ref/README.md | 200 OK | Commands `validate`, `read-properties`, `to-prompt`; "demonstration purposes only" caveat |
| 4 | Claude docs, "Skill authoring best practices", https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | 200 OK, full page | Conciseness, degrees of freedom, per-model testing, naming, third-person descriptions, ToC over 100 lines, one-level references, eval-first process, script advice, checklist |
| 5 | Claude docs, "Agent Skills" overview, https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview | 200 OK, full page | Vendor `name`/`description` rules (XML tags, reserved words), three levels and token table, surface limits (API no network or installs), no sync across surfaces, security guidance |
| 6 | Claude Code docs, "Skills", https://code.claude.com/docs/en/skills | 200 OK, first 100,000 of 121,124 characters read | 20 accepted frontmatter keys, 1,536-character listing truncation, upload-time six-key restriction, reserved names |
| 7 | Microsoft Agent Framework, "Agent Skills", https://learn.microsoft.com/en-us/agent-framework/agents/skills | 200 OK, first 100,000 of 100,228 characters read | Runtime stages and tools, source types, MCP index and digest, decorators, cache isolation, approval defaults, runner and error-detail warnings, skills vs workflows |
| 8 | Anthropic Engineering, "Equipping agents for the real world with Agent Skills", https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills (also served at /research/) | 200 OK | Published 2025-10-16, update 2025-12-18 (open standard); three levels; code-versus-generation rationale; audit guidance |
| 9 | Anthropic, "Effective context engineering for AI agents", https://www.anthropic.com/research/effective-context-engineering-for-ai-agents | 200 OK, fetched twice with targeted questions | Context rot, attention budget, altitude, minimal prompt first, hybrid retrieval, compaction, notes, sub-agents, 1,000-2,000 token summaries |
| 10 | Böckeler, "Harness engineering for coding agent users", https://martinfowler.com/articles/harness-engineering.html | 200 OK, fetched twice with targeted questions | Published 2026-04-02; guides, sensors, computational vs inferential, steering loop, regulation categories, harnessability, templates, open questions |
| 11 | Anthropic Engineering, "Writing tools for agents", https://www.anthropic.com/engineering/writing-tools-for-agents | 200 OK | 25,000-token default cap in Claude Code, 72 vs 206 tokens, parameter naming, errors, held-out evals |
| 12 | MCP "Tools", https://modelcontextprotocol.io/specification/latest/server/tools (2026-07-28) and /specification/2025-06-18/server/tools | 200 OK both, full pages | Tool fields, untrusted annotations, error split, tool-name guidance, security requirements; `description` optional in the newer version |
| 13 | Anthropic Engineering, "Code execution with MCP", https://www.anthropic.com/engineering/code-execution-with-mcp | 200 OK | Published 2025-11-04; definitions and intermediate results cost context; 150,000 to 2,000 token example; sandbox caveat |
| 14 | `anthropics/skills`, https://github.com/anthropics/skills and `skills/skill-creator/SKILL.md` (raw) | 200 OK both | README: many skills Apache-2.0, `spec/` and `template/` folders, no mention of evals; `SKILL.md`: baseline runs, snapshot baseline, description optimization |
| 15 | `obra/superpowers`, https://github.com/obra/superpowers and `skills/writing-skills/SKILL.md` (raw) | 200 OK both | MIT repository (Jesse Vincent); RED/GREEN/REFACTOR method and when not to create a skill, restated in new words |
| 16 | `garrytan/gbrain`, https://github.com/garrytan/gbrain and `skills/context-audit/SKILL.md` (raw) | 200 OK both | MIT repository; report-only audit shape, 2.8 bytes-per-token divisor, green/yellow/red classes |
| 17 | Host pages used to confirm facts owned by `skill-creation-workflow`: https://antigravity.google/docs/skills/ , https://developers.openai.com/api/docs/guides/tools-skills , https://learn.chatgpt.com/docs/build-skills | 200 OK each | Install paths and API limits matched that skill's host table (no discrepancy except the Claude Code sync note below) |

## Reading limits
- The Claude Code skills page and the Microsoft page were read only up to the 100,000-character window; the Claude Code tail (about 21,000 characters) and the last 228 characters of the Microsoft page were not read.
- Source 6 shows `claude.ai account` skills synced to `~/.claude/skills/synced/` in terminal sessions, while source 5 says Claude Code skills are separate from claude.ai; this skill does not rule between them and routes the host-path question to `skill-creation-workflow`.
- Scripts, SQL and data files: none in this skill. The sample `skills-ref` code and the gbrain and `skill-creator` scripts were not read or run.
- Fetches went through a summarizing model, so quoted phrases are as reported by that tool.

## Claims not adopted as fact
- The earlier draft's "unique lowercase filenames because MCP archives collide on `Guide.md` vs `guide.md`" has no support in the sources (only OpenAI's `SKILL.md` match is case-insensitive); removed.
- The earlier draft's "scheduled garbage collection for drift" and "MCP doc retrievers" as harness controls are not in the harness article; removed. The article gives no maturity rating for architecture fitness; the earlier "good" was removed.
- The "2.6 to 3.5 bytes per token" range is not in the cited audit skill (it states 2.8); only 2.8 is attributed, as that skill's calibration.
- "Bigger windows soften context rot" and "hybrid fits legal and finance" as firm rules: the first is not in the article; the second is a tentative "might" there.
- The `~100 tokens`, `5,000 tokens`, `500 lines` and `1,000-2,000 token` figures are recommendations or typical values from the sources, not hard parser limits.
- The five admission questions, the "delete obvious constraints / say every fact once" framing and the typosquatting caution are this skill's own synthesis, not quotations.
- Open-source repo contents beyond the pages read (for example the full `anthropics/skills` license terms for `skill-creator`) were not confirmed.
