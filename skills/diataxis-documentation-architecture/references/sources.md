# Sources for the diataxis-documentation-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Daniele Procida, "Diátaxis — A systematic approach to technical documentation authoring", https://diataxis.fr/ | Core framework definition: technical documentation must be organized around four distinct user needs and corresponding forms (**Tutorials**, **How-to Guides**, **Technical Reference**, **Explanation**) addressing content (what to write), style (how to write it), and information architecture (how to organize it). |
| 2 | Daniele Procida, "Start here — Diátaxis in five minutes", https://diataxis.fr/start-here/ | Detailed characterization of the four quadrants: **Tutorials** (practical lesson, study/acquisition of skill, instructor responsible for learner safety & success, driving-lesson analogy), **How-to Guides** (practical steps to solve a real-world goal/problem at work, recipe analogy), **Reference** (theoretical/factual description of the machinery for use at work — austere, accurate, complete, free of distraction), and **Explanation** (theoretical illumination of a topic for study/understanding — answers "why", discusses trade-offs and connections); the **Diátaxis Map** (Action vs. Cognition $\times$ Acquisition/Study vs. Application/Work); the **Diátaxis Compass**; and the organic inside-out **Workflow** (improve one piece at a time using the compass rather than building empty scaffolding upfront). |

## Notes on disagreements and nuances across sources

- **Top-down folder scaffolding vs. Inside-out incremental refactoring:** Procida (Source 2) explicitly warns against starting a Diátaxis adoption by creating four empty top-level directories (`tutorials/`, `how-to/`, `reference/`, `explanation/`) before auditing actual content, recommending instead that authors use the Diátaxis Compass on existing pages to separate mixed concerns organically until the four top-level groupings emerge naturally.
