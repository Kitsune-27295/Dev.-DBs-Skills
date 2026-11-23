---
name: c4-model-architecture
description: Use when creating, reviewing, or maintaining software architecture diagrams using Simon Brown's C4 Model — zooming across Level 1 (System Context), Level 2 (Container), Level 3 (Component), and Level 4 (Code) plus System Landscape, Dynamic, and Deployment diagrams. Gives the 4 hierarchical abstractions, Simon Brown's diagram notation checklist, Mermaid/Structurizr/PlantUML rules, and common "boxes and lines" mistakes.
---

# C4 Model (Hierarchical Architecture Diagramming)

One idea: treat architecture diagrams like **Google Maps for your code** — define a strict hierarchy of four abstractions (**Person / Software System**, **Container**, **Component**, **Code**) and zoom in across four matching diagram levels so every audience (business, product, architects, developers) gets a clear, notation-consistent map without mixing abstraction levels on one canvas. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary: The 4 Hierarchical Abstractions (Simon Brown)

| Abstraction | Meaning | Test sentence |
|---|---|---|
| 1. Person | a human role, actor, or persona who uses the software system | "Customer, Admin User, Support Agent" |
| 2. Software System | the highest level of abstraction that delivers value to users (your system in scope, plus external systems it talks to) | "Internet Banking System, Mainframe Core, SendGrid Email System" |
| 3. Container | a separately runnable / deployable application or data store inside your Software System (**not** just Docker! A SPA running in a browser, a mobile app, a Node/Go API process, a PostgreSQL DB, an S3 bucket, or a Kafka broker is each a C4 Container) | "if it runs in its own process space or must be deployed/hosted separately, it is a Container" |
| 4. Component | a logical grouping of related code building blocks running **inside one Container** (a controller + service module, a domain package, a driven adapter) | "lives in the same process; not separately deployable on its own" |
| 5. Code | the lowest level: classes, interfaces, functions, database tables inside one Component | "usually generated from code/IDE on demand rather than hand-maintained" |

## The 4 Core Diagram Levels + 3 Supporting Diagrams

| Diagram | Scope & Zoom Level | What appears on canvas | Target Audience |
|---|---|---|---|
| **Level 1: System Context** | 1 Software System in scope + its environment | The system in scope (1 box in center) surrounded by **People** and **External Software Systems** | Everyone (technical & non-technical: business, product, engineering) |
| **Level 2: Container** | Zooms inside the 1 Software System from L1 | All **Containers** (web apps, mobile apps, APIs, workers, DBs, queues) inside the system boundary + external People/Systems from L1 | Technical people inside and outside the team (developers, architects, ops) |
| **Level 3: Component** | Zooms inside **one specific Container** from L2 | The internal **Components** of that single Container + the adjacent Containers/Systems it calls | Developers and architects working on that specific Container |
| **Level 4: Code** (Optional) | Zooms inside **one Component** from L3 | UML class/interface/ER diagram of one complex Component | Developers implementing that component (only draw when genuinely tricky) |
| **System Landscape** (Supporting) | Enterprise / portfolio view above L1 | All People and Software Systems across an organization or department | Enterprise architects, leadership, cross-team product |
| **Dynamic Diagram** (Supporting) | One specific runtime use case / user story | Numbered interactions ($1, 2, 3\dots$) among existing C4 elements (usually at L2 Container or L3 Component level) | Developers & QA tracing a specific request or Saga flow |
| **Deployment Diagram** (Supporting) | One runtime environment (e.g., Production AWS/K8s) | How **L2 Containers** map onto physical Deployment Nodes (Cloud Regions, VPCs, K8s pods, managed DB instances) | DevOps, SRE, security, and platform engineers |

## Non-negotiable C4 Diagramming Rules (Brown's Checklist)

1. **Never mix abstraction levels on the same diagram:** Do not draw an L2 Container (e.g., `PostgreSQL Database`) or an L3 Component (e.g., `AuthController`) inside an L1 System Context diagram. And do not draw internal L3 Components of *every* microservice on a single giant L2 Container diagram — zoom into one Container per L3 diagram.
2. **Every box must carry 3 pieces of metadata (Name + Type/Technology + Short Description):**
   - Never draw a box labeled just `Backend` or `Order Service`.
   - Write: **`Order Service`** / `[Container: Go 1.24 / gRPC]` / *"Validates orders, orchestrates checkout sagas, and owns order state."*
3. **Every arrow must be unidirectional and labeled with intent + technology/protocol:**
   - Never draw unlabelled lines or vague double-headed `<-->` arrows.
   - Label the **action** in active voice and the **protocol**: e.g., `Sends order confirmation email using [HTTPS / JSON REST]` or `Publishes OrderPaid events to [Kafka / Avro]`. Indicate the direction of the **call or dependency** (who initiates the request), not just "data flows both ways."
4. **Every diagram must have a Title, Scope, and Legend/Key:** Anyone opening the diagram cold must immediately see what diagram type/level it is (`[Container] Internet Banking System`) and what every shape, border style (dashed = system boundary), and color means.
5. **Most teams only need Level 1 and Level 2 (plus Deployment/Dynamic):** Create L1 (System Context) and L2 (Container) for every system. Only create L3 (Component) diagrams for complex containers where internal module structure isn't obvious from the folder tree (`screaming-architecture`), and rarely hand-draw L4 (Code) diagrams because they go stale on every PR.
6. **Diagrams as Code in Git:** Maintain C4 diagrams as text in the repository (Mermaid `C4Context`/`C4Container` or `flowchart`, Structurizr DSL, or C4-PlantUML) integrated with `arc42-api-contracts-architecture` so diagrams are diffable and updated in PRs alongside structural changes.

## Building order

1. **Draw Level 1 (System Context) first:** Place the system in the center; list every human Persona/Role and every External System it interacts with. Verify that zero internal databases or microservices leak onto L1.
2. **Draw Level 2 (Container) second:** Expand the center box into a dashed System Boundary containing every separately runnable process (UI apps, APIs, background workers) and data store (DBs, caches, message brokers), keeping the exact same external People and Systems around the outside for visual continuity.
3. **Add a Deployment Diagram and 1-2 Dynamic Diagrams:** Show how L2 Containers run in production infrastructure and trace the 1-2 highest-risk runtime flows.
4. **Add Level 3 (Component) only for monoliths or complex containers:** Zoom into a single Container and map its internal architectural circles/slices (`hexagonal-architecture`, `clean-architecture`, `modular-monolith-architecture`).

## Mistakes to catch

- **Confusing "C4 Container" with "Docker Container":** In C4, a client-side React SPA running in the user's browser, an iOS app, a serverless Lambda function, and a managed RDS Postgres instance are all **Containers** (separately runnable execution or storage units).
- **The "Homeless Box" / Generic "Business Logic" box:** Drawing a box called `Business Logic` or `Shared Utils` inside a Container diagram when it is actually a library compiled inside an API process (libraries are L3 Components, not L2 Containers).
- **Drawing a Message Broker or Database as a pass-through line without a Container box:** If Service A writes to a database or publishes to Kafka and Service B reads from it, the Database or Kafka Broker is an **L2 Container** and must be drawn as its own node showing who writes/publishes and who reads/subscribes.
- **Bidirectional unlabelled arrows (`A <---> B`):** Hides who initiates the connection, what protocol is used, and whether the coupling is synchronous RPC or asynchronous pub/sub.
- **Unexplained color coding and acronyms:** Using 7 pastel colors with no Legend/Key and unexplained internal project code names.

## Deep references

- [C4 abstractions and levels](references/c4-abstractions-and-levels.md) — when deciding what is a container and which levels to draw
- [C4 docs-as-code pipeline](references/c4-docs-as-code-pipeline.md) — when generating C4 diagrams from a Structurizr/arc42 toolchain
