# arc42's 12 Sections and "Just Enough" Architecture Documentation

Sources: https://arc42.org/overview/ · https://docs.arc42.org/home/ · https://docs.arc42.org/section-1/ · https://docs.arc42.org/section-3/ · https://docs.arc42.org/section-10/ · https://vickybytes.com/blog/software-architecture-documentation-guide · Last verified 2026-11-27

The vickybytes page is a Next.js site; the fetch tool returned no body, so its text was read from the page's HTML source with a script.

## arc42 as the page describes it

arc42 (Hruschka and Starke, "proven in practice since 2005") answers what to document and how. The overview page states CC BY-SA 4.0 and offers a one-page **Canvas** as the lighter option; docs.arc42.org (open source, same licence) holds one page per section plus tips and examples and does not mention the Canvas.

| Group | Sections |
|---|---|
| Requirements and quality | 1 Introduction and Goals (fundamental requirements, quality goals); 2 Constraints; 3 Context and Scope (external systems, interfaces); 4 Solution Strategy |
| Structures and views | 5 Building Block View (code structure, hierarchical refinement, usually the largest); 6 Runtime View (important scenarios); 7 Deployment View |
| Concepts and decisions | 8 Crosscutting Concepts (grows as concepts are decided); 9 Architectural Decisions; 10 Quality Requirements (quality tree, scenarios); 11 Risks and Technical Debt; 12 Glossary (the ubiquitous language) |

## What the section pages add (read 2026-11-27)

- **Section 1:** the top three, at most five, quality goals; ISO/IEC 25010:2023 is named as one example overview of quality topics, not a requirement. Subsections: requirements overview, quality goals, stakeholders.
- **Section 3:** delimits the system from its communication partners; a business context (partners and the data exchanged) and a technical context (channels and media); the interfaces are called among the most critical aspects. The page does not mention C4.
- **Section 10:** a quality tree plus scenarios that make requirements measurable. A short form (context, source and stimulus, metric) and a long form (stimulus and response, with source, environment, artifact and response measure) are described; if the requirements are already precise the scenario part can be skipped.

## Combining arc42, C4 and ADRs (vickybytes)

- **Roles:** arc42 is the document skeleton, C4 the diagram levels, ADRs the decision log. Which C4 level sits in which section is this pack's convention (see the map in SKILL.md), not something arc42 states. Diagram notation lives in `c4-model-architecture`; decision records live in `adr-architecture`.
- **Just enough:** document what matters and skip what the code already shows.
- **Freshness rules:** keep docs in version control and review them in pull requests; update them in the same change (definition of done); name owners; generate diagrams where possible; review key records each quarter; show last-verified dates.
- **Common mistakes:** too much detail, no clear audience, missing rationale, diagrams without explanation, writing once and never updating.

Caveat: the vickybytes guide is a general overview, not normative; the arc42 section list comes from arc42.org and docs.arc42.org.

## Forces and trade-offs

| Choice | Pro | Con |
|---|---|---|
| Fill all 12 sections | Complete | Filler, drift, nobody reads it |
| Canvas only | Fast, one page | Loses runtime/deployment detail for larger systems |
| Wiki outside the repo | Easy for non-engineers | Drifts from code; skipped in PRs |
| Docs in repo with PR review | Versioned with code | Needs discipline and link checks |

## How an agent should apply this

- Start with sections 1, 3, 5 (level 1) and 9; add 6/7/8/10/11 only when a reader needs them.
- Write the glossary (12) early so every other section uses its terms.
- Put API schemas in spec files and link them from sections 3 and 5 instead of copying fields into prose.
- Add or update the relevant section in the same PR as a structural change, and stamp a verified date.
- For small systems propose the Canvas first and say which sections would be added on growth.
