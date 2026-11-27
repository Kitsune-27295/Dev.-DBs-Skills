---
name: soa-vs-microservices-architecture
description: "Choose between, or move from, enterprise-scope SOA (ESB, shared data, reuse-first, many protocols) and application-scope microservices (smart endpoints, dumb pipes, private data per service): the structural differences from IBM and AWS, why business logic and canonical models do not belong in a bus, and incremental migration. Not for designing microservices themselves (`microservices-architecture`), event patterns (`event-driven-architecture`) or a single-deployable design (`monolithic-architecture`). Use when comparing SOA and microservices, auditing an ESB estate, or planning a move off one."
---

# Service-Oriented Architecture (SOA vs. Microservices)

One idea: both SOA and Microservices decompose software into network-accessible services, but they optimize for **opposite primary forces** — **SOA operates at Enterprise Scope to maximize cross-application reuse and heterogeneous legacy integration** (often via an **Enterprise Service Bus [ESB]** and shared enterprise data), whereas **Microservices operate at Application Scope to maximize independent team agility and deployability** (via **smart endpoints, dumb pipes, and a private database per service**). Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary & Structural Contrast (IBM, AWS & Fowler)

| Dimension | Service-Oriented Architecture (SOA) | Microservices Architecture |
|---|---|---|
| **1. Scope** | **Enterprise-wide**: integrates multiple disparate enterprise applications (ERP, CRM, Mainframe, Billing) across an organization | **Single Application**: decomposes one business application into fine-grained, independently deployable domain services |
| **2. Primary Goal** | **Maximize Reuse & Interoperability** across heterogeneous enterprise systems | **Maximize Agility, Independent Deployment & Decoupling** (prefers controlled data duplication over cross-team coupling) |
| **3. Communication Fabric** | **Enterprise Service Bus (ESB)**: "smart pipe" that handles protocol translation (AWS lists SOAP, AMQP, MSMQ), routing and transformation; per this skill's rules it must not hold business choreography | **Smart Endpoints & Dumb Pipes**: lightweight HTTP/REST, gRPC, or simple pub/sub brokers that only route messages without business logic |
| **4. Data Ownership** | **Shared Data Storage**: multiple services frequently read/write a shared enterprise database or canonical enterprise data model | **Private Database per Service**: each microservice strictly encapsulates its own database schema and storage engine |
| **5. Service Granularity** | Services in four roles per IBM: functional/business, enterprise, application and infrastructure (security, authentication); scope ranges from small to enterprise-wide | Much smaller services that each specialize in one task (AWS); aligning them with a DDD Bounded Context is the `microservices-architecture` rule |
| **6. Governance & Deployment** | Consistent, common governance over shared resources (AWS, IBM); changes often force a rebuild of the whole application (AWS). Canonical schemas and lockstep releases are typical symptoms (agent inference) | Decentralized governance, team-owned contracts (Consumer-Driven Contracts), and fully independent CI/CD deployments |

## Core architectural rules and invariants

1. **Never build a "Microservice" architecture around a smart ESB or Canonical Enterprise Data Model:** Putting business orchestration, data transformation, and a shared company-wide `CanonicalCustomer` schema inside a central integration bus couples every team's release cycle together — recreating the worst failure mode of heavyweight SOA.
2. **Choose SOA when integrating heterogeneous enterprise platforms; choose Microservices when building an agile product:**
   - If you are bridging a 20-year-old mainframe, an SAP ERP, Salesforce, and a legacy SQL database across different protocols (SOAP, MQ, flat files, REST), an **SOA integration layer / mediation bus** is the right tool.
   - If you are building a cloud-native application owned by autonomous product teams that need to deploy 10 times a day, use **Microservices** (or start with a `modular-monolith-architecture`).
3. **Avoid the ESB Single Point of Failure (SPOF) and Bottleneck:** If maintaining an SOA estate, keep business domain rules inside the services rather than inside proprietary ESB scripts/XSLT transformations. An ESB that holds business logic becomes an un-testable, vendor-locked monolith in the middle of the network.
4. **Trade Reuse for Decoupling consciously:** In SOA, sharing a single `CustomerEntityService` across 15 applications saves code duplication but means every change requires a 15-team committee and synchronous cross-system calls. In Microservices, replicate the subset of data each Bounded Context needs via **Event-Carried State Transfer** (`event-driven-architecture`) so services stay autonomous.
5. **Migrate from SOA to Microservices incrementally (Strangler Fig + Anti-Corruption Layer):**
   - Do not rewrite an entire ESB/SOA estate in one big bang.
   - Wrap legacy SOA/ESB endpoints behind an **Anti-Corruption Layer (ACL)** (`dto-mapper-anti-corruption-layer`) so new Bounded Contexts are not polluted by legacy canonical schemas. Strangler Application and ACL are Richardson's refactoring patterns; applying them to an ESB estate is agent inference, since IBM and AWS give no migration path.
   - Untangle the **Shared SOA Database** first (split schemas by Bounded Context) before splitting runtime services.

## Evaluation and migration workflow

1. **Audit the current service estate against the 6 dimensions above:** Identify whether your "microservices" are actually coarse-grained SOA services sharing one database or blocked on a central integration team.
2. **Isolate the Canonical Schema trap:** apply rules 1 and 5 (per-context contracts behind an ACL).
3. **Extract business orchestration out of the ESB:** Move workflow state machines out of the transport bus into domain-owned **Saga Orchestrators** (`saga-transactional-outbox-pattern`) or application services wrapped in code-level tests.
4. **Decouple shared databases:** apply rule 5 (single-service table ownership; cross-boundary data via versioned APIs or domain events).

## Testing strategy

For an SOA integration estate, test protocol mediation, schema validation, ACL translation and ESB fault isolation, so one slow legacy backend does not stall the rest (agent inference). For a microservices estate, see `microservices-architecture` and `testing-pyramid-and-shapes`.

## When each earns its keep

- **SOA earns its keep:** Large enterprises integrating diverse third-party COTS packages, legacy mainframes, and multi-protocol B2B systems where protocol mediation and enterprise-wide service cataloging are the primary problems.
- **Microservices earn their keep:** Cloud-native products where small, cross-functional teams own distinct business subdomains and require independent scaling, fault isolation, and high-frequency continuous deployment (`microservices-architecture`).

## Mistakes to catch

- **"SOA in Microservice Clothing":** services that share one database or need lockstep deployments (the Distributed Monolith, see `microservices-architecture`).
- **Putting domain business rules inside the ESB / API Gateway:** Writing pricing, eligibility, or workflow branching logic inside MuleSoft/BizTalk/Camel/Kong routing rules where developers cannot unit-test them locally.
- **The Canonical Data Model Bottleneck:** Forcing Billing, Shipping, Marketing, and Support to agree on one giant 300-field `EnterpriseOrder` schema instead of letting each Bounded Context model only the fields relevant to its role.
- **Synchronous request chaining across Enterprise Services:** Chaining 5 synchronous SOA services over an ESB so a slowdown in one legacy system exhausts thread pools across the entire enterprise.

## Quick Decision Checklist

- [ ] Is the need heterogeneous enterprise integration (SOA) or an agile product with autonomous teams (microservices)?
- [ ] Is business logic kept out of the ESB, gateway routing rules and proprietary transformation scripts?
- [ ] Am I avoiding a company-wide canonical data model in favor of per-context contracts?
- [ ] Does every table have a single owning service, with shared databases untangled first?
- [ ] Are legacy endpoints wrapped in an Anti-Corruption Layer, migrating incrementally rather than big bang?
- [ ] Are long synchronous chains across services avoided?

## Deep references

- [SOA vs microservices comparison dimensions](references/soa-vs-microservices-comparison-dimensions.md) — when comparing scope, data, communication and governance
- The nine Lewis and Fowler characteristics (audit "is it really microservices?"; a shared database or a central rule engine is evidence of SOA-style coupling) live in `microservices-architecture`, file `references/fowler-lewis-nine-characteristics.md`.
- [Trigger evals](references/trigger-evals.md) — read when tuning the description or checking which skill owns a request.
