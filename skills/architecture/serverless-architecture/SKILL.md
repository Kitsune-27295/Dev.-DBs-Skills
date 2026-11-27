---
name: serverless-architecture
description: Use when designing, reviewing, or optimizing a Serverless (FaaS + BaaS) application (AWS Lambda, Azure Functions, Cloud Functions, EventBridge/Queues, managed databases/auth), managing cold starts, stateless execution limits, and connection pooling, or applying the AWS Well-Architected Serverless Lens. Gives FaaS/BaaS invariants, function design rules, testing strategy, and common cost/concurrency pitfalls.
---

# Serverless (FaaS & BaaS) Architecture

One idea: build systems out of **managed third-party backend services (BaaS)** and **short-lived, event-driven, stateless compute functions (FaaS)** that scale automatically per request/event from zero to peak — eliminating always-on server management at the cost of ephemeral state, execution-time limits, cold-start latency, and distributed vendor integration. Sources and their claims: [references/sources.md](references/sources.md).

## Vocabulary (Roberts, Janakiraman & AWS Serverless Lens)

| Term | Meaning | Test sentence |
|---|---|---|
| BaaS (Backend as a Service) | managed cloud services replacing server-side components we used to run ourselves (managed Auth, DynamoDB/Firestore, S3, SQS/EventBridge) | "zero server instances to patch or capacity-plan for this capability" |
| FaaS (Function as a Service) | ephemeral, event-triggered functions run in provider-managed containers that spin up on demand and shut down when idle | "billed per invocation and compute millisecond, not per idle hour" |
| Cold Start | the latency penalty when the FaaS platform provisions a new container and initializes the runtime/code before handling an event | "happens on the first request after idle or during a sudden concurrency spike" |
| Warm Reuse | subsequent invocations handled by an already-initialized function container | "module-scope connections and caches survive across warm invocations, never guaranteed across all invocations" |
| Event Source / Trigger | the upstream producer invoking the function (API Gateway HTTP request, queue message, storage upload, cron schedule, stream record) | "every FaaS execution begins with an event envelope" |
| Concurrency Burst / Amplification | thousands of parallel function instances spinning up simultaneously during a traffic spike | "can overwhelm downstream relational databases or non-serverless APIs" |

## Core architectural rules and invariants

1. **Functions must be strictly stateless across invocations:** Never store session data, in-flight workflow state, or local files expecting a future invocation to see them. Any state that must survive an invocation belongs in an external managed store (DynamoDB/Redis/S3/Database). Use module-level globals **only** for connection reuse and immutable cached config during warm reuse.
2. **Keep functions single-purpose, small, and short-lived:** Each function has a strict platform timeout and scales along one trigger axis. Minimize dependency bundle size so cold-start initialization stays fast.
3. **Separate business logic from the FaaS handler envelope:** Keep the provider-specific handler (`event, context`) as a thin **Driver Adapter** (`hexagonal-architecture`) that parses the trigger payload and calls pure, framework-free domain/use-case code. That enables fast local unit testing and painless migration to containers if traffic outgrows FaaS economics.
4. **Guard downstream databases against connection exhaustion:** A burst of 500 concurrent FaaS containers opening raw PostgreSQL/MySQL connections will crash a relational database. Use HTTP/serverless data APIs, DynamoDB, or a connection proxy (RDS Proxy / PgBouncer) and cap function concurrency.
5. **Every event-triggered function needs failure routing:** Triggers deliver events *at-least-once* (make handlers idempotent, `idempotency-fix`); configure Dead-Letter Queues (DLQs) or failure destinations, and bound retry counts so poison messages do not loop forever and explode the cloud bill (`database-cost-guard`).
6. **Least-privilege IAM per function:** Give each function its own narrow execution role (e.g., `dynamodb:PutItem` on one table), never a shared wildcard role across all functions.

## Building order

1. **Separate the pure domain/use case from the cloud trigger:** Write and unit-test the business function in plain TypeScript/Python/Go/C# with driven ports for storage and external APIs.
2. **Design the event/API contract and failure path:** Define the API Gateway schema or queue/event payload, idempotency key, timeout, retry policy, and Dead-Letter Queue (DLQ).
3. **Write the thin FaaS handler:** Initialize SDK clients and database pools outside the handler function (at module scope for warm container reuse), parse the event inside the handler, and delegate to the use case.
4. **Codify infrastructure and alarms as code (IaC):** Declare functions, triggers, least-privilege permissions, concurrency limits, and billing/error alarms in declarative IaC (SAM, Serverless Framework, CDK, Terraform).

## Testing strategy

| Scope | Test | Uses |
|---|---|---|
| Domain & Use Case logic | unit test (fast, local, majority of suite) | plain code + in-memory fakes (zero cloud emulator needed) |
| Handler adapter parsing | unit test | sample JSON event payloads (API Gateway, SQS, EventBridge fixtures) |
| Cloud BaaS integration | cloud integration test | real ephemeral cloud stack (or targeted Testcontainers) verifying IAM, DB queries, and event wiring |
| Production observability | semantic monitoring & tracing | structured JSON logs, correlation IDs, distributed tracing (X-Ray / OpenTelemetry), and budget alerts |

## When it earns its keep

- **Worth it:** Bursty, unpredictable, or occasional traffic (where paying for 24/7 idle servers is pure waste), asynchronous event processing pipelines (file uploads, webhooks, ETL streams, scheduled jobs), rapid MVP delivery leveraging BaaS, and small teams minimizing infrastructure ops.
- **Not worth it:** High-throughput, steady-state 24/7 compute workloads (where reserved containers/VMs are significantly cheaper), ultra-low-latency systems that cannot tolerate cold-start tail latency, or long-running stateful computations exceeding FaaS execution limits.

## Mistakes to catch

- **Believing "#NoOps":** Serverless removes *server OS patching*, not operations. You still own monitoring, distributed tracing, security permissions, downstream throttling, third-party outage handling, and cost control.
- **Synchronous FaaS-calls-FaaS chains:** Having Function A synchronously invoke and wait on Function B (paying double compute billing while A sits idle waiting, and multiplying cold starts). Orchestrate via queues/events or Step Functions / Durable Functions instead.
- **Unbounded concurrency + recursive trigger loops:** A function triggered by an S3 bucket writing back to the same S3 bucket (infinite loop and massive bill). Never let a function write back to its own trigger source, and always set concurrency and budget caps.
- **Opening a new DB connection or SDK client inside the handler on every invocation:** Exhausts sockets and adds latency. Instantiate clients at module scope so warm invocations reuse them.
- **Locking business logic inside the vendor handler:** Mixing AWS/Azure event structures and vendor SDK calls directly into domain rules so the logic cannot be tested locally or moved to a container.

## Quick Decision Checklist

- [ ] Is the function stateless, with any state that must survive held in an external managed store?
- [ ] Is the handler a thin adapter calling pure domain code that runs locally without the cloud?
- [ ] Are SDK clients and DB pools created at module scope, not inside the handler per invocation?
- [ ] Is database connection exhaustion handled with a data API, DynamoDB or a connection proxy?
- [ ] Is every event-triggered function idempotent, with a DLQ or failure destination?
- [ ] Does each function have its own least-privilege role, with concurrency and budget caps?
- [ ] Does any function call another synchronously, or write back to its own trigger source?
- [ ] Does the workload suit serverless: bursty traffic, not steady 24/7 compute or cold-start-sensitive latency?

## Deep references

- [BaaS, FaaS and trade-offs](references/baas-faas-tradeoffs.md) — when judging whether serverless fits and what limits apply
- [AWS lens failure management](references/aws-lens-failure-management.md) — when designing DLQs, retries and stream error handling
