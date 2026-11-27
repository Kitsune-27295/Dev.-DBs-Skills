# ADR Teamwork, Governance, Templates and Enforcement

Sources: https://github.com/architecture-decision-record/architecture-decision-record · https://adr.github.io/madr/ · https://adr.github.io/adr-templates/ · Last verified 2026-11-27

## Conventions

- Storage: any tool works; the Git option is one file per record in a directory.
- Naming, Henderson: present-tense imperative verb phrase, lowercase, dashes, `.md` (`choose-database.md`), matching his commit message style. MADR: `NNNN-title-with-dashes.md`, consecutive number (room for 9,999), under `docs/decisions/`, optional category subfolders with numbers unique per category. Nygard: `adr-NNN.md`. Pick one per repository.
- Henderson's mutability guidance conflicts internally: the good-ADR advice says do not alter existing information (amend or supersede), while the teamwork advice says teams found dated additions to the existing record worked better. Both agree on never rewriting the decision.

## When to write one (Henderson)

Write when future developers need the why, or the decision affects coordination, maintainability or external interfaces. Skip non-architectural, tiny, low-risk, single-developer, already-documented decisions and temporary workarounds or experiments. Anyone who has read the repository guidance may propose one.

## Governance questions to settle upfront (examples from the page)

| Question | Example answer |
|---|---|
| Lifecycle | Initiating, Researching, Evaluating, Implementing, Maintaining, Sunsetting (the page calls it five stages but lists six) |
| Acceptance | Problem clear, alternatives and trade-offs documented, stakeholders involved, comments addressed; then a published proposal with a one-week comment period and a vote |
| Roles | Proposer, researcher, evaluator, reviewer, approver, maintainer; each record names a primary and secondary contact and an accountable team |
| Review | About one month after the decision against reality; the example governance answer adds at least yearly and on relevant change |
| Authority | The page's example order is executives, then the implementing team, then experts; define your own approval, veto and escalation path |

Frame ADRs around the why rather than mandating them; some teams say "decisions" to widen use.

## Template families (Henderson list)

Nygard (simple, popular), Tyree and Akerman (more sophisticated), EdgeX, arc42, Alexandrian pattern, business case (costs, SWOT), MADR, Planguage, Y-statements, Important Technical Decisions (lean, decision-first), and several organization-specific ones. ISO/IEC/IEEE 42010:2011 Annex A suggests nine information items for ADRs (adr.github.io).

**MADR** (adr.github.io, latest listed 4.0.0 of 2024-09-17, MIT or CC0-1.0): optional front matter (status, date, decision-makers, consulted, informed); required Context and Problem Statement, Considered Options and Decision Outcome (with optional Consequences and Confirmation); optional Decision Drivers, Pros and Cons of the Options, More Information. Status values in the template comment: proposed, rejected, accepted, deprecated, superseded by a link.

**Y-statement** (adr.github.io): the short form is one sentence naming use case, concern, chosen option, quality sought and accepted downside; the long form adds neglected options and a "because" rationale. The skill writes the sentence in its own words and does not claim a verbatim template; the originating article was unreachable.

Choosing (own inference): Nygard or Y-statement for small teams; MADR when rejected options keep getting lost; heavier templates only when governance demands them.

## Enforcement ideas

- Fitness functions: automated CI checks that verify a decision holds (for example, every state change emits an event).
- Architecture unit tests: ArchUnit on the JVM, ArchUnitTS for TypeScript (Henderson page mentions them), or an own import-graph scan.
- Pull-request guardrails: tools that surface relevant decisions in review or flag edits to watched code without an ADR (the page lists some third-party tools; not evaluated here).

```ts
// illustrative ArchUnitTS-style check, own sketch
expect(projectFiles().inFolder("domain").shouldNot().dependOnFiles().inFolder("infrastructure"))
```

## How an agent should apply this

- Check the "write" criteria before drafting; say so when a decision does not meet them.
- Propose the governance answers (proposer, approver, review date) in the record header.
- Turn a mechanically checkable decision into a test and cite the ADR in it.
- Date perishable assumptions and schedule a review.
- Suggest MADR sections when alternatives were debated; otherwise keep Nygard-sized.
