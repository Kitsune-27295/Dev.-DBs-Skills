# Sources — Skill Orchestrator

Every URL below was checked during skill authoring (2026-11-24).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://github.com/multica-ai/andrej-karpathy-skills (raw CLAUDE.md, EXAMPLES.md, README.md via raw.githubusercontent.com) | 200 OK (LICENSE, LICENSE.md, LICENSE.txt raw: 404; GitHub API license null) | The four principles, 65-line file of 2,357 bytes, "derived from" Karpathy observations, README says MIT, example categories |
| https://github.com/multica-ai/andrej-karpathy-skills/pull/104/files | 200 OK via GitHub API diff and pulls API (open, unmerged) | Codex metadata PR; the same rules kept in sync across CLAUDE.md, a Cursor rule and a skill |
| https://www.skillleaderboard.com/skill/multica-ai-andrej-karpathy-skills | 200 OK (WebFetch) | "Inspired by, not written by Karpathy"; repository stats; no license shown |
| https://www.orcarouter.ai/blog/karpathy-claude-md-file-explained | 200 OK (WebFetch) | Principles recap, advice to audit rules against real failures, no benchmarks, owner mismatch; vendor bias |
| https://www.orcarouter.ai/pt/blog/karpathy-claude-md-file-explained | 200 OK (WebFetch) | Portuguese variant, same content; nothing new |
| https://www.mindstudio.ai/blog/anthropic-claude-code-best-practices-2025 | 200 OK (WebFetch) | Hooks-for-hard-rules idea; no Karpathy mention; unsourced numbers |
| https://www.mindstudio.ai/blog/karpathy-spec-driven-ai-coding-method | 200 OK (WebFetch) | Spec, verifier and environment framing with unsourced attribution; a different framework from the four principles |
| https://code.claude.com/docs/en/best-practices | 200 OK (WebFetch) | Advisory versus deterministic layers, keep CLAUDE.md short, hooks for zero-exception rules, emphasis guidance |
| https://code.claude.com/docs/en/memory | 200 OK (WebFetch, full text) | Scopes and load order, imports (four hops), `.claude/rules/` with `paths`, AGENTS.md fallback (v2.1.277+), size limits, auto memory |
| https://www.anthropic.com/research/claude-code-best-practices | 200 OK; published 2025-04-18, marked no longer maintained | Original CLAUDE.md guidance and emphasis tuning (superseded) |
| https://www.anthropic.com/research/effective-context-engineering-for-ai-agents | 200 OK; published 2025-09-29 | Attention budget, just-in-time retrieval, compaction, CLAUDE.md as the hybrid-strategy example |
| https://www.anthropic.com/constitution | 200 OK (first 100,000 of about 195,000 characters read) | Priority ordering of values, holistic and not strict |
| https://github.com/luongnv89/claude-howto/blob/main/02-memory/README.md | 200 OK, but the WebFetch summary was unrelated in style; treated as unreliable and not used as evidence | Secondary only |
| https://xerj.org/answers/claude-code-memory | 200 OK (updated 2026-11-14) | Secondary confirmation of the 200-line target and load order |
| https://www.reddit.com/r/ClaudeAI/comments/1xlujwl/claude_codes_docs_say_claudemd_is_context_not/ | blocked (fetch refused) | Nothing |
| https://devops.com/claude-code-adds-agents-md-fallback-cutting-instruction-file-sprawl | 403 Forbidden | Nothing; its claims are unverified here |
| https://agents.md/ | 200 OK | Format, nesting (closest file wins), adopters list, symlink migration advice |
| https://github.com/agentsmd/agents.md | 200 OK | README only: MIT license, example; no nesting text |
| https://github.com/TechSpokes/agency-specifications-files-agents-md | 200 OK | Secondary: stricter folder-scoped layout, no evidence of effect |
| https://agentskills.io/specification | 200 OK (read through the raw `docs/specification.mdx` on GitHub, same content) | Frontmatter fields and limits (name 64, description 1024, compatibility 500, metadata, experimental allowed-tools), about 100-token metadata, body under 5000 tokens and 500 lines, validation tool |
| https://github.com/agentskills/agentskills | 200 OK | Validation tool location, Apache 2.0 code and CC-BY-4.0 docs |
| https://raw.githubusercontent.com/agentskills/agentskills/main/skills-ref/README.md | 200 OK | validate, read-properties and to-prompt commands; demonstration-only notice |
| https://agentskills.io/home | 200 OK | No platform count given (only "a large number"), so the "26+ platforms" claim is unverified |
| https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices | 200 OK | Third-person descriptions, what plus when, reserved words and tag bans (vendor additions), 500-line target, evaluation-first |
| https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf | 200 OK (read with a PDF text extractor) | Three-level loading, trigger tests, negative triggers, under- and over-triggering symptoms, 5,000-word body note |
| https://github.com/anthropics/skills | 200 OK | Repository licensing note (many skills Apache 2.0, some source-available) |
| https://raw.githubusercontent.com/anthropics/skills/main/skills/skill-creator/SKILL.md | 200 OK | Pushy descriptions, 20-query trigger eval with held-out split, about 100 words and under 500 lines |
| https://github.com/obra/superpowers | 200 OK | Antigravity note on description-driven loading; harness bootstraps |
| https://raw.githubusercontent.com/obra/superpowers/main/skills/using-superpowers/SKILL.md | 200 OK | The "1%" rule, process before implementation, red-flag table, subagent guard, instruction priority user over skills over defaults; LICENSE raw shows MIT |
| https://www.agentskills.me/skill/using-superpowers | 200 OK | Mirror of the same skill text; no new protocol |
| https://www.atcyrus.com/skills/superpowers-using-superpowers | 200 OK | Listing page with a one-line summary only |
| https://www.verdent.ai/guides/what-is-superpowers-ai-coding-framework | 200 OK | Secondary: session-hook injection, MIT, "150K+ stars" claim, four-phase workflow |
| https://strapi.io/blog/what-are-agent-skills-and-how-to-use-them | 200 OK | Claims only: 30-50 tokens per skill and "26+ platforms" (differ from the spec or unverifiable) |
| https://medium.com/@dan.avila7/claude-code-skills-progressive-disclosure-step-by-step-3ca02a4a9f60 | 403 blocked | Not read |
| https://medium.com/@mubashirburfat4/i-found-7-github-repositories-that-give-claude-code-new-abilities-1ea07bca832a | 403 blocked | Not read |
| https://github.com/coleam00/cole-medin-knowledge-base/blob/main/concepts/progressive-disclosure.md | 200 OK (raw variant read) | "Just in time, not just in case" framing, three layers |
| https://blakecrosley.com/pt-BR/guides/agent-architecture | 200 OK (Portuguese, paraphrased) | LLM-reasoned description matching, hooks as the deterministic layer, shared description budget claim, explicit-invoke retreat for heavy skills |

## Licenses

- `obra/superpowers`: MIT (LICENSE file read). Only its protocol ideas are discussed, in paraphrase.
- `anthropics/skills` (`skill-creator`): Apache-2.0 for this skill; the repository mixes licenses, so check per folder. Paraphrased only.
- `agentskills/agentskills`: code Apache 2.0, documentation CC-BY-4.0, as shown on its page.
- The Karpathy-derived repository: the README says MIT but no LICENSE file was found and the platform API reports no license. Nothing is copied; all wording in this skill is the pack author's own.
- Vendor documentation and blog posts are cited by URL and paraphrased, with quotes kept under about 15 words.

## Claims not adopted as fact

- "26 or more platforms" support skills: a blog claim; the spec home page gives no count (SPEC-03).
- Token figures for skill metadata other than the spec's "about 100 tokens" (for example 30-50 tokens) and any "tokens saved" figure.
- Star and fork counts of repositories and their dates: they differ between listings and change daily.
- MindStudio percentages and its attribution of a spec-verifier-environment method to Karpathy: unsourced.
- The 2025 advice to add emphasis words such as "IMPORTANT" to CLAUDE.md: superseded by the 2026 documentation (EMP-01).
- The 2025 "include everything useful" content list: superseded by the stricter 2026 documentation (INC-01).
- The claim that a shared description budget is about 1% of the context window: one blog; check your host.
- Adoption counts on agents.md (such as 60k+ projects): the site's own claim.

## Reading limits

- The Anthropic constitution was read for its first 100,000 of about 195,000 characters, enough for the priority ordering only.
- The PDF guide was read through text extraction; layout and figures were not inspected.
- The three blocked or refused pages (two Medium posts, one Reddit thread) and the 403 news article were not read; nothing from them is used.
- Version numbers for Claude Code (v2.1.211 to v2.1.316) come from the documentation page as fetched on 2026-11-24 and were not checked against a changelog.
- Behavior of non-Claude tools with AGENTS.md was not verified in their own documentation.
- The original social-media post behind the Karpathy-derived file was not read; only the README's quotes of it.
- Third-party listing pages may lag the repositories they describe.
