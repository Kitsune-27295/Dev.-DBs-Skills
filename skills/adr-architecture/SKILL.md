---
name: adr-architecture
description: Use when authoring, reviewing, superseding, or governing Architecture Decision Records (ADRs) — capturing Architecturally Significant Requirements (ASRs) using Michael Nygard's template, MADR, or Y-statements, maintaining an immutable decision log in Git, and avoiding blind acceptance or blind reversal of past decisions.
---

# Architecture Decision Records (ADRs)

One idea: prevent **blind acceptance** ("we are afraid to touch this legacy choice because nobody knows why it's there") and **blind reversal** ("we replaced this pattern and accidentally broke an untested non-functional constraint") by capturing every **Architecturally Significant Decision** as a short, version-controlled, append-only Markdown record (`docs/adr/NNNN-verb-phrase.md`) in the repository. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Michael Nygard, Zdun & GitHub ADR Organization)

| Term | Meaning | Test sentence |
|---|---|---|
| Architecturally Significant Requirement (ASR) | a functional or non-functional requirement that has a measurable, high-cost-to-reverse effect on system structure, dependencies, interfaces, or quality attributes | "if reversing this choice later takes more than a day, it's architecturally significant" |
| Architecture Decision (AD) | a justified design choice made among 2+ viable alternatives to satisfy an ASR | "names the chosen option AND the rejected alternatives with their trade-offs" |
| Architecture Decision Record (ADR) | a short (1-2 page) text file recording a single AD, its context/forces, the decision, its lifecycle status, and its positive/negative consequences | "one decision per file, stored in Git next to the code" |
| Decision Log | the chronological, immutable collection of all ADRs in a project (`docs/adr/`) | "reads like the intellectual history of why the architecture is shaped this way" |
| Superseding (Never Deleting) | when context changes and a past decision is reversed, the old ADR is marked `Superseded by ADR-NNNN` and a new ADR is added | "never delete or rewrite history in an accepted ADR" |
| Y-Statement | Zdun's ultra-compact 1-sentence ADR summary: *"In the context of `<use case>`, facing `<concern>`, we decided for `<option>` and neglected `<other options>`, to achieve `<quality>`, accepting `<downside>`."* | "forces explicit trade-off honesty in one sentence" |

## Core rules and invariants

1. **Record only Architecturally Significant Decisions:** Do not write ADRs for trivial coding style rules (enforced by linters) or localized implementation details easily refactored in an hour. Write an ADR whenever a choice affects:
   - Module/service boundaries, dependency rules, or data ownership,
   - Database engines, message brokers, frameworks, or third-party vendor lock-in,
   - Public API contracts, authentication/security models, or cross-cutting non-functional trade-offs (latency vs. consistency vs. cost).
2. **Every ADR must list the Forces (Context) and the Rejected Alternatives:** An ADR that only states *"We chose PostgreSQL because it is good"* is useless. You must record the **competing forces** (team skill, budget, latency SLA, transaction volume) and **at least two considered options** with the honest reason the alternatives were rejected.
3. **Be honest about Negative Consequences:** Every architectural decision is a trade-off. If the `Consequences` section lists only benefits and zero downsides, risks, or follow-up costs, the ADR is promotional fluff rather than engineering analysis.
4. **ADRs are immutable once Accepted (Supersede, never overwrite):**
   - Lifecycle states: `Proposed` $\to$ `Accepted` (or `Rejected`) $\to$ `Deprecated` / `Superseded by ADR-0042 (0042-new-choice.md)`.
   - You may fix typos or append a late `Compliance / Verification` note, but to change the decision itself, write a **new** ADR that explains *what changed in the context* and links backward/forward to the old ADR.
5. **Co-locate ADRs in Git and review them in Pull Requests:** Store ADRs in `docs/adr/` (or `doc/architecture/decisions/`) using sequential 4-digit numbering and present-tense imperative verb slugs (`0001-record-architecture-decisions.md`, `0002-use-postgresql-for-transactional-outbox.md`). Review the ADR in the same PR as the architectural change (or immediately before building it).

## Canonical Nygard + MADR Hybrid Template

```markdown
# ADR-NNNN: [Short imperative verb phrase, e.g., Use Transactional Outbox for Order Events]

- **Status:** Proposed | Accepted | Superseded by ADR-MMMM (MMMM-slug.md)
- **Date:** YYYY-MM-DD
- **Deciders:** [Names / Roles]

## Context and Problem Statement
[1-3 paragraphs describing the technical/business forces at play, constraints, and the specific problem or ASR. State facts neutrally.]

## Considered Options
1. **[Option A — Chosen]** — brief summary, pros, cons.
2. **[Option B — Rejected]** — why it was viable and the specific reason it lost.
3. **[Option C — Do Nothing / Status Quo]** — what breaks if we make no change.

## Decision
We will **[explicit action]**, because **[core rationale tied to the forces above]**.

> *Y-Statement:* In the context of [context], facing [concern], we decided for [option] and neglected [alternatives], to achieve [system qualities], accepting [downside/cost].

## Consequences
- **Positive:** [What becomes easier, faster, or safer]
- **Negative / Trade-offs:** [What becomes harder, slower, or requires extra maintenance]
- **Compliance / Verification:** [How we enforce or test this decision automatically — e.g., ArchUnit test, CI check, linter rule]
```

## Verification and maintenance checklist

| Check | Question to verify |
|---|---|
| Scope | Does this file cover **exactly one** decision? (If it decides DB + Auth + UI framework, split it into 3 ADRs.) |
| Alternatives | Could a skeptical engineer see why Option B was rejected without asking in Slack? |
| Trade-offs | Are the negative consequences and operational costs explicitly acknowledged? |
| Automated enforcement | Does `Compliance / Verification` name an automated test or boundary check so the decision doesn't decay into shelfware? |
| Bidirectional links | If this ADR supersedes an older one, is the older ADR's `Status` updated to link forward to this one? |

## Mistakes to catch

- **Writing a 30-page "Software Architecture Document" instead of modular ADRs:** As Nygard notes, large monolithic specification documents are never read and never kept up to date. Keep each ADR to 1-2 pages of high-signal Markdown.
- **Retroactive justification ("Resume-Driven ADR"):** Picking a complex technology first (e.g., Kubernetes + Kafka for a 10-user internal tool) and writing fake straw-man alternatives to justify it.
- **Modifying an Accepted ADR in place when reversing a decision:** Deleting the old rationale erases why the team tried the first approach — causing a future team to repeat the exact same mistake 18 months later.
- **Orphan Decisions with zero verification:** Writing an ADR saying *"Domain layer must never import Infrastructure"* without adding an architecture import test (`clean-architecture`, `hexagonal-architecture`) to enforce it in CI.
