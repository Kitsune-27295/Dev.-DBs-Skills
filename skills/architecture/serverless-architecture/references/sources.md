# Sources — Serverless Architecture

Every URL below was fetched and read during the 2026-11-27 rebuild (WebFetch).

| Source | Retrieved status | What it contributed |
|---|---|---|
| Roberts, "Serverless Architectures", https://martinfowler.com/articles/serverless.html | 200, read 2026-11-27 except the last 2,865 characters (dated 2018-05-22) | BaaS and FaaS definitions, cold starts, five-minute 2018 duration cap, account-wide concurrency, no-ops rebuttal, drawbacks, testing in the cloud |
| Janakiraman, "Serverless", https://martinfowler.com/bliki/Serverless.html | 200, read 2026-11-27 (dated 2016-06-20) | Client-side control flow, per-request pricing, conceptual overhead, broad stack tests, semantic monitoring |
| AWS Lambda timeout page, https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html | 200, read 2026-11-27 | Current timeout: default 3 s, maximum 1,800 s |
| AWS Serverless Applications Lens, welcome page, https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/welcome.html | 200, read 2026-11-27 | Lens dated 2022-07-14, scope |
| Same lens, failure management, https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/failure-management.html | 200, read 2026-11-27 | DLQ, stream retry controls, partial failures, Step Functions, Express versus Standard |
| Same lens, security pillar, https://docs.aws.amazon.com/wellarchitected/latest/serverless-applications-lens/security-pillar.html | 200, read 2026-11-27 | Five security areas, OS patching removed, OWASP still applies |

## Reading limits

Tool summaries of pages were read, not raw HTML. No scripts or data files exist here. The lens pillars on cost, performance and operations were not read.

## Claims not adopted as fact

- Least-privilege IAM per function, idempotent handlers and module-scope client reuse: standard practice stated in the skill as guidance, not confirmed on the pages read.
- Connection exhaustion of relational databases by concurrent functions and RDS Proxy as the fix: reasoning from limits, not read on a page here.
- Steady 24/7 workloads being cheaper on reserved compute: inference, no price data read.
