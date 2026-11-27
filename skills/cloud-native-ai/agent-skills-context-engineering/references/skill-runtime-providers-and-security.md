# Skill Runtime, Providers and Security

Sources: https://learn.microsoft.com/en-us/agent-framework/agents/skills · https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills · https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview · Last verified 2026-11-27

Note: the Microsoft page is about 100 KB; the final 228 characters (the end of the skills-vs-workflows comparison) were not read.

## Contents
- Four runtime stages
- Skill sources
- Provider pipeline: aggregate, dedupe, cache, filter
- Approval and script execution
- Skills versus workflows
- Security checklist
- How an agent should apply this

## Four runtime stages
| Stage | Tool | Cost | Notes |
|---|---|---|---|
| Advertise | none | about 100 tokens per skill, each run | names and descriptions injected into the system prompt |
| Load | `load_skill` | under 5,000 tokens recommended | full `SKILL.md` body; always advertised |
| Read resource | `read_skill_resource` | on demand | advertised only if at least one skill has resources |
| Run script | `run_skill_script` | on demand | advertised only if at least one skill has scripts |

Anthropic's engineering article (published 2025-10-16; a 2025-12-18 update says Agent Skills was published as an open standard) describes the same levels: metadata, body, then bundled files read only when needed. It argues that code beats token generation for deterministic work such as sorting, and that a script can run without loading its source or the target file into context.

## Skill sources (Microsoft Agent Framework)
- **File-based:** `SKILL.md` folders; the provider searches up to two levels deep by default (configurable). Resources come from `references/` and `assets/` (`.md .json .yaml .yml .csv .xml .txt`); scripts from `scripts/` (Python `.py`; C# also `.js .sh .ps1 .cs .csx`). File-based scripts take their arguments as a JSON array of strings.
- **Code-defined:** inline skills with closures, runtime-generated; scripts run in-process, so no script runner is needed.
- **Class-based:** a class that packages the skill (for example as a NuGet or PyPI package).
- **MCP-based:** `skill://index.json` lists entries of type `skill-md` (fetched on demand) or `archive` (a ZIP downloaded and unpacked). A `digest` must be `sha256:` plus 64 lowercase hex characters when present; a mismatch skips that entry, and a matching digest proves only consistency with the index, not that the server is trustworthy. A missing or unparsable index yields an empty list. Python's MCP source is experimental. **Scripts inside MCP archives are never executed**; they are exposed only as read-only resources.

Loading is strict: invalid YAML, duplicate recognized fields, wrong casing, or a collection where a scalar belongs stops that skill from loading. Unknown top-level fields are ignored. Bad `metadata` entries are skipped with a warning.

## Provider pipeline
Leaf sources feed an aggregating source (registration order, no dedup or filter), wrapped by chainable decorators:
- **Deduplicating:** case-insensitive, first occurrence wins, duplicates logged as warnings.
- **Caching:** concurrent callers for one key share a single fetch; optional refresh interval (default: no expiry).
- **Filtering:** a predicate over the skill and the source context (agent, session).

A caller-supplied source is used as-is in Python (not auto-deduplicated or cached). **Tenant isolation trap:** caching a context-aware source in one shared bucket can replay one agent's or tenant's skills for another; supply a cache isolation key selector (low-cardinality and stable). For long-running Python agents, `UnloadSkillsCompactionStrategy` lets the agent drop loaded skill instructions and resources after the work is done.

## Approval and script execution
All three skill tools require approval by default. Ready-made rules exist: a read-only rule approves `load_skill` and `read_skill_resource` while still prompting for `run_skill_script`; an all-tools rule approves everything. Both reject hosted function calls. Per-tool opt-out flags exist, but the page warns to disable approval only for sources you trust, because skill instructions are injected into the agent's context and `run_skill_script` executes code supplied by the source.
- The bundled subprocess runner is **demonstration only**. Production needs sandboxing (containers; in Python also seccomp or firejail), CPU, memory and wall-clock limits, input validation with an allow-list of scripts, and audit logging.
- **Host-only values:** in Python, declare a `FunctionInvocationContext` parameter on a script or runner; it is hidden from the model-visible schema. A script's `**kwargs` can also receive undeclared model-supplied entries, so a value there is not proof the host supplied it.
- **Error details (C#):** `IncludeDetailedErrors` forwards exception messages to the model; the page warns they can hold connection strings, file paths or a prompt-injection payload. The page does not describe a Python equivalent.

## Skills versus workflows
From the page's comparison (read up to its truncated last bullet): a skill lets the model decide how to execute and runs within one agent turn, so a failure means retrying the whole operation; it suits focused, single-domain tasks and idempotent or low-risk operations. Prefer a workflow for deterministic paths, checkpoint and resume, and steps with side effects that must not repeat (sending email, charging payments).

## Security checklist
Anthropic's article and overview and Microsoft's page agree: a skill is instructions plus code, so a malicious one can inject prompts, exfiltrate data, or run unintended actions.
1. Install only from trusted, versioned sources. (Typosquatting is this pack's own caution, not stated by the sources.)
2. Read `SKILL.md`, scripts, dependencies and bundled resources before enabling; look for unexpected network calls and instructions that connect to external sources. Anthropic adds that fetched external content can carry malicious instructions and that dependencies can change under a trusted skill.
3. Treat MCP skill servers as untrusted input; connect only to vetted ones.
4. Sandbox script execution; limit filesystem and network.
5. Log which skills load, which resources are read, which scripts run.
6. Disable approval only for sources you control.

## How an agent should apply this
- Design skills for three disclosure tiers: `SKILL.md` as the routing layer, bulk in resources.
- For multi-tenant hosting, call out cache-key isolation and dedup order (first registration wins) explicitly.
- Default to read-only auto-approval plus gated script execution; never recommend the demo subprocess runner for production.
- Before using a third-party skill, audit scripts, dependencies and outbound URLs and report findings (`software-supply-chain-security` owns the broader review).
- Prefer a deterministic bundled script over model-generated code for sorting, parsing and extraction.
