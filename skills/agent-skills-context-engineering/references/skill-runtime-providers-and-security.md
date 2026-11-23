# Skill Runtime, Providers and Security

Sources: https://learn.microsoft.com/en-us/agent-framework/agents/skills · https://www.anthropic.com/research/equipping-agents-for-the-real-world-with-agent-skills · Last verified 2026-11-23

Note: the Microsoft page is about 100 KB; the last ~230 characters (end of the skills-vs-workflows comparison) were not read.

## Contents
- Four runtime stages
- Skill sources
- Provider pipeline: aggregate, dedupe, cache, filter
- Approval and script execution
- Security checklist
- How an agent should apply this

## Four runtime stages
| Stage | Tool | Cost | Notes |
|---|---|---|---|
| Advertise | none | ~100 tokens per skill, each run | names + descriptions in system prompt |
| Load | `load_skill` | under ~5000 tokens recommended | full `SKILL.md` body |
| Read resource | `read_skill_resource` | on demand | only advertised if some skill has resources |
| Run script | `run_skill_script` | on demand | only advertised if some skill has scripts |

Anthropic's own article describes the same three levels: metadata, body, then bundled files "read only when needed", and compares it to a manual with table of contents, chapters and appendix. Its context-flow example: Claude reads `pdf/SKILL.md` via Bash, then optionally `forms.md`; a bundled script extracts form fields without loading the script or the PDF into context. For long Python agents, an unload-skills compaction strategy can drop loaded instructions after use (details not on that page).

## Skill sources (Microsoft Agent Framework)
File-based (`SKILL.md` folders, discovery depth 2; resources `.md .json .yaml .yml .csv .xml .txt`; scripts `.py .js .sh .ps1`), code-defined (inline skills with closures, runtime-generated), class-based (packaged as NuGet/PyPI) and MCP-based (`skill://index.json`, entries `skill-md` or ZIP `archive`). Loading is strict: invalid YAML, duplicate known fields, wrong casing, or a list where a scalar belongs stops that skill from loading; unknown top-level fields are ignored; bad `metadata` entries are skipped with a warning. **Scripts inside MCP archives are never executed**, only exposed as read-only resources.

## Provider pipeline
Leaf sources feed an aggregating source (concatenation in registration order, no dedup), wrapped by chainable decorators:
- **Deduplicating:** case-insensitive, first registration wins, logs a warning.
- **Caching:** concurrent callers share one fetch per key; configurable refresh interval.
- **Filtering:** predicate over `(skill, context)`, context carries agent and session.

Convenience constructors add dedup + caching automatically; a caller-supplied pipeline is used as-is (Python) or composed manually (C#). **Tenant isolation trap:** caching a context-aware source in one bucket can serve one tenant's skills to another; add a cache isolation key selector.

```python
provider = SkillsProvider(
    CachingSkillsSource(
        DeduplicatingSkillsSource(AggregatingSkillsSource([files_src, inline_src])),
        refresh_interval=timedelta(minutes=5),
        cache_isolation_key_selector=lambda ctx: ctx.agent.name))
```

## Approval and script execution
All three skill tools require approval by default. Ready-made rules auto-approve read-only tools (load, read resource) while still gating script runs; per-tool opt-outs exist but should be limited to trusted sources. Both rules reject hosted function calls. Forwarding detailed script exceptions to the model can leak sensitive data. The bundled subprocess runner is demonstration-only: production needs sandboxing, resource limits, allow-lists and audit logs. Scripts receive arguments as a JSON array of strings; host-only values (tenant id, precision) travel via invocation context the model cannot set.

## Security checklist
Both sources agree: a skill is instructions plus code, so a malicious one can inject prompts, exfiltrate data, or run unintended actions.
1. Install only from trusted, versioned sources; watch for typosquatted names.
2. Read `SKILL.md`, scripts, dependencies and resources before enabling; be suspicious of instructions that contact external network sources.
3. Treat MCP skill servers as untrusted input; connect only to vetted ones.
4. Sandbox script execution; limit filesystem and network.
5. Log which skills load, which resources are read, which scripts run.
6. Disable approval only for sources you control.

## How an agent should apply this
- Design skills assuming three disclosure tiers: keep `SKILL.md` as the routing layer and push bulk to resources.
- When advising on multi-tenant hosting, call out cache-key isolation and dedup order explicitly.
- Default to read-only auto-approval plus gated script execution; never recommend the demo subprocess runner for production.
- Before using a third-party skill, audit scripts, dependencies and outbound URLs and report findings.
- Prefer a deterministic bundled script over model-generated code for sorting, parsing and extraction.
