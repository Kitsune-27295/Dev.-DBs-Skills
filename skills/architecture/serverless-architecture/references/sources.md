# Sources for the serverless-architecture skill

Retrieved 2026-11-22 via Firecrawl (`firecrawl_scrape`). Statements below summarize the canonical sources and separate architectural rules from author claims.

| # | Source | What the skill takes from it |
|---|---|---|
| 1 | Mike Roberts, "Serverless Architectures" (2018-05-22 / Martin Fowler site), https://martinfowler.com/articles/serverless.html | Dual definition of Serverless as **BaaS** (Backend as a Service — third-party managed data, auth, messaging) and **FaaS** (Function as a Service — event-triggered, stateless, short-lived compute containers); unpacking FaaS constraints (statelessness, execution duration limits, startup latency and cold starts, API Gateways, tooling); contrast with PaaS and containers; explicit debunking of "#NoOps"; benefits (scaling costs for occasional/inconsistent traffic, reduced operational & development cost) vs. drawbacks (vendor lock-in, multitenancy, integration testing difficulty, loss of server optimizations). |
| 2 | Badri Janakiraman, "bliki: Serverless" (2016-06-20), https://martinfowler.com/bliki/Serverless.html | Shift from long-lived server controllers to client-side coordination + third-party BaaS + short-lifecycle FaaS matching a single request/event timeline; demand-based pricing savings on bursty traffic vs. conceptual overhead of weaving many services and reliance on Broad Stack Tests and semantic monitoring. |
| 3 | AWS Well-Architected Framework, "Serverless Applications Lens", https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/welcome.html | Cloud-native well-architected pillars applied to serverless workloads (Compute layer: Lambda/FaaS, Data layer, Messaging/Streaming layer, User Management & Identity, Edge/API Gateway layer, System Monitoring & Deployment); operational excellence, security (least privilege per function), reliability (throttling, retries, DLQs, idempotency), performance efficiency, and cost optimization. |

## Notes on disagreements and nuances across sources

- **Unit testing vs. Broad Stack / Cloud Integration tests:** Both Janakiraman (Source 2) and Roberts (Source 1) emphasize that while unit testing pure business logic extracted from FaaS handlers is essential, a much larger share of a serverless app's behavior lives in cloud configuration (IAM roles, event triggers, BaaS rules). Therefore, automated cloud integration tests and production semantic monitoring must complement local unit tests.
