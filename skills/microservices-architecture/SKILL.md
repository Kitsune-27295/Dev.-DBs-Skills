---
name: microservices-architecture
description: Use when designing, reviewing, or operating a Microservices Architecture (independently deployable services organized around business capabilities/DDD subdomains, each owning its private database), or solving distributed data consistency (Sagas, Transactional Outbox, API Composition). Gives the 9 Fowler/Lewis characteristics, Chris Richardson's pattern language rules, contract testing, and common distributed monolith mistakes.
---

# Microservices Architecture

One idea: structure an application as a suite of **independently deployable, loosely coupled services**, each organized around a **business capability (DDD subdomain)**, running in its own process, owned by a small cross-functional team, and **owning its private database** — trading in-process simplicity for independent deployability and team autonomy. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Fowler, Lewis & Richardson)

| Term | Meaning | Test sentence |
|---|---|---|
| Service (Component) | an out-of-process component that communicates via network mechanisms (HTTP/REST, gRPC, message broker) and deploys independently | "can I deploy this service on Tuesday without coordinating or redeploying any other service?" |
| Business Capability / Subdomain | a slice of business functionality (e.g., `Order Management`, `Catalog`, `Delivery`) that defines a service boundary | "organized around what the business does, not technical layers like 'UI service' or 'DB service'" |
| Database per Service | each service's persistent data is private to that service and accessible only via its published API | "no other service holds credentials or writes SQL against this service's tables" |
| Smart Endpoints and Dumb Pipes | services own all domain logic; the communication fabric (HTTP or lightweight message broker) merely routes bytes/messages | "no enterprise service bus (ESB) holding business orchestration rules" |
| Saga | a sequence of local transactions across services coordinated via asynchronous messages (choreography or orchestration) with compensating transactions on failure | "how microservices maintain data consistency without 2PC distributed transactions" |
| Transactional Outbox | atomically persisting a domain state change and an outbound event in the service's local database before relaying it to the broker | "prevents dual-write bugs between DB and message broker" |
| Consumer-Driven Contract | an automated test suite authored by a client service that verifies a provider service's API still satisfies the client's expectations | "catches breaking API changes without spinning up 20 services" |

## Non-negotiable architectural invariants

1. **Independent deployability is the litmus test:** If two services must be deployed together in lockstep, or share a mutable code library of domain entities that forces simultaneous releases, you have a **Distributed Monolith**, not microservices.
2. **Private database per service (Decentralized Data Management):** Never share a database table across services. Other services may only read or mutate a service's state through its versioned API or by subscribing to its published domain/integration events.
3. **Eliminate long synchronous call chains:** Deep chains of synchronous RPC/HTTP calls (`A -> B -> C -> D`) multiply latency and destroy availability (the product of each service's uptime). Prefer asynchronous collaboration (events, Saga choreography/orchestration) or local read replicas (CQRS / API Composition) for cross-service flows.
4. **Design for failure at every network boundary:** Every remote call can time out, throttle, or fail. Wrap outbound synchronous calls with explicit timeouts, bounded retries with exponential backoff + jitter, circuit breakers, and bulkheads.
5. **No distributed 2PC transactions:** Use **Sagas** (with explicit compensating actions for rollbacks) for cross-service writes, and **API Composition** or **CQRS views** for cross-service queries.
6. **Prerequisites before splitting:** Do not adopt microservices without automated CI/CD deployment pipelines, rapid infrastructure provisioning, centralized structured logging, distributed tracing (correlation/trace IDs), and basic health/metrics monitoring.

## Building and decomposition order

1. **Verify the prerequisites and domain maturity:** Confirm whether you should start `monolithic-architecture` / `modular-monolith-architecture` first. Only decompose when subdomain boundaries are stable and independent team delivery or scaling demands it.
2. **Identify subdomains and system operations:** Map business capabilities and DDD Bounded Contexts; assign each subdomain to one service with a clear public API and private data store.
3. **Design distributed operations explicitly:** For every cross-service write, define the Saga steps and compensating transactions; for every cross-service read, choose between API Gateway/BFF composition or a local CQRS projection updated by events.
4. **Implement each service internally with clean boundaries:** Inside a service, use `hexagonal-architecture` or `clean-architecture` plus the **Transactional Outbox** and **Idempotent Consumer** (`idempotency-fix`) patterns.
5. **Verify contracts in CI:** Gate every service pipeline on unit tests, component tests (in-process with testcontainers/fakes), and Consumer-Driven Contract tests.

## Tests per level (the Microservice Testing Pyramid)

| Level | Test | Uses |
|---|---|---|
| Domain & Use Cases (inside one service) | unit test (fast, largest share) | pure domain objects and in-memory port fakes |
| Service Component Test | in-process / container boundary test | boots the single service against its real test DB and stubs external services |
| Contract Integration Test | Consumer-Driven Contract (e.g., Pact) | verifies producer and consumer agree on request/response/event schema without running both live |
| End-to-End System Test | minimal smoke suite | 1-2 critical business journeys across deployed services (keep small; brittle E2E suites stall releases) |

## When it earns its keep

- **Worth it:** Large, business-critical systems developed by multiple cross-functional teams (Team Topologies stream-aligned teams) practicing continuous delivery, where independent release velocity, technology heterogeneity, fault isolation, or asymmetric scaling outweigh the distributed systems tax.
- **Not worth it:** Small teams (e.g., 1-2 two-pizza teams), early-stage startups still pivoting on their domain model, or tightly coupled domains where nearly every user action spans 5 services synchronously.

## Mistakes to catch

- **The Distributed Monolith:** Splitting code into 12 repositories that all read/write the same central database or require coordinated multi-service deployments.
- **Nano-services / Entity services:** Creating a service per database table (`UserService`, `AddressService`, `PhoneNumberService`) instead of around a cohesive business capability / aggregate lifecycle — resulting in chatty synchronous calls for every operation.
- **Dual-writing to DB and Broker without an Outbox:** Calling `db.save()` followed by `broker.publish()` in application code without a Transactional Outbox — guaranteeing inconsistent state when the process crashes or the broker blips.
- **Missing Idempotency on Consumers:** Assuming a message broker delivers events "exactly once." Brokers deliver *at-least-once*; every event consumer and Saga step must be idempotent (`idempotency-fix`).
- **Breaking API changes without versioning:** Modifying or removing a field in a REST/gRPC response or event payload without backward compatibility or contract tests.

## Quick Decision Checklist

- [ ] Are subdomain boundaries stable, and was a monolith-first start considered?
- [ ] Are the prerequisites in place: CI/CD, provisioning, centralized logs, tracing and monitoring?
- [ ] Can each service deploy independently without a lockstep release?
- [ ] Does each service own its private database, with no shared tables?
- [ ] Are long synchronous call chains avoided, with timeouts, retries and circuit breakers on remote calls?
- [ ] Do cross-service writes use Sagas, with an Outbox for events and idempotent consumers?
- [ ] Are Consumer-Driven Contract tests gating every pipeline?

## Deep references

- [Fowler and Lewis: the nine characteristics in depth](references/fowler-lewis-nine-characteristics.md) — read when judging whether a design is really microservices or a distributed monolith.
- [Microservice premium, monolith first and adoption readiness](references/microservice-premium-and-adoption-readiness.md) — read when deciding whether, when and how to split a system.
