---
name: monolithic-architecture
description: Use when evaluating, designing, or maintaining a traditional Monolithic Architecture, deciding between Monolith-First and Microservices, or organizing a single-deployable application cleanly so it avoids becoming a Big Ball of Mud. Gives the Monolith-First decision rules, single-unit deployment invariants, internal layering, scaling and evolution strategies, and common mistakes.
---

# Traditional Monolithic Architecture

One idea: build, package, and deploy the application's behavior as a **single autonomous deployment unit** running in one process (and sharing one transactional database), avoiding the "Microservice Premium" until domain boundaries are proven and operational scale truly requires physical distribution. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary

| Term | Meaning | Test sentence |
|---|---|---|
| Monolith | a self-contained application whose core behavior executes in a single process and deploys as one unit | "one build artifact, one deployment pipeline, in-process function calls" |
| Monolith First | strategy of starting a new system as a monolith even if you expect it may grow into microservices later | "discover Bounded Context boundaries in code before hardening them over the network" |
| Microservice Premium | the operational, latency, consistency, and tooling tax paid by distributed service architectures | "slows a team down unless the system is too complex for a monolith" |
| All-in-One Monolith | the simplest form: one project/package containing UI, business rules, and data access | "fastest startup for small apps or MVPs, highest risk of tangling as it grows" |
| Layered Monolith | a single deployment unit divided internally into logical layers or projects (UI, Business, Data) | "one deployable binary, separated internal namespaces/modules" |
| Horizontal Clone Scaling | scaling a stateless monolith by running multiple identical instances behind a load balancer | "scale the whole process replica, not individual sub-modules" |
| Sacrificial Architecture | an intentionally simple monolith built to validate product viability quickly and be replaced later | "optimize for learning speed and cycle time first" |

## Architectural rules and invariants

1. **Single deployment unit, in-process calls:** Every feature ships in the same deployable artifact (binary, container image, web app). Modules communicate via fast, type-checked, in-process function calls rather than network RPCs.
2. **ACID transactions by default:** Because data lives in a unified database, cross-feature state changes can use native database transactions (`BEGIN ... COMMIT`) instead of complex distributed Sagas or eventual consistency.
3. **Keep the monolith process stateless for horizontal scaling:** Store user session state, file uploads, and shared caches outside local process memory (in the database, Redis, or object storage) so the monolith can be duplicated across $N$ servers or containers behind a load balancer.
4. **Enforce internal logical separation early:** Even inside a single deployment unit, separate presentation, business logic, and data access (or feature slices) so refactoring boundaries remains cheap. Cross-module refactoring inside a monolith is an IDE operation; across microservices it is a distributed migration.
5. **Pay the Microservice Premium only when earned:** Do not split a monolith into microservices on day one (*Monolith First*). Wait until domain boundaries (Bounded Contexts) have stabilized and team size or independent scaling bottlenecks exceed what a single deployment unit can support.

## Building and evolution order

1. **Start single-unit and modular:** Build inside one repository and one deployment pipeline with clear internal folder/package boundaries (`layered-n-tier-architecture`, `clean-architecture`, or `modular-monolith-architecture`).
2. **Automate a fast CI/CD pipeline:** Run unit and integration tests against a real test database on every commit and deploy the single container/artifact atomically.
3. **Scale vertically and horizontally first:** Before splitting services, optimize database queries (`query-performance`), add caching, and scale horizontally with stateless replicas behind a load balancer.
4. **Peel off edges only when justified:** If one specific workload (e.g., video transcoding, high-frequency webhook ingestion) has radically different scaling or reliability needs, extract just that edge while keeping the core monolith intact.

## Testing strategy

| Scope | Test | Uses |
|---|---|---|
| Domain / Business logic | unit tests | fast in-process calls with zero network mocking |
| Database & transactions | integration tests | real local/containerized test database verifying ACID rollbacks and constraints |
| HTTP / UI routes | route / functional tests | in-process test server against the real test database |
| Deployment artifact | smoke test | boots the single container/binary and checks health + 1 critical flow |

## When it earns its keep

- **Worth it:** Almost all greenfield products (*Monolith First*), startups and MVPs validating product-market fit, small-to-medium engineering teams, domains where Bounded Contexts are still being discovered, and systems requiring strong transactional consistency with low operational overhead.
- **Not worth it:** Very large organizations where dozens of independent teams step on each other's release trains daily, or workloads where specific sub-components require heterogeneous runtimes, strict fault isolation, or 100x asymmetric compute scaling that cannot be handled by horizontal monolith replicas.

## Mistakes to catch

- **Equating "Monolith" with "Big Ball of Mud":** Letting any file import any table or UI helper without internal boundaries. A monolith is a deployment topology, not an excuse to skip modular design.
- **Premature Microservices on Greenfield:** Splitting a brand-new product into 10 microservices before domain boundaries are understood — cementing wrong boundaries behind network APIs and slowing feature delivery to a crawl.
- **In-memory local state blocking horizontal scale:** Storing active user sessions or uploaded files on the local container filesystem so load-balanced replicas see inconsistent state.
- **Manual or fragile deployments:** Letting the build/test suite grow so slow that teams fear deploying the monolith. Keep tests fast and deployments automated.
- **Trying to decompose a tangled monolith overnight:** If a monolith has no internal module boundaries, extracting microservices directly will create a distributed big ball of mud. Refactor to a `modular-monolith-architecture` first.

## Quick Decision Checklist

- [ ] Am I starting as a single deployment unit, avoiding the Microservice Premium until it is earned?
- [ ] Are modules separated internally (layers or feature slices) so it is not a big ball of mud?
- [ ] Is the process stateless, with sessions, uploads and caches kept outside local memory?
- [ ] Am I using native ACID transactions instead of Sagas for cross-feature changes?
- [ ] Did I try query tuning, caching and horizontal replicas before splitting anything?
- [ ] Is a split justified for one specific workload, extracting only that edge?
- [ ] Is the CI/CD pipeline fast and automated, with tests against a real test database?

## Deep references

- [Monolith First evolution paths](references/monolith-first-evolution-paths.md) — arguments, evolution options and counter-argument for greenfield decisions
- [Monolith structure, deployment and comparison](references/monolith-structure-deployment-and-comparison.md) — internal layering, containers, monolith vs microservices dimensions
