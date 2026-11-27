---
name: layered-n-tier-architecture
description: Use when designing, reviewing, or refactoring a Layered (N-Layer) or N-Tier application (Presentation/Web, Business/Middle, Data Access/Persistence), deciding between strict (closed) and relaxed (open) layer communication, or separating logical layers from physical deployment tiers. Gives the downward dependency rules, layer vs tier distinction, test strategy per layer, and common mistakes (sinkhole anti-pattern, upward imports, fat controllers/views calling the database directly).
---

# Layered & N-Tier Architecture

One idea: separate responsibilities into horizontal **logical layers** where dependencies point strictly downward (a higher layer uses services of a lower layer; a lower layer never knows a higher layer exists), and only promote a logical layer to a separate **physical tier** (separate process or machine) when scalability, security perimeter, or legacy operational constraints justify the network latency. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (stop mixing layers and tiers)

| Term | Meaning | Test sentence |
|---|---|---|
| Logical layer | a code-organization boundary grouping related responsibilities (packages, modules, namespaces) | "lives in the same process unless deployed separately" |
| Physical tier | an independently deployed runtime unit on its own machine, VM, or subnet | "crossing a tier crosses the network" |
| Presentation / Web layer | handles HTTP, UI rendering, input formatting, and session/auth entry | "knows how to talk to the user, not how data is stored" |
| Business / Domain layer | enforces business invariants, workflows, and calculations | "no SQL, no HTML, no HTTP request objects" |
| Data Access / Persistence layer | translates domain/data requests into SQL, ORM calls, or external storage operations | "knows the database schema, never the UI screen" |
| Strict (closed) layer | a request must pass through the immediately adjacent layer below it and cannot skip layers | "Presentation -> Business -> Data Access only" |
| Relaxed (open) layer | a higher layer may bypass an intermediate layer for read-only or utility shortcuts | "lower latency, higher coupling across layers" |
| Layer sinkhole | a middle layer that only passes arguments down and returns results unchanged | "pass-through boilerplate with zero business rules" |

## Dependency and boundary rules

1. **Downward-only dependencies:** Layer $N$ may only import or call Layer $N-1$ (in strict mode) or Layers $< N$ (in relaxed mode). A lower layer must never import types, callbacks, or configuration from a higher layer.
2. **Layer != Tier:** Do not put a network hop between Presentation, Business, and Data Access unless physical tier separation is explicitly required (e.g., WAF -> Web Subnet -> Middle Tier Subnet -> Database Subnet). Three logical layers can and usually should deploy as a single process.
3. **Explicit strict vs. relaxed choice:** Default to **strict (closed)** layers so business invariants and authorization checks in the Business layer cannot be bypassed by the UI calling Data Access directly. Only open a layer consciously (for example, a shared cross-cutting logging/caching layer or an explicitly read-only reporting query).
4. **No database leakage into Presentation:** Entities or raw cursor/row objects coupled to database transactions must not leak into view templates or HTTP serialization where lazy-loading (`N+1` queries) or schema leakage can fire during rendering.
5. **Security perimeters on physical tiers:** When deploying across physical N-tiers, place a Web Application Firewall (WAF) or reverse proxy in front of the Web tier, isolate each tier in its own subnet/security group, and restrict the Data tier to accept connections only from the Middle tier.

## Building order

1. **Slice by responsibility first:** Define the three core logical layers (`presentation`, `business`, `data`) and lock their import direction in the linter or build tool.
2. **Build the Business contract:** Write the business operations and domain rules with pure unit tests before wiring a database or web route.
3. **Implement Data Access behind interfaces or repositories:** Isolate SQL, ORM queries, and caching in the Data layer so business rules are not tangled with storage syntax.
4. **Add the Presentation layer:** Keep controllers/handlers thin — parse input, call the Business layer, and format the response.
5. **Choose physical tiers last:** Deploy as one unit first; split into separate Web and Middle physical tiers (or introduce an asynchronous message queue between them) only when independent scaling or network security zones require it.

## Tests per layer

| Layer | Test | Uses |
|---|---|---|
| Business layer | unit / acceptance | in-memory fakes or mocked data-access interfaces |
| Data Access layer | integration | real test database (verify queries, constraints, transactions) |
| Presentation layer | route / controller test | mocked or fake Business layer (verify status codes, auth, payload validation) |
| Physical tiers (end-to-end) | smoke / system test | one happy path and one failure path across the real deployment boundary |

Enforce rule 1 automatically with an import-graph check (`dependency-cruiser`, `ArchUnit`, `eslint-plugin-boundaries`) so upward imports fail CI.

## When it earns its keep

- **Worth it:** Traditional enterprise CRUD and line-of-business applications, migrating on-premises multi-tier workloads to cloud VMs/containers, teams organized around UI / backend / DBA skills, or when a clear default structure is needed without the indirection of full Hexagonal or Clean Architecture.
- **Not worth it:** Ultra-simple scripts (1-file or 1-module apps where 3 layers become 80% pass-through sinkholes), or complex domain-heavy systems with volatile infrastructure where the Business layer should own the ports instead of depending downward on the Data Access layer (use `hexagonal-architecture` or `clean-architecture` instead).

## Mistakes to catch

- **Confusing N-Layer with N-Tier:** Deploying Presentation, Business, and Data Access as separate network services when they scale together and live in the same trust boundary — adding serialization cost, network latency, and distributed failure modes for zero gain.
- **Architecture Sinkhole anti-pattern:** 80%+ of Business layer methods doing nothing but `return dataLayer.getX(id)`. Either allow a controlled relaxed read path or collapse unnecessary pass-through abstractions.
- **Fat Controller / Anemic Middle Layer:** Putting validation, pricing, or permission checks inside HTTP controllers or SQL stored procedures while the Business layer stays empty.
- **Upward or circular imports:** Data Access importing a DTO, request context, or error formatter defined in the Presentation layer.
- **Chatty cross-tier calls:** Making fine-grained synchronous calls in a loop across physical tiers instead of batching or using coarse-grained contracts / asynchronous queues.

## Quick Decision Checklist

- [ ] Do dependencies point strictly downward, with no lower layer importing from a higher one?
- [ ] Am I defaulting to strict (closed) layers and opening one only deliberately?
- [ ] Have I kept layers separate from tiers, adding a network hop only when explicitly required?
- [ ] Are database entities and raw rows kept out of view templates and HTTP serialization?
- [ ] Are controllers thin, with validation, pricing and permissions in the Business layer?
- [ ] Is an import-graph check enforcing the downward rule in CI?
- [ ] Is the Business layer more than a pass-through sinkhole, and are cross-tier calls coarse-grained?

## Deep references
- [Layers, tiers, and communication models](references/layers-tiers-and-communication-models.md) — strict vs relaxed tiers, Azure best practices, VM reference deployment, challenges checklist.
- [Choosing a style, topologies, and erosion](references/style-fit-topologies-and-erosion.md) — when N-tier fits vs other styles, MVC vs three-tier, monolith scaling, big ball of mud.
- [Traditional N-Layer vs Clean Architecture](references/layered-vs-clean-dependency-direction.md) — why BLL->DAL dependency hurts tests and how dependency inversion restructures projects.
