# arc42's 12 Sections and "Just Enough" Architecture Documentation

Sources: https://arc42.org/overview/ · https://vickybytes.com/blog/software-architecture-documentation-guide · Last verified 2026-11-23

The vickybytes page is a Next.js site; its body was recovered from the page's embedded JSON data, not a rendered view.

## arc42 as the page describes it

arc42 (Hruschka and Starke, in use since 2005) answers what to document and how. It is free and open source, including commercially (CC BY-SA 4.0), and every section is tailorable. Companion resources: docs.arc42.org (one page per section, `/section-1/` to `/section-12/`), examples, FAQ, a quality model, and a one-page **Canvas** as the lighter alternative.

| Group | Sections |
|---|---|
| Requirements and quality | 1 Introduction and Goals (fundamental requirements, quality goals); 2 Constraints; 3 Context and Scope (external systems, interfaces); 4 Solution Strategy |
| Structures and views | 5 Building Block View (code structure, hierarchical refinement, usually the largest); 6 Runtime View (important scenarios); 7 Deployment View |
| Concepts and decisions | 8 Crosscutting Concepts (grows as concepts are decided); 9 Architectural Decisions; 10 Quality Requirements (quality tree, scenarios); 11 Risks and Technical Debt; 12 Glossary (the ubiquitous language) |

## Combining arc42, C4 and ADRs (vickybytes)

- **Roles:** arc42 supplies the document skeleton; C4 (Simon Brown: context, containers, components, code; most teams draw the first three) supplies diagram levels; ADRs (Nygard format: title, status, context, decision, consequences) supply the decision log. Mapping C4 levels to sections 3, 5, 6, 7 and ADRs to section 9 is the arc42 skill's own synthesis, consistent with the guide.
- **Just enough:** document what readers need and skip what the code already shows; start with a context diagram and a few ADRs.
- **ADR hygiene:** keep them in the repo; never delete, mark superseded and link the successor.
- **Audience table:** context diagram for everyone; container for dev/ops; component for developers; decision record for architects; deployment for ops/security; quality requirements for product owners; runbook for on-call.
- **Freshness rules:** update docs in the same change (definition of done), assign owners, generate diagrams where possible, review quarterly, show last-verified dates.
- **Common mistakes:** too much detail, no clear audience, missing rationale, diagrams without titles/legends, writing once and never again, hiding the docs.
- **Diagram habits:** title and legend, labeled arrows (purpose or protocol), one level of detail per diagram, alt text.

Caveat: the vickybytes guide is a general overview, not normative; the arc42 section list comes from arc42.org.

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
