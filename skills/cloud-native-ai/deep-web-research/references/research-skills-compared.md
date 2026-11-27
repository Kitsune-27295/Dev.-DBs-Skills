# Research Skills Compared

Sources: https://www.aihero.dev/skills-research · https://github.com/Weizhena/Deep-Research-skills · https://github.com/199-biotechnologies/claude-deep-research-skill · https://github.com/robertnowell/deep-research · https://mcpmarket.com/tools/skills/deep-web-researcher · https://github.com/sanjay3290/ai-skills · https://skillselion.com/research-skills · Last verified 2026-11-27

Seven public research skills were read (the Medium comparison article returned HTTP 403 and could not be read; the skillselion directory page held no skill list). Licenses visible: Weizhena MIT, 199-biotechnologies MIT, robertnowell MIT, sanjay3290 Apache-2.0. The MCP Market page showed only a summary (author doodledood, repo claude-code-plugins); its internals were not readable, so its row is thin.

## Comparison

| Skill | Core method | Budget / stop rule | Citation validation | Subagent use | Keys / scripts | Adopt / reject |
|---|---|---|---|---|---|---|
| aihero `/research` | One background agent reads primary sources (docs, source, specs), writes ONE Markdown file with linked claims, reports the path | None; the author says keep questions narrow | None beyond links; reader spot-checks | One background agent; known bug: it can spawn a copy of itself | None | Adopt: file-not-chat output, primary sources only. Reject: no stop rule, no recursion guard |
| Weizhena Deep-Research-skills | Outline (items + fields as YAML) -> user confirms -> per-item parallel agents write JSON -> report | Batch size set in outline; user approves each next batch; resumes by skipping finished items | JSON field validator; uncertain values tagged `[uncertain]` | One agent per item or small group, background | pip pyyaml; Codex needs multi-agent config | Adopt: approval gate, resumable batches, uncertain tags. Reject: rigid fixed prompt template, item-list shape suits comparisons only |
| 199-biotechnologies | Scope, plan, retrieve, triangulate, outline refinement, synthesize, critique, refine, package | Modes Quick/Standard/Deep/UltraDeep (claimed minutes: 2-5, 5-10, 10-20, 20-45); validation loop max 3 cycles | Source registry, evidence store, claim ledger as JSONL; scripts check structure, DOIs/URLs, claim support | 5-10 searches plus 2-3 subagents at retrieval; red-team personas in deep modes | No keys for basics; optional search providers; Python scripts | Adopt: claim ledger, persisted evidence, bounded fix loop. Reject: heavy report templating, 80% prose rule, HTML/PDF packaging |
| robertnowell | Analyze angles, breadth agents, depth agents, optional verification, synthesize | Scope by agent counts (2/3/5 breadth); no time or token cap | Five hard gates; verifier agents return SUPPORTED/PARTIAL/NO/UNAVAILABLE per claim | Sonnet breadth/depth, Haiku verifiers, Explore agent for local code | None | Adopt: tiers, gates, NO_USEFUL_FINDINGS protocol. Reject: printing the whole report inline twice |
| MCP Market Deep Web Researcher | Lead coordinates parallel investigators in waves; targeted follow-ups for gaps and conflicts | Four depth levels auto-picked from the query; no caps documented | Per-finding confidence from authority and independence (scale not shown) | Parallel investigators, several rounds | Temporary Markdown orchestration files as memory | Adopt: wave loop, Markdown memory, auto depth choice. Gaps: stop rules unknown |
| sanjay3290 deep-research | Delegates the whole run to Gemini Deep Research API via a Python script | Claimed by the repo: 2-10 min, about $2-5 per task, 250k-900k input tokens | Whatever the API returns; no local check | None locally; async poll/stream | GEMINI_API_KEY, httpx | Use when: a vendor-hosted long run is acceptable and keys exist. Reject as default: opaque, costly, no ledger |
| skillselion directory | Machine-access page only | n/a | n/a | n/a | n/a | Nothing usable; the llms-full page lists generic top-installed skills, none research-specific |

## Patterns that repeat
- Depth is chosen up front from the question, and each level maps to a fixed number of agents.
- A lead plans; workers search; only the lead writes the final answer.
- Findings are tagged by source quality and by confidence.
- Failed angles are disclosed instead of hidden.

## Where they disagree
- Verification: Haiku-style verifier agents (robertnowell) versus scripts and ledgers (199). Ours can use both, cheaply.
- Memory: JSONL ledgers (199), YAML/JSON per item (Weizhena), Markdown files (MCP Market). Markdown is the simplest for an agent without scripts.
- Stop rules: only 199 documents time and source thresholds; others stop by phase count.

## How an agent should apply this
- Pick depth mode first (quick / standard / deep); do not start every question at maximum.
- Write findings to a file and keep the chat for the decision, as `/research` does.
- Add what the simplest skills lack: an explicit stop rule and a recursion guard for subagents.
- Take the ledger idea from 199 but keep it Markdown, no scripts required.
- Treat delegated vendor deep-research APIs as an optional, costed fallback, never the default.
