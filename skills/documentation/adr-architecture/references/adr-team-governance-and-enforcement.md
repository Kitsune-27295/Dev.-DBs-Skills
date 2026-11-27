# ADR Teamwork, Governance, Templates and Enforcement

Sources: https://github.com/architecture-decision-record/architecture-decision-record · https://adr.github.io/ · Last verified 2026-11-23

## Conventions

- Storage: any tool works (doc, wiki, tracker); the git option is one file per ADR in an `adr/` directory.
- Naming: present-tense imperative verb phrase, lowercase, dashes, `.md` (`choose-database.md`); matches commit style. (Nygard used numbers; the repo advice favors verb phrases. Pick one and be consistent.)
- Good ADR: gives rationale, alternatives, trade-offs and cost/benefit; one decision per record; timestamps on perishable facts (costs, scale assumptions).
- Mutability: the page says records are largely immutable (amend with dated additions or supersede), but notes that many teams keep ADRs as living documents with dated notes.
- Consequences section should cover outcomes, follow-up ADRs and an after-action review (suggested about a month later).

## When to write one

Raise an ADR when future developers need the "why", or the decision affects coordination, maintainability or external interfaces. Skip for non-architectural, tiny, single-developer, already documented, or temporary decisions (workarounds, experiments).

## Governance questions to settle upfront

| Question | Example answer from the page |
|---|---|
| Who can propose | Anyone who read the guidance; some roles commission others |
| Lifecycle | Initiating, Researching, Evaluating, Implementing, Maintaining, Sunsetting |
| Acceptance | Problem clear, alternatives and trade-offs documented, stakeholders involved, feedback addressed, then timeboxed comment period (example: a week) and vote |
| Roles | Proposer, researcher, evaluator, reviewer, approver, maintainer; each ADR names primary/secondary contact and accountable team; review at least yearly |
| Authority | Decide who approves, votes or vetoes; define consensus, conflict, escalation |
| Principles (example) | Fast for reversible decisions, disagree and commit, public discussion unless confidential |

Focus conversation on the why; ADRs lose value when they become forced paperwork. Some teams say "decisions" instead of "ADRs" to widen use (vendor, planning).

## Template families

Nygard (minimal, common start), Tyree-Akerman (heavier, for large decisions), Alexandrian pattern, business case (costs, SWOT), MADR (simple and elaborate; elaborate stresses options with pros/cons), Planguage (quality-oriented), Important Technical Decisions (lean, decision-first), Y-statements, arc42, others. Y-statement shape: in the context of X, facing Y, we decided Z and neglected W, to achieve A, accepting B.

Choose: Nygard or Y-statement for small teams; MADR when rejected options keep getting lost; Tyree-Akerman only when governance demands it (inference).

## Enforcement ideas

- Fitness functions: automated CI checks that verify a decision holds (e.g., every state change emits an event).
- Architecture unit tests: ArchUnit (Java), ArchUnitTS (TypeScript).
- PR guardrails: tools that surface relevant decisions in review or flag edits to watched code lacking an ADR.
- Pair with C4 views for the visual side.

```ts
// ArchUnitTS-style fitness check (illustrative)
expect(projectFiles().inFolder("domain").shouldNot().dependOnFiles().inFolder("infrastructure"))
```

## How an agent should apply this

- Ask whether the decision meets the "raise" criteria before drafting; say so when it does not.
- Propose the governance answers (proposer, approver, review date) in the ADR header.
- Convert a decision that can be checked mechanically into a fitness test and cite the ADR in it.
- Date perishable assumptions and schedule a review.
- Suggest MADR options when alternatives were debated; otherwise keep Nygard-sized.
