# SOA vs Microservices: Comparison Dimensions (IBM and AWS)

Sources: https://www.ibm.com/think/topics/soa-vs-microservices ; https://aws.amazon.com/compare/the-difference-between-soa-microservices/ · Last verified 2026-11-27

## Definitions

- **SOA:** enterprise-wide approach composing applications from reusable services, each a business function (check credit, process a mortgage). Emerged late 1990s to replace point-to-point integration. Each service has an interface, a contract and an implementation; services compose into higher-level ones. IBM lists functional/business, enterprise, application and infrastructure services (security, authentication).
- **Microservices:** loosely coupled, specialized components serving one application, usually API-connected, often containerized and cloud native. AWS says they evolved from SOA and are much smaller.

Core difference per IBM: **scope**, enterprise versus application. The two can complement each other.

## Dimension table

| Dimension | SOA | Microservices |
|---|---|---|
| Reuse | share components for efficiency | prefer copying; shared runtime parts add dependencies |
| Communication | via a central ESB, a possible single point of failure | direct APIs; async patterns such as pub/sub |
| Protocols | broad: SOAP, AMQP, MSMQ | lightweight HTTP/REST, JMS |
| Data | read/change at primary source, shared layer | per-service store, accept duplication |
| Granularity | small to enterprise-wide | highly specialized |
| Deployment | AWS: a change often means rebuilding the whole application (IBM does not address SOA deployment) | independent, containerizable |
| Speed | slows as services compete for shared resources (AWS); IBM adds that troubleshooting is simpler | each service scales on demand (AWS) |
| Governance | common standards | team-chosen, harder to keep consistent |

AWS example: an ecommerce inventory service in SOA splits in microservices into availability checking, fulfillment and accounting.

## SOA limits that motivated microservices (AWS)

ESB single point of failure; one shared data repository hard to manage per service; broad scope lets one failure disrupt a whole business workflow. Microservices add bounded contexts and fewer interdependencies, but direct API communication can create complex data paths that need monitoring.

## When to pick which

- SOA: large, heterogeneous estates with legacy or standalone enterprise applications and many protocols; reuse existing services.
- Microservices: agile teams with CI/CD, per-service scaling, mixed languages/frameworks, smaller web/mobile estates.
- Migration: SOA is sometimes a stepping stone from a monolith; DevOps helps move on selectively. AWS has no migration section, only a general move from monolith.

## How an agent should apply this

- Ask scope first: integrating an enterprise estate (SOA concerns) or decomposing one product (microservices)?
- Reject any design with a shared database between independently deployed services.
- Keep business rules out of the ESB or gateway; it is for mediation only.
- Replace sync chains with async events where latency or availability matters.
- Do not quote IBM's "SOA is slower" as universal; it is a vendor statement about shared architecture.
