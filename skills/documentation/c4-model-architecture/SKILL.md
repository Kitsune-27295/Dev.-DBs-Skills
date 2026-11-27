---
name: c4-model-architecture
description: Draw, review or fix software architecture diagrams with Simon Brown's C4 model: pick the zoom level (system context, container, component, code), decide what counts as a container, apply the notation rules (title, element type and technology, labeled one-way relationships, legend) and catch mixed-level "boxes and lines" diagrams. Not for Mermaid or PlantUML syntax (see `mermaid`), arc42 chapter structure (see `arc42-api-contracts-architecture`) or recording decisions (see `adr-architecture`). Use when asked for a C4, context, container or component diagram, to review or clean up an architecture diagram, or to decide which levels a system needs.
---

# C4 Model (Hierarchical Architecture Diagramming)

One idea: draw architecture like a map with zoom levels. Four abstractions (person and software system, container, component, code) map to four diagram levels, and each diagram stays at one level and zooms into one element of the level above. Sources, statuses and claims not adopted: [references/sources.md](references/sources.md).

## 1. Abstractions

| Abstraction | Meaning | Test |
|---|---|---|
| Person | a human user of the system (customer, administrator) | "who uses it?" |
| Software system | the top-level unit that delivers value to users, often owned by one team; external systems are drawn as boxes too | "what would a stakeholder name?" |
| Container | an application or data store that must be running for the system to work; a runtime boundary, unrelated to Docker | "does it run or hold data on its own?" |
| Component | a building block inside one container (an authentication module, a card validator) | "does it organize code within one container?" |
| Code | implementation detail, shown only as the fourth diagram level (usually UML classes, ideally generated) | "would the IDE draw it?" |

## 2. Diagram levels

| Diagram | Zooms into | Shows | Audience |
|---|---|---|---|
| 1 System context | the system in scope | persons and systems around it | technical and non-technical |
| 2 Container | the one system | its containers, plus the persons and systems around | architects, developers, product |
| 3 Component | one container | its components, plus neighbors | architects, developers |
| 4 Code | one component | classes or similar | developers; rarely worth drawing |

Supporting diagrams: system landscape (several systems), dynamic (one runtime scenario), deployment (how containers map to environments). The source gives guidance only for the four static levels: draw only the levels that add value; context plus container are enough for most teams. Level 3 and 4 are for structure that is not obvious, and Level 4 is best generated, not hand-kept.

What counts as a container, with rulings: [references/c4-abstractions-and-levels.md](references/c4-abstractions-and-levels.md).

## 3. Notation rules (from the notation page)

1. **Title with type and scope** on every diagram ("Container diagram for Orders System").
2. **Every element** shows its type (Person, Software System, Container, Component), a short responsibility description, and for containers and components the technology.
3. **Every relationship** is labeled with its purpose, not a bare "Uses", and shows one direction (who calls or depends on whom). Container-to-container lines also name the protocol or technology.
4. **A key on every diagram** explaining shapes, colors, border styles, line types and arrowheads; spell out acronyms not all readers know.
5. **Never mix levels:** no container on a context diagram, no components of every service on one container diagram. One component diagram per container.
6. **Be consistent across the set:** same names and notation everywhere, with a clear reading order from one diagram to the next.

Example labels: container `Orders API` [Node.js, REST] -> `Orders DB` [PostgreSQL] with the line "Reads and writes orders" [SQL].

## 4. Building order

1. Level 1: the system in the middle, every person and external system around it; no internal parts.
2. Level 2: expand into containers (apps, APIs, workers, databases, queues), keeping the same outer persons and systems.
3. Add a deployment or dynamic diagram only when a deployment or a runtime flow is the question.
4. Add Level 3 for one complex container at a time; internal design rules live in `hexagonal-architecture`.
5. Keep diagrams as text in the repository so changes review as diffs; pipeline in [references/c4-docs-as-code-pipeline.md](references/c4-docs-as-code-pipeline.md); Mermaid syntax and limits in `mermaid`; how diagrams sit inside chapters in `arc42-api-contracts-architecture`.

## 5. Mistakes to catch

- Reading "container" as Docker. A browser SPA, a mobile app, a serverless function and a managed database schema are containers.
- Drawing a database or broker as a bare line. It is a container; show who writes and who reads.
- A box called "business logic" or "shared utils". Code libraries live inside a container; they are not containers.
- Two-way unlabeled arrows, which hide who initiates and the protocol.
- Color or shape meaning with no key, unexplained acronyms, missing technology.
- Treating several apps on one runtime as one container: each app is its own container.

## Quick Decision Checklist

- [ ] Does each diagram stay at one level and zoom into one element?
- [ ] Does each element show type, description and (containers, components) technology?
- [ ] Is each relationship one-way and labeled with purpose, plus protocol between containers?
- [ ] Does each diagram have a title with type and scope, and a key?
- [ ] Are databases, queues and managed stores drawn as containers?
- [ ] Did I draw Level 3 or 4 only where structure is not obvious?

## Deep references

- [C4 abstractions and levels](references/c4-abstractions-and-levels.md): read when deciding what is a container and which levels to draw.
- [C4 docs-as-code pipeline](references/c4-docs-as-code-pipeline.md): read when generating C4 diagrams from a Structurizr toolchain.
- [Trigger evals](references/trigger-evals.md): read when tuning the description.
- [Sources](references/sources.md): retrieval statuses, reading limits, claims not adopted.
