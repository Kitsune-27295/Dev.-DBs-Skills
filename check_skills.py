#!/usr/bin/env python3
"""Check that a folder of skills is intact. Standard library only; reads nothing outside the folder you pass.

    python check_skills.py <skills folder>          # e.g. skills, .claude/skills or ~/.claude/skills
    python check_skills.py --write-manifest         # maintainers: rewrite MANIFEST.sha256 from skills/
    python check_skills.py --redundancy [folder]    # repeated paragraphs across skills (first pass of the redundancy review)

Skill folders are found one or two levels deep, so both the pack layout (`skills/<category>/<name>/`) and a flat
installed folder (`<name>/`) work; a skill name must be unique across categories. When the folder is this pack's own
`skills/`, every category folder must also be listed in `.claude-plugin/marketplace.json`.
For every `<folder>/SKILL.md` it checks: front matter present, `name` equal to the folder name and a valid name,
a non-empty `description` (at most 1024 characters), every relative Markdown link resolving inside the skill folder,
and every mention of another skill of this pack (in backticks) naming a skill that is installed. Exit code 1 on error.
"""

from __future__ import annotations

import hashlib
import json
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
    "router-front-controller-routing", "api-gateway-reverse-proxy", "middleware-interceptor-chain", "caching-strategies", "background-worker-job-scheduler", "rate-limiter-throttler", "authn-authz-guard", "repository-unit-of-work", "dto-mapper-anti-corruption-layer", "validator-input-parser", "feature-flag-toggle-engine", "state-machine-workflow-engine", "ssot-and-dry", "open-closed-principle", "single-responsibility-cohesion", "dependency-inversion-composition-root", "kiss-yagni-aha", "value-objects-type-invariants", "error-handling-problem-details", "git-atomic-commits", "model-effort-routing", "oss-deep-audit", "deep-web-research", "playwright-qa-orchestrator", "clean-code-for-agents", "skill-orchestrator", "diagnosing-bugs",
    # Code Design, SSOT & Type-Safe Domain Modeling (3)
    "pragmatic-solid-and-ssot", "defensive-domain-modeling", "codebase-design",
    # AI Engineering Workflow — Matt Pocock Pack (8)
    "setup-matt-pocock-skills", "grill-me", "grilling", "to-spec", "to-tickets",
    "implement", "tdd", "code-review",
    "verification-loop",
    "a11y-audit",
    "ci-test-reliability",
    "cross-layer-value-trace",
    "threat-modeling",
    "vulnerability-triage",
    "sql-server-audit",
    "agent-session-memory",
    "memory-hygiene",
    "triage",
    "wayfinder",
    "retro",
    "handoff",
    "prototype",
    "domain-modeling",
    "git-guardrails-claude-code",
    "wizard",
    "setup-ts-deep-modules",
    "setup-pre-commit",
    "to-questionnaire",
    "wait-what",
    "receiving-code-review",
    "pr-description",
    "application-performance",
    "simplification-audit",
    "ops-safety",
    "incident-analyst-brief",
    "blameless-postmortem",
    "worst-case-data-ui-check",
    "multi-agent-coordination",
    "mcp-apps",
    "text-quality-gate",
    "agent-cost-report",
    "agent-config-migration",
    "zabbix-diagnostics",
    "transactional-email-engineering",
    "dependency-management-and-versioning",
    "software-supply-chain-security",
    "skill-creation-workflow",
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


PACK_DIR = pathlib.Path(__file__).resolve().parent


def skill_folders(root: pathlib.Path) -> tuple[list[pathlib.Path], list[str]]:
    """Skill folders one or two levels below root (a folder with SKILL.md is not searched further), and repeated names."""
    found: list[pathlib.Path] = []
    seen: set[str] = set()
    duplicates: list[str] = []

    def visit(folder: pathlib.Path, depth: int) -> None:
        for child in sorted(p for p in folder.iterdir() if p.is_dir()):
            if (child / "SKILL.md").is_file():
                if child.name in seen:
                    duplicates.append(child.name)
                else:
                    seen.add(child.name)
                    found.append(child)
            elif depth < 2:
                visit(child, depth + 1)

    if root.is_dir():
        visit(root, 1)
    return sorted(found, key=lambda p: p.name), duplicates


def marketplace_problems(root: pathlib.Path) -> list[str]:
    """Every category folder of the pack must be a plugin source in .claude-plugin/marketplace.json."""
    market = PACK_DIR / ".claude-plugin" / "marketplace.json"
    if root.resolve() != (PACK_DIR / "skills").resolve() or not market.is_file():
        return []
    listed = {s for plugin in json.loads(market.read_text(encoding="utf-8")).get("plugins", []) for s in plugin.get("skills", [])}
    categories = sorted(p.name for p in root.iterdir() if p.is_dir() and not (p / "SKILL.md").is_file())
    return [f"marketplace.json: category `{c}` is not listed as ./skills/{c}" for c in categories if f"./skills/{c}" not in listed]


def write_manifest() -> int:
    files = sorted((p for p in (PACK_DIR / "skills").rglob("*") if p.is_file()), key=lambda p: p.relative_to(PACK_DIR).as_posix().lower())
    lines = [f"{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.relative_to(PACK_DIR).as_posix()}" for p in files]
    (PACK_DIR / "MANIFEST.sha256").write_bytes(("\n".join(lines) + "\n").encode())
    print(f"MANIFEST.sha256: {len(lines)} file(s)")
    return 0


REDUNDANCY_SKIP_FILES = {"sources.md", "trigger-evals.md"}
REDUNDANCY_MIN_CHARS = 180
REDUNDANCY_REPORT = 0.55  # shingle overlap that is worth a reviewer's attention
REDUNDANCY_FAIL = 0.90  # near-verbatim copy: fails the check


def _paragraphs(text: str) -> list[str]:
    """Prose paragraphs only: no front matter, code, tables, headings, checklists, link lists or Sources/Last verified lines."""
    text = re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S)
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    keep = []
    for block in re.split(r"\n\s*\n", text):
        b = block.strip()
        if len(b) < REDUNDANCY_MIN_CHARS or b.count("\n") > 12:
            continue
        if b.startswith(("|", "#", "- [ ]", "Sources:", "Last verified", "Source:")):
            continue
        if all(re.match(r"\s*[-*] \[[^\]]*\]\([^)]*\)", line) for line in b.splitlines()):
            continue
        keep.append(b)
    return keep


def _shingles(text: str, size: int = 5) -> set[str]:
    words = re.findall(r"[a-z0-9]+", text.lower())
    return {" ".join(words[i:i + size]) for i in range(max(0, len(words) - size + 1))}


def redundancy(root: pathlib.Path) -> tuple[list[str], list[str]]:
    """Deterministic first pass of the redundancy review: (failures, findings for a reviewer).

    Finds a paragraph repeated across two skills, a reference file that restates its own SKILL.md, and two files of
    different skills that are mostly the same text. It cannot see the same rule in different words: that is the
    reviewer's job (skill-creation-workflow, references/redundancy-review.md).
    """
    skills, _ = skill_folders(root)
    items: list[tuple[str, str, set[str], str]] = []  # (skill, file, shingles, paragraph)
    for folder in skills:
        for md in sorted(folder.rglob("*.md")):
            if md.name in REDUNDANCY_SKIP_FILES:
                continue
            rel = md.relative_to(folder).as_posix()
            for paragraph in _paragraphs(md.read_text(encoding="utf-8")):
                sh = _shingles(paragraph)
                if len(sh) >= 20:
                    items.append((folder.name, rel, sh, paragraph))
    index: dict[str, set[int]] = {}
    for i, (_, _, sh, _) in enumerate(items):
        for s in sh:
            index.setdefault(s, set()).add(i)
    pairs: set[tuple[int, int]] = set()
    for ids in index.values():
        if 1 < len(ids) <= 8:
            ordered = sorted(ids)
            pairs.update((a, b) for k, a in enumerate(ordered) for b in ordered[k + 1:])
    failures: list[str] = []
    findings: list[str] = []
    for a, b in sorted(pairs):
        (sa, fa, sha, pa), (sb, fb, shb, _) = items[a], items[b]
        cross = sa != sb
        intra = sa == sb and fa != fb and "SKILL.md" in (fa, fb)
        if not (cross or intra):
            continue
        overlap = len(sha & shb) / min(len(sha), len(shb))
        if overlap < REDUNDANCY_REPORT:
            continue
        line = f"{sa}/{fa} <-> {sb}/{fb}: {overlap:.0%} of a paragraph repeated ({pa[:70].strip()!r}...)"
        (failures if overlap >= REDUNDANCY_FAIL else findings).append(line)
    return failures, findings


def check(root: pathlib.Path) -> list[str]:
    skills, duplicates = skill_folders(root)
    if not skills:
        return [f"{root}: no skill folders (a folder with a SKILL.md) found"]
    problems = [f"{name}: skill name used by more than one folder" for name in duplicates] + marketplace_problems(root)
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
                    problems.append(f"{folder.name}/{md.relative_to(folder).as_posix()}: link `{target}` does not resolve")
        for mention in sorted(set(BACKTICK.findall(text)) & set(PACK) - {folder.name}):
            if mention not in installed:
                problems.append(f"{where}: refers to `{mention}`, which is not installed here")
    return problems


def main(argv: list[str]) -> int:
    if argv == ["--write-manifest"]:
        return write_manifest()
    if argv and argv[0] == "--redundancy":
        root = pathlib.Path(argv[1] if len(argv) > 1 else PACK_DIR / "skills").expanduser()
        failures, findings = redundancy(root)
        for line in failures:
            print(f"  [FAIL] {line}")
        for line in findings:
            print(f"  [REVIEW] {line}")
        print(f"{'FAILED' if failures else 'OK'}: {len(failures)} near-verbatim copy(ies), {len(findings)} for the reviewer in {root}")
        return 1 if failures else 0
    if len(argv) != 1:
        print(__doc__)
        return 2
    root = pathlib.Path(argv[0]).expanduser()
    problems = check(root)
    for line in problems:
        print(f"  [FAIL] {line}")
    count = len(skill_folders(root)[0])
    print(f"{'OK' if not problems else 'FAILED'}: {count} skill(s) checked in {root}")
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
