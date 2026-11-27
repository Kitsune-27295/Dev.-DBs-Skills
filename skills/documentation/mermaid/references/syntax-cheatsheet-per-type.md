# Syntax Cheatsheet per Diagram Type

Sources: https://mermaid.js.org/syntax/flowchart.html · https://mermaid.js.org/syntax/sequenceDiagram.html · https://mermaid.js.org/syntax/classDiagram.html · https://mermaid.js.org/syntax/entityRelationshipDiagram.html · https://mermaid.js.org/syntax/stateDiagram.html · Last verified 2026-11-27

Moved here from `SKILL.md` section 4 on 2026-11-24 to keep the core file under its size budget; content unchanged.

**Flowchart**
- Direction: `TB`, `TD`, `BT`, `LR`, `RL`. Use `TD` for hierarchies and `LR` for chronological/data flows.
- Classic shapes: `[rect]`, `(rounded)`, `([stadium])`, `((circle))`, `{decision}`, `[(database)]`, `[[subroutine]]`, `{{hexagon}}`, `[/io/]`. Extended semantic shapes (v11.3+): `A@{ shape: cyl, label: "DB" }` (`rect`, `diam`, `stadium`, `doc`, `docs`, `st-rect` (alias `procs`), `hex`, `fork`, `cloud`, `lean-r`, `sm-circ`, `dbl-circ`).
- Edges: `-->`, `---`, `-.->`, `==>`, `--o`, `--x`, `<-->`; label with `A -->|text| B`; extra dashes span more ranks (`---->`). Edge IDs & animations (v12.3+): `A e1@--> B` + `e1@{ step: 1 }` or `e1@{ curve: linear }`.
- Subgraphs: `subgraph id ["Title"] ... end`. Warning: per-subgraph `direction LR` is **ignored** if any node inside links directly to a node outside the subgraph. Collapse noisy internals (v11.17+): `id@{ view: collapsed }`.
- Styling: `classDef role fill:#...,stroke:#...` + `class a,b role` or `a:::role`. The page says to escape commas in CSS values (`stroke-dasharray:5\,5`) yet its animation example does not: test. Note: external CSS fails because Mermaid injects inline `!important` styles — use `classDef`.

**Sequence**
- `participant A as Display Name` / `actor U as User` (no quotes around aliases; `@{ "type": "database" }` stereotypes supported); group with `box rgb(200,230,200) Backend ... end` (never `#hex` inside `box` because `#` starts an entity/comment parse).
- Dynamic actors (v10.3+): `create participant B` / `destroy B`.
- Arrows: `->>` sync, `-->>` reply, `-)` async, `-x` lost, `<<->>` bidirectional; `->>+B` / `-->>-A` activate/deactivate.
- Blocks: `loop`, `alt ... else ... end`, `opt`, `par ... and ... end`, `critical ... option ... end`, `break`, `rect rgba(...)`; `autonumber [<start> <inc>]`; `note over A,B: text` (use `#59;` for semicolons in message text).

**Class**
- Visibility `+ - # ~`; classifiers `*` (abstract), `$` (static) at method/field end; stereotypes `<<interface>>`, `<<abstract>>`, `<<enumeration>>`; generics `List~String~` (commas inside generics like `Map~K, V~` are unsupported); `namespace A.B { class X }`.
- Relations: `<|--` inheritance, `*--` composition, `o--` aggregation, `-->` association, `..>` dependency, `..|>` realization, `--()` / `()--` lollipop interface; multiplicity in quotes `"1" --> "many"`.
- Hide empty compartment: `config: class: hideEmptyMembersBox: true`.

**ER**
- `ENTITY { type name PK "comment" }`; keys `PK`, `FK`, `UK` (comma-separated: `PK, FK`); nullable types `string? middleName` (v11.16+); entity display alias `p[Person]`.
- Cardinalities: `||--o{` (`1..0+`), `}|--|{` (`1+..1+`), `|o--o|` (`0..1`), `--` identifying (solid) vs. `..` non-identifying (dashed). Copy markers character-for-character; optionally use aliases (`one or more`, `zero or many`).
- Subgraphs (v11.17+): `subgraph "Customer Domain" ... end` groups entities; quote IDs with spaces in relationships.

**State**
- Prefer `stateDiagram-v2`; composite `state X { ... }` (note: transitions **cannot** cross between internal states of *different* composite states); `<<choice>>`, `<<fork>>`/`<<join>>`, concurrency separator `--`, `[*]` start/end.
- `classDef` cannot style `[*]` or composite container boundaries.

**C4** (`C4Context`, `C4Container`, `C4Component`, `C4Dynamic`, `C4Deployment`)
- Compatible with C4-PlantUML subset: `Person`, `Person_Ext`, `System`, `SystemDb`, `SystemQueue`, `System_Ext`, `Container`, `ContainerDb`, `ContainerQueue`, `Component`, `Deployment_Node` / `Node`; boundaries `Enterprise_Boundary`, `System_Boundary`, `Container_Boundary`, `Boundary`.
- Relationships: `Rel(from, to, "label", "techn")`, `BiRel`, `Rel_Back`, `Rel_U/D/L/R`; order of statements controls placement (`Lay_U/D/L/R`, `sprite`, `AddElementTag`, `Legend` are **not supported** in Mermaid). Tune grid via `UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")`.

**Architecture** (`architecture-beta`, beta)
- Blocks: `group id(icon)[Title] (in parent)?`, `service id(icon)[Title] (in parent)?`, `junction id (in parent)?`. Built-in icons: `cloud`, `database`, `disk`, `internet`, `server` (plus Iconify packs `prefix:name`).
- Ported edges: `db:R --> L:server` (`T|B|L|R`), group boundary modifier `server{group}:B --> T:subnet{group}`.
- Sibling alignment (`align`, v11.16.0+) and layout tuning (v11.15.0+): `align row a b c` / `align column a b c` prevents sibling collapse; tune determinism via `config: architecture: { seed: 1, nodeSeparation: 75, idealEdgeLengthMultiplier: 1.5 }`.

For any type not detailed above, check the official Mermaid syntax reference before writing rather than guessing keywords.

## How an agent should apply this

- Read the block for the chosen type before writing syntax; keep the first line as the exact type keyword.
- Quote labels and avoid reserved words as ids (see `SKILL.md` section 2).
- Validate with a real parser when available (`SKILL.md` section 7).
