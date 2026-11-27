# Sources — Mermaid Diagram Engineering

Every URL below was re-fetched and checked during the 2026-11-27 rebuild. Last verified 2026-11-27. The Mermaid docs read were version 12.4.0 (the page links a v13 alpha guide).

| Source | Retrieved status | What it contributed |
|---|---|---|
| https://mermaid.js.org/intro/syntax-reference.html | 200 (summarizing fetch tool) | Frontmatter must start on line 1, `%%` comments, silent failure of misspelled parameters, directives |
| https://mermaid.js.org/config/schema-docs/config.html | 200 (first 100,000 of 438,467 characters read) | `maxTextSize` 50000, `maxEdges` 500, theme list, default theme `default`, look `classic`, layout `elk` |
| https://mermaid.js.org/config/theming.html | 200 | Eleven themes, only `base` customizable, hex colors only, v12.0.0 default shift |
| https://mermaid.js.org/config/layouts.html | 200 | ELK bundled and default from v12.0.0, tiny build falls back to Dagre, mindmap layout; ELK tuning options NOT found |
| https://mermaid.js.org/syntax/flowchart.html | 200 | `end` and `o`/`x` pitfalls, `@{ shape }` v11.3.0+, collapsible subgraphs v11.17.0+, per-edge curve v11.10.0+, step animation v12.3.0+, `defaultRenderer` removed |
| https://mermaid.js.org/syntax/sequenceDiagram.html | 200 | Stereotypes, create/destroy v10.3.0+, box colors, arrows (bidirectional v11.0.0+, half-arrows v11.12.3+), autonumber args v11.15.0+, escaping, config defaults |
| https://mermaid.js.org/syntax/entityRelationshipDiagram.html | 200 | Cardinality markers and aliases, `PK`/`FK`/`UK`, nullable `?` v11.16.0+, subgraphs v11.17.0+ |
| https://mermaid.js.org/syntax/stateDiagram.html | 200 | Composite-state rule, choice/fork/join, concurrency, classDef contradictions |
| https://mermaid.js.org/syntax/classDiagram.html | 200 | Visibility, classifiers, generics without commas, eight relations, namespaces v11.15.0+, `hideEmptyMembersBox` |
| https://mermaid.js.org/syntax/c4.html | 200 | Five types, macro list, unsupported features, `c4.wrap` since v11.17.1 |
| https://mermaid.js.org/syntax/architecture.html | 200 | Beta warning, ports, `{group}`, `align` v11.16.0+, `randomize` v11.14.0+, layout tuning v11.15.0+, `seed` |
| https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams | 200 | Rendering surfaces, `info` version check, geoJSON/topoJSON/STL fences, third-party plugin caveat |
| https://docs.github.com/en/copilot/tutorials/copilot-cookbook/communicate-effectively/creating-diagrams | 200 | Fence format, non-determinism, the example's date inconsistencies |
| https://github.com/mermaid-js/mermaid-cli | 200 | `mmdc` usage, markdown transform, stdin, `npx` form, Docker/Podman notes, MIT, Homebrew unsupported |

Method and semantic-preservation checklist originally adapted from the official Mermaid Chart VS Code extension (MIT); account-bound features omitted. The gate and type-per-need table were adapted, method only and rewritten, from an internal documentation workflow of an internal project; no text, names or product examples were reused.

## Reading limits

- Pages were read through a summarizing fetch tool, not raw HTML; the config schema page was read only in its first 100,000 characters.
- Facts here track Mermaid 12.4.0; GitHub, Obsidian and other hosts may bundle older versions, hence the `info` check.
- This skill has no scripts or data files; none were edited or run.

## Claims not adopted

- ELK options `mergeEdges`, `nodePlacementStrategy` values and default, `nodePlacementAlignment`, `elk.preset`: not found on the layouts page; removed.
- A default-gradient detail for the `base` theme: not re-verified; removed.
- `architecture-beta` introduced in v11.1.0: the page gives no such version; removed.
- Exit-code behavior of `mmdc`, the GHCR image name, `--cssFile` and `--size` effects, Docker `-u` flag, Linux sandbox guides: not in the README read; removed or softened.
- Font-weight defaults in the sequence config table: the page's table looked wrong; not used.
- The 25 to 30 node threshold and 15+ node ELK advice: this pack's judgement, not documented by Mermaid.
