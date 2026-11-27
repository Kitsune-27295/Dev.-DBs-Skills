# Sources — Mermaid Diagram Engineering

All 11 references below were retrieved and verified on 2026-11-22.

| Source | Retrieved status | What it contributed to `SKILL.md` |
|---|---|---|
| [Mermaid — Syntax Reference (Intro & Layouts)](https://mermaid.js.org/intro/syntax-reference.html) | 200 OK | Frontmatter config, comments (`%%`), HTML entity escaping, ELK vs. Dagre defaults. |
| [Mermaid — Flowcharts Syntax](https://mermaid.js.org/syntax/flowchart.html) | 200 OK | Node/semantic `@{ shape: ... }` syntax (v11.3+), `end` & `o`/`x` edge pitfalls, collapsible subgraphs (v11.17+), step animations (v12.3+), `classDef` comma escaping, `redux-color`/`neo`/ELK defaults (v12.0+). |
| [Mermaid — Sequence Diagrams](https://mermaid.js.org/syntax/sequenceDiagram.html) | 200 OK | Participants/actors/stereotypes, `create`/`destroy`, `box` color restriction (no hex `#`), arrows & half-arrows, activations, `autonumber`, `loop`/`alt`/`opt`/`par`/`critical`/`break`, `#59;` escaping. |
| [Mermaid — Entity Relationship Diagrams](https://mermaid.js.org/syntax/entityRelationshipDiagram.html) | 200 OK | Crow's foot cardinalities & aliases, identifying (`--`) vs. non-identifying (`..`), `PK`/`FK`/`UK`, nullable `?` types (v11.16+), ER subgraphs (v11.17+), ELK/Dagre frontmatter. |
| [Mermaid — State Diagrams](https://mermaid.js.org/syntax/stateDiagram.html) | 200 OK | `stateDiagram-v2`, composite states (and no cross-composite internal transitions rule), `<<choice>>`, `<<fork>>`/`<<join>>`, `--` concurrency, `classDef` limitations. |
| [Mermaid — Class Diagrams](https://mermaid.js.org/syntax/classDiagram.html) | 200 OK | Visibility/classifiers (`*`, `$`), tilde generics `List~T~` (no comma support), 8 UML relations, lollipop interfaces, namespaces & `hierarchicalNamespaces`, `hideEmptyMembersBox`. |
| [Mermaid — C4 Diagrams](https://mermaid.js.org/syntax/c4.html) | 200 OK | All 5 C4 diagram types (`C4Context`, `C4Container`, `C4Component`, `C4Dynamic`, `C4Deployment`), `Rel*` / `Boundary*` / `UpdateLayoutConfig`, and explicit unsupported C4-PlantUML features (`Lay_*`, `sprite`, `tags`, `Legend`). |
| [Mermaid — Architecture Diagrams (`architecture-beta`)](https://mermaid.js.org/syntax/architecture.html) | 200 OK | `group`, `service`, `junction`, directional ports (`:L`/`R`/`T`/`B`), `{group}` modifier, built-in & Iconify icons, `align row`/`column` (v11.16+), and deterministic `seed`/spacing config. |
| [GitHub Docs — Creating diagrams in Markdown](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams) | 200 OK | Native ```` ```mermaid ```` rendering across Issues/PRs/Discussions/Wikis, ```` ```mermaid\ninfo\n``` ```` version check, and warning against conflicting third-party browser Mermaid plugins. |
| [GitHub Docs — Copilot Cookbook: Creating diagrams](https://docs.github.com/en/copilot/tutorials/copilot-cookbook/communicate-effectively/creating-diagrams) | 200 OK | Grounded Markdown fence formatting and AI-assisted diagram generation workflow. |
| [mermaid-js/mermaid-cli (`mmdc`)](https://github.com/mermaid-js/mermaid-cli) | 200 OK | CLI validation & export flags (`-i`, `-o`, `-t dark -b transparent`, stdin `-`, markdown transformation, `--iconPacks`). |

Method and semantic-preservation checklist originally adapted from the official Mermaid Chart VS Code extension (MIT); account-bound features omitted.

## Added 2026-11-24

- The gate (order, exchange, lifecycle, relations, decision; more than about eight lines of prose; a diagram is never the only carrier of a fact) and the type-per-need table were adapted, method only and rewritten, from an internal documentation workflow of an internal project (added 2026-11-24). No text, names or product examples were reused.
- Section 4 of `SKILL.md` (syntax cheatsheet) was moved unchanged to `references/syntax-cheatsheet-per-type.md` to keep `SKILL.md` within its size budget (added 2026-11-24).
