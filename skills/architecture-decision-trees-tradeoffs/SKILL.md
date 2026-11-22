---
name: architecture-decision-trees-tradeoffs
description: Use when selecting among architectural styles, hosting/compute models, or technology choices across competing non-functional characteristics ("-ilities") — applying Mark Richards & Neal Ford's Architecture Styles Star-Rating Matrix, Architecture Quantum, Architectural Characteristics Worksheets, Architectural Katas, and Microsoft Azure Architecture Styles & Compute Decision Trees (IaaS vs. PaaS vs. FaaS).
---

# Architecture Decision Trees & Trade-Off Analysis

One idea: **there is no universally "best" architecture or technology — there is only the least-worst combination of trade-offs** for a specific **domain topology**, **Architecture Quantum**, and prioritized set of **Architectural Characteristics (`-ilities`)**. Select candidate topologies systematically rather than by hype or familiarity. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Richards, Ford & Azure Architecture Center)

| Term | Meaning | Test sentence |
|---|---|---|
| First Law of Software Architecture | *"Everything in software architecture is a trade-off"* (Richards & Ford) | "if you think an option has zero downsides, you haven't found its trade-off yet" |
| Second Law of Software Architecture | *"Why is more important than how"* — capturing forces and rationale outlives implementation mechanics | "always document why an option won and why alternatives lost (`adr-architecture`)" |
| Architecture Characteristics (`-ilities`) | non-domain design considerations that influence structural topology and are critical to success (**Operational**, **Structural**, **Cross-Cutting**) | "pick the top 3–5 driving `-ilities` rather than over-specifying all 20" |
| Architectural Quantum | an independently deployable artifact with **high functional cohesion** and **synchronous connascence** (usually includes its own database/UI boundary) | "4 services sharing 1 central database still behave largely as 1 operational quantum" |
| Domain vs. Technical Partitioning | grouping top-level modules by **business subdomain** (workflow/DDD) vs. by **technical layer** (UI, service, persistence) | "match codebase partitioning to the axis along which changes actually occur" |
| Architecture Styles Worksheet (Star Matrix) | Richards & Ford's cross-style rating chart comparing Monolithic/Layered/Pipeline/Microkernel/Event-Driven/Space-Based/Service-Based/Microservices on common `-ilities` | "match prioritized `-ilities` against style strengths before picking frameworks" |
| Architectural Kata | bounded, small-group architecture design exercise (*Ted Neward / Neal Ford*) practicing style selection and trade-off justification | "practice selecting styles and articulating trade-offs under explicit business constraints" |

## Step-by-Step Style & Trade-Off Selection Heuristic

1. **Discover and constrain the Driving Architecture Characteristics (Target 3–5):**
   - Separate **Explicit** requirements (written SLAs, compliance, latency targets) from **Implicit** requirements (availability, data integrity, security).
   - Classify along three axes: **Operational** (scalability, elasticity, availability, recoverability, performance), **Structural** (modularity, testability, deployability, maintainability, extensibility), and **Cross-Cutting** (security, privacy, legal, accessibility).
   - *Rule against over-specification:* Avoid designing for every `-ility` at maximum strength simultaneously — over-constraining leads to accidental complexity (the "Vasa" anti-pattern). Force stakeholders to rank the top 3–5 characteristics that genuinely drive structural shape.
2. **Determine Architecture Quanta and Partitioning Axis:**
   - Ask how many distinct **Architectural Quanta** are needed (e.g., an admin catalog back-office with eventual staleness tolerance vs. a customer checkout path with sub-second latency and peak elasticity = 2 candidate quanta).
   - Decide **Monolith vs. Distributed** (`monolithic-architecture` vs. `microservices-architecture`) remembering the **8 Fallacies of Distributed Computing** (latency $\neq 0$, bandwidth $\neq \infty$, unreliable/insecure networks, changing topology, multiple admins, non-zero transport cost, heterogeneous network) and **Stamp Coupling** across network boundaries.
   - Choose **Domain Partitioning** (`modular-monolith-architecture`, `vertical-slice-architecture`, `screaming-architecture`) when business workflows change independently across domains; choose **Technical Partitioning** (`layered-n-tier-architecture`) only for smaller systems organized primarily around technical skill tiers.
3. **Map Styles to Domain Topology & Forces (Cross-Style Decision Matrix):**

| Candidate Style / Skill | Partitioning & Dependency Shape | Strong `-ilities` (When to Pick) | Core Trade-Offs (Cost Paid) |
|---|---|---|---|
| `layered-n-tier-architecture` | Technical layers; downward calls across logical layers or network tiers | Low upfront cost, familiarity, migrating legacy on-prem apps, low update frequency | Poor agility/deployability across layers; **Architecture Sinkhole** pass-through overhead |
| `monolithic-architecture` / `modular-monolith-architecture` | Single deployable quantum partitioned internally by Bounded Contexts | Simplicity, strong ACID consistency, in-process speed, low ops overhead (*Monolith First*) | Shared runtime/release blast radius unless strict module + schema boundaries hold |
| `pipes-and-filters-pattern` | Stateless filters connected by unidirectional pipes | Extensibility, batch/stream ETL, composable transformations | Poor interactive request/response ergonomics; serialization overhead between stages |
| `microkernel-plugin-architecture` | Minimal core + isolated versioned plug-ins | Customizability, third-party extensions, product variants | Plug-in compatibility governance, versioning matrix, fault isolation if in-process |
| `event-driven-architecture` | Decoupled producers & consumers via broker/stream (`Pub/Sub` or log) | Asynchronous scalability, fault isolation, near-real-time IoT/streaming, extensibility | Eventual consistency, idempotency (`idempotency-fix`), debugging/tracing complexity |
| **Web-Queue-Worker** (Azure) | Stateless web front-end + async queue + background worker pool | Simple domains with heavy/slow async jobs; easy managed cloud hosting + independent worker scaling | Both front-end and workers can degrade into tangled monoliths without discipline |
| `microservices-architecture` | Domain-partitioned autonomous services + private data per service | Independent deployability, evolutionary polyglot tech, selective scaling & team autonomy | Distributed transactions (`saga-transactional-outbox-pattern`), network latency, high DevOps maturity cost |
| `actor-model-space-based-architecture` | Partitioned in-memory Processing Units + async write-behind Data Pumps | Extreme concurrent write spikes (e.g., 10k+ concurrent bidding/ticketing spikes), low latency | Eventual database consistency, cache collision handling, complex local state rebalancing |
| **Big Data / Big Compute (HPC)** (Azure) | Partitioned data lakes/streams or embarrassingly parallel multi-core batch pools | Massive dataset analytics/ML or CPU/GPU-heavy scientific/risk simulations | Batch latency, cluster scheduling overhead, specialized storage/transfer pipelines |

4. **Match Compute Hosting Model (Azure Compute Decision Tree: IaaS vs. PaaS vs. FaaS):**
   - **Migration vs. Greenfield:** For **Lift-and-Shift** (rehosting with minimal code changes), start with **VMs / Managed VMware (IaaS)**. Only refactor into **Cloud-Optimized** containers or serverless when timeline/budget justify redesigning for cloud-native properties.
   - **Control vs. Operational Overhead Spectrum:**
     - **Full OS / Custom Kernel / Legacy Dependency Control:** **IaaS VMs** (highest operational patching/network burden).
     - **Managed Web / API Hosting (Low Ops):** **PaaS Web App Hosting** (e.g., App Service; deployment slots, built-in web hosting) or simple **Single Container Execution** (no full orchestrator needed).
     - **Event-Driven, Short-Lived, Scale-to-Zero Bursts:** **FaaS** (e.g., Azure Functions; very low ops overhead, Consumption/Flex billing — watch cold starts and durable state in `serverless-architecture`).
     - **Serverless Containers vs. Full Kubernetes (AKS / OpenShift):** Pick **Managed Serverless Containers** (e.g., Container Apps) for microservice/event-driven containers without managing K8s APIs; pick **Managed Kubernetes (AKS)** only when teams have cluster ops skills and explicitly need direct K8s API/CRD/service-mesh control (multi-node production footprint).
     - **Parallel HPC / Batch Jobs:** Dedicated **Managed Batch Compute** capable of scaling to zero after job completion.
   - **Polyglot Workload Rule:** Evaluate each distinct component separately — a single system routinely combines PaaS/containers for APIs with FaaS for event triggers and managed Batch for overnight jobs.
5. **Re-Verify Data Stores & Cross-Cloud Trade-Offs Before Recording an ADR:**
   - Align operational data (**OLTP** relational/document/key-value) separately from analytical data (**OLAP**/Data Lake/Vector Search) using `technology-choices-overview` criteria (data model, consistency, scale, cost, region/SLA limits).
   - Check multi-region topology needs early: most managed compute platforms are **single-region** by default and require an external global router/load balancer for active-active or active-passive failover.
   - Record the final style + compute decision, prioritized `-ilities`, and rejected options in `adr-architecture` using Y-Statements and Fitness Functions (`archunit`/CI checks) to prevent future drift.

## Architectural Katas & Review Checklist

Practice or peer-review decisions with concrete constraints (*Ted Neward / Neal Ford katas* & Richards's decision rules):
- **Justify via Concrete Drivers:** Name the 3–5 driving `-ilities` *and* the exact constraint in requirements that forces them (e.g., "flash sale spikes" $\to$ Elasticity, not "good performance").
- **Prefer Synchronous by Default, Asynchronous When Needed:** Asynchronous decoupling buys elasticity/resilience at the cost of eventual consistency and trace complexity — justify paying that tax.
- **Avoid Decision Anti-Patterns (Richards & Ford):**
  - **Covering Your Assets:** Infinitely deferring decisions out of fear instead of prototyping/testing reversibility and moving.
  - **Groundhog Day:** Failing to record *why* a choice won in an ADR (`adr-architecture`), forcing teams to re-debate the same technology every quarter.
  - **Email-Driven Architecture:** Losing architecture decisions in chats/emails instead of a shared, discoverable decision log.
- **Keep Multi-Cloud/Vendor Mapping Explicit:** When migrating across AWS, Azure, or GCP, map capabilities by *workload pattern* (PaaS, FaaS, managed K8s, pub/sub, analytical store) before matching managed SKU names.

## Mistakes to Catch

- **Chasing Star Ratings Blindly Without Domain Context:** Picking Microservices or Event-Driven Architecture solely because their scalability/extensibility ratings are high while ignoring team size (e.g., 4 engineers) and ACID requirements.
- **Confusing Data Sharing Across Services as "Multiple Quanta":** Splitting compute into 5 deployables that all query one shared schema creates distributed deployment pain without decoupling the architectural quantum.
- **Treating Kubernetes as Default Greenfield Compute:** Paying AKS cluster management and multi-node operational overhead when PaaS web hosting or serverless containers satisfy every actual SLA.
- **Evaluating Only Happy-Path Functional Requirements:** Choosing compute and style without mapping explicit failure modes, regional SLA limits, or team operational skills.
