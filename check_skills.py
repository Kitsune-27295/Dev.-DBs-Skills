#!/usr/bin/env python3
"""Check that a folder of skills is intact. Standard library only; reads nothing outside the folder you pass.

    python check_skills.py <skills folder>          # e.g. skills, .claude/skills or ~/.claude/skills

For every `<folder>/SKILL.md` it checks: front matter present, `name` equal to the folder name and a valid name,
a non-empty `description` (at most 1024 characters), every relative Markdown link resolving inside the skill folder,
and every mention of another skill of this pack (in backticks) naming a skill that is installed. Exit code 1 on error.
"""

from __future__ import annotations

import pathlib
import re
import sys

PACK = (
    # Engineering & Security Fundamentals (7)
    "fundamentals-audit", "race-condition-fix", "idempotency-fix", "never-trust-the-client",
    "security-audit", "layered-refactor", "integration-tests",
    # Database Fundamentals & Governance (8)
    "database-audit", "database-exposure", "backup-restore-drill", "database-cost-guard", "transaction-fix",
    "schema-and-constraints", "migrations-and-environments", "query-performance",
    # Database Engine Diagnostics (3)
    "sql-server-diagnostics", "postgres-diagnostics", "sqlite-diagnostics",
    # Software Architecture Styles & Patterns (24)
    "architecture-decision-trees-tradeoffs", "ddd-domain-heuristics-debiasing",
    "hexagonal-architecture", "layered-n-tier-architecture", "mvc-architecture", "clean-architecture",
    "monolithic-architecture", "modular-monolith-architecture", "microservices-architecture",
    "serverless-architecture", "event-driven-architecture", "cqrs-pattern", "event-sourcing-pattern",
    "bff-pattern", "micro-frontends-architecture", "vertical-slice-architecture", "screaming-architecture",
    "package-by-feature-component", "repository-root-monorepo-architecture", "microkernel-plugin-architecture",
    "pipes-and-filters-pattern", "actor-model-space-based-architecture", "saga-transactional-outbox-pattern",
    "soa-vs-microservices-architecture",
    # Cloud-Native, Resilience, Evolution & AI (7)
    "agent-skills-context-engineering", "twelve-factor-cloud-native", "circuit-breaker-retry-telemetry",
    "parallel-change-expand-contract", "yagni-evolutionary-architecture",
    "agentic-rag-architecture", "testing-pyramid-and-shapes",
    # Architecture Documentation, Diagrams & Contracts (5)
    "c4-model-architecture", "adr-architecture", "arc42-api-contracts-architecture",
    "diataxis-documentation-architecture", "mermaid",
    # Software Components & Foundational Principles (19)
    "router-front-controller-routing", "api-gateway-reverse-proxy", "middleware-interceptor-chain", "caching-strategies", "background-worker-job-scheduler", "rate-limiter-throttler", "authn-authz-guard", "repository-unit-of-work", "dto-mapper-anti-corruption-layer", "validator-input-parser", "feature-flag-toggle-engine", "state-machine-workflow-engine", "ssot-and-dry", "open-closed-principle", "single-responsibility-cohesion", "dependency-inversion-composition-root", "kiss-yagni-aha", "value-objects-type-invariants", "error-handling-problem-details", "git-atomic-commits", "model-effort-routing", "oss-deep-audit", "deep-web-research", "playwright-qa-orchestrator", "clean-code-for-agents",
    # Code Design, SSOT & Type-Safe Domain Modeling (3)
    "pragmatic-solid-and-ssot", "defensive-domain-modeling", "codebase-design",
    # AI Engineering Workflow — Matt Pocock Pack (8)
    "setup-matt-pocock-skills", "grill-me", "grilling", "to-spec", "to-tickets",
    "implement", "tdd", "code-review",
)
NAME = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
LINK = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")
BACKTICK = re.compile(r"`([a-z0-9-]+)`")
MAX_DESCRIPTION = 1024


def front_matter(text: str) -> dict[str, str] | None:
    """Top-level `key: value` pairs of the leading `---` block (nested keys are ignored on purpose)."""
    text = text.lstrip("\ufeff")
    if not text.startswith("---"):
        return None
    parts = text.split("---", 2)
    if len(parts) < 3:
        return None
    fields: dict[str, str] = {}
    for line in parts[1].splitlines():
        match = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if match:
            fields[match.group(1)] = match.group(2).strip().strip("'\"")
    return fields


def check(root: pathlib.Path) -> list[str]:
    problems: list[str] = []
    skills = sorted(p for p in root.iterdir() if p.is_dir() and (p / "SKILL.md").is_file()) if root.is_dir() else []
    if not skills:
        return [f"{root}: no skill folders (a folder with a SKILL.md) found"]
    installed = {p.name for p in skills}
    for folder in skills:
        text = (folder / "SKILL.md").read_text(encoding="utf-8")
        fields = front_matter(text)
        where = f"{folder.name}/SKILL.md"
        if fields is None:
            problems.append(f"{where}: no front matter between two `---` lines")
            continue
        if fields.get("name") != folder.name:
            problems.append(f"{where}: name is {fields.get('name')!r}, the folder is {folder.name!r}")
        if not NAME.match(fields.get("name", "")):
            problems.append(f"{where}: name must be lowercase letters, digits and single hyphens")
        description = fields.get("description", "")
        if not description:
            problems.append(f"{where}: empty description")
        elif len(description) > MAX_DESCRIPTION:
            problems.append(f"{where}: description is {len(description)} characters (limit {MAX_DESCRIPTION})")
        for md in [folder / "SKILL.md", *sorted(folder.rglob("*.md"))]:
            for target in LINK.findall(md.read_text(encoding="utf-8")):
                if re.match(r"^[a-z][a-z0-9+.-]*:", target):
                    continue  # a URL
                if not (md.parent / target).resolve().exists():
                    problems.append(f"{md.relative_to(root).as_posix()}: link `{target}` does not resolve")
        for mention in sorted(set(BACKTICK.findall(text)) & set(PACK) - {folder.name}):
            if mention not in installed:
                problems.append(f"{where}: refers to `{mention}`, which is not installed here")
    return problems


def main(argv: list[str]) -> int:
    if len(argv) != 1:
        print(__doc__)
        return 2
    root = pathlib.Path(argv[0]).expanduser()
    problems = check(root)
    for line in problems:
        print(f"  [FAIL] {line}")
    count = len([p for p in root.iterdir() if p.is_dir() and (p / 'SKILL.md').is_file()]) if root.is_dir() else 0
    print(f"{'OK' if not problems else 'FAILED'}: {count} skill(s) checked in {root}")
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
